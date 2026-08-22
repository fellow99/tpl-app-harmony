import { authViewModel } from '../viewmodel/AuthViewModel';
import { LoginRequest, SocialLoginRequest } from '../model/AuthModels';
import { CaptchaUtil } from '../service/CaptchaUtil';
import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';
import { WechatService } from '../service/WechatService';
import { WechatAuthBus, WechatAuthCallback } from '../service/WechatAuthBus';
import { WECHAT_LOGIN_ENABLED, WECHAT_SOURCE } from '../constants/WechatConstants';
import { I18n } from '../utils/I18n';

/**
 * 登录表单组件：密码登录 / 短信登录 双 tab + 图形验证码 + 登录按钮。
 */
@Component
export struct LoginForm {
  /** 登录成功回调（由页面注入，用于跳转） */
  onLoginSuccess: () => void = () => {};

  @State loginMode: string = 'password';
  @State phone: string = '';
  @State password: string = '';
  @State smsCode: string = '';
  @State smsCountdown: number = 0;
  @State sendingSms: boolean = false;
  @State code: string = '';
  @State captchaUuid: string = '';
  @State captchaEnabled: boolean = true;
  @State captchaPixelMap: image.PixelMap | undefined = undefined;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  /** 当前等待微信授权回调的处理函数（用于页面销毁时注销）。 */
  private wechatCallback: WechatAuthCallback | undefined = undefined;

  aboutToAppear(): void {
    this.refreshCaptcha();
  }

  aboutToDisappear(): void {
    if (this.wechatCallback !== undefined) {
      WechatAuthBus.unregister(this.wechatCallback);
      this.wechatCallback = undefined;
    }
  }

  private async refreshCaptcha(): Promise<void> {
    try {
      const resp = await authViewModel.fetchCaptcha();
      this.captchaEnabled = resp.captchaEnabled;
      this.captchaUuid = resp.uuid;
      this.code = '';
      if (resp.captchaEnabled && resp.img !== '') {
        this.captchaPixelMap = await CaptchaUtil.decode(resp.img);
      } else {
        this.captchaPixelMap = undefined;
      }
    } catch (err) {
      this.errorMessage = I18n.t((err as Error).message);
    }
  }

  private async handleSendSms(): Promise<void> {
    const phone: string = this.phone.trim();
    if (phone === '' || !/^1\d{10}$/.test(phone)) {
      this.errorMessage = I18n.t('message.error.phoneInvalid');
      return;
    }
    if (this.smsCountdown > 0 || this.sendingSms) {
      return;
    }
    this.sendingSms = true;
    this.errorMessage = '';
    try {
      await authViewModel.sendSmsCode(phone);
      this.startCountdown();
    } catch (err) {
      this.errorMessage = I18n.t((err as Error).message);
    } finally {
      this.sendingSms = false;
    }
  }

  private startCountdown(): void {
    this.smsCountdown = 60;
    const timer: number = setInterval(() => {
      this.smsCountdown -= 1;
      if (this.smsCountdown <= 0) {
        clearInterval(timer);
        this.smsCountdown = 0;
      }
    }, 1000);
  }

  private async handleLogin(): Promise<void> {
    if (this.isLoading) {
      return;
    }
    if (this.phone.trim() === '' || !/^1\d{10}$/.test(this.phone.trim())) {
      this.errorMessage = I18n.t('message.error.phoneInvalid');
      return;
    }
    if (this.password === '') {
      this.errorMessage = I18n.t('message.error.passwordRequired');
      return;
    }
    if (this.captchaEnabled && this.code.trim() === '') {
      this.errorMessage = I18n.t('message.error.captchaRequired');
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';
    try {
      const req: LoginRequest = {
        grantType: 'password',
        phoneNumber: this.phone.trim(),
        password: this.password,
        code: this.code.trim(),
        uuid: this.captchaUuid
      };
      await authViewModel.login(req);
      this.onLoginSuccess();
    } catch (err) {
      this.errorMessage = I18n.t((err as Error).message);
      this.refreshCaptcha();
    } finally {
      this.isLoading = false;
    }
  }

  private async handleSmsLogin(): Promise<void> {
    if (this.isLoading) {
      return;
    }
    if (this.phone.trim() === '' || !/^1\d{10}$/.test(this.phone.trim())) {
      this.errorMessage = I18n.t('message.error.phoneInvalid');
      return;
    }
    if (this.smsCode.trim() === '') {
      this.errorMessage = I18n.t('message.error.smsCodeRequired');
      return;
    }
    if (this.captchaEnabled && this.code.trim() === '') {
      this.errorMessage = I18n.t('message.error.captchaRequired');
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';
    try {
      const req: LoginRequest = {
        grantType: 'sms',
        phoneNumber: this.phone.trim(),
        smsCode: this.smsCode.trim(),
        code: this.code.trim(),
        uuid: this.captchaUuid
      };
      await authViewModel.login(req);
      this.onLoginSuccess();
    } catch (err) {
      this.errorMessage = I18n.t((err as Error).message);
      this.refreshCaptcha();
    } finally {
      this.isLoading = false;
    }
  }

  private generateState(): string {
    return 'tpl_' + Date.now().toString() + '_' + Math.floor(Math.random() * 1000000).toString();
  }

  private handleWechatLogin(): void {
    if (this.isLoading) {
      return;
    }
    this.errorMessage = '';
    const state: string = this.generateState();
    const callback: WechatAuthCallback = (code: string, respState: string): void => {
      if (respState !== state) {
        this.errorMessage = I18n.t('message.error.wechatStateCheckFailed');
        return;
      }
      this.completeWechatLogin(code, state);
    };
    this.wechatCallback = callback;
    WechatAuthBus.register(callback);
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    WechatService.sendAuthReq(context, state).then((launched: boolean) => {
      if (!launched) {
        WechatAuthBus.unregister(callback);
        this.wechatCallback = undefined;
        this.errorMessage = I18n.t('message.error.wechatLaunchFailed');
      }
    }).catch(() => {
      WechatAuthBus.unregister(callback);
      this.wechatCallback = undefined;
      this.errorMessage = I18n.t('message.error.wechatLaunchFailed');
    });
  }

  private async completeWechatLogin(code: string, state: string): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';
    try {
      const req: SocialLoginRequest = {
        clientId: 'app',
        grantType: 'social',
        source: WECHAT_SOURCE,
        socialCode: code,
        socialState: state
      };
      await authViewModel.socialLogin(req);
      this.onLoginSuccess();
    } catch (err) {
      this.errorMessage = I18n.t((err as Error).message);
    } finally {
      this.isLoading = false;
    }
  }

  @Builder
  private tabButton(label: ResourceStr, mode: string) {
    Text(label)
      .fontSize(15)
      .fontColor(this.loginMode === mode ? '#3B5998' : '#6E6A65')
      .fontWeight(this.loginMode === mode ? FontWeight.Medium : FontWeight.Normal)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .padding({ bottom: 8 })
      .border({ width: { bottom: this.loginMode === mode ? 2 : 0 }, color: '#3B5998' })
      .onClick(() => {
        this.loginMode = mode;
        this.errorMessage = '';
      })
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        this.tabButton($r('app.string.auth_login_tab_password'), 'password')
        this.tabButton($r('app.string.auth_login_tab_sms'), 'sms')
      }
      .width('100%')

      TextInput({ placeholder: $r('app.string.auth_login_phonePlaceholder'), text: this.phone })
        .type(InputType.PhoneNumber)
        .maxLength(11)
        .onChange((value: string) => {
          this.phone = value;
        })
        .height(48)
        .width('100%')
        .fontSize(15)
        .backgroundColor('#FFFFFF')
        .borderRadius(6)
        .border({ width: 1, color: '#D9D4CC' })

      if (this.loginMode === 'password') {
        TextInput({ placeholder: $r('app.string.auth_login_passwordPlaceholder'), text: this.password })
          .type(InputType.Password)
          .showPasswordIcon(true)
          .onChange((value: string) => {
            this.password = value;
          })
          .height(48)
          .width('100%')
          .fontSize(15)
          .backgroundColor('#FFFFFF')
          .borderRadius(6)
          .border({ width: 1, color: '#D9D4CC' })
      } else {
        Row({ space: 12 }) {
          TextInput({ placeholder: $r('app.string.auth_login_smsCodePlaceholder'), text: this.smsCode })
            .type(InputType.Number)
            .maxLength(6)
            .onChange((value: string) => {
              this.smsCode = value;
            })
            .layoutWeight(1)
            .height(48)
            .fontSize(15)
            .backgroundColor('#FFFFFF')
            .borderRadius(6)
            .border({ width: 1, color: '#D9D4CC' })

          Button(this.smsCountdown > 0 ? `${this.smsCountdown}s` : $r('app.string.common_getCode'))
            .height(48)
            .fontSize(13)
            .fontColor('#3B5998')
            .backgroundColor('#EEECE6')
            .enabled(this.smsCountdown === 0 && !this.sendingSms)
            .onClick(() => {
              this.handleSendSms();
            })
        }
        .width('100%')
      }

      if (this.captchaEnabled) {
        Row({ space: 12 }) {
          TextInput({ placeholder: $r('app.string.common_captcha'), text: this.code })
            .onChange((value: string) => {
              this.code = value;
            })
            .maxLength(4)
            .layoutWeight(1)
            .height(48)
            .fontSize(15)
            .backgroundColor('#FFFFFF')
            .borderRadius(6)
            .border({ width: 1, color: '#D9D4CC' })

          if (this.captchaPixelMap !== undefined) {
            Image(this.captchaPixelMap)
              .width(90)
              .height(48)
              .objectFit(ImageFit.Contain)
              .borderRadius(6)
              .border({ width: 1, color: '#D9D4CC' })
              .onClick(() => {
                this.refreshCaptcha();
              })
          } else {
            Text($r('app.string.common_captcha_retry'))
              .width(90)
              .height(48)
              .textAlign(TextAlign.Center)
              .fontSize(12)
              .fontColor('#6E6A65')
              .backgroundColor('#EEECE6')
              .borderRadius(6)
              .onClick(() => {
                this.refreshCaptcha();
              })
          }
        }
        .width('100%')
      }

      if (this.errorMessage !== '') {
        Text(this.errorMessage)
          .fontSize(13)
          .fontColor('#D94E3C')
          .width('100%')
          .textAlign(TextAlign.Center)
      }

      Button(this.isLoading ? $r('app.string.auth_login_submitting') : $r('app.string.auth_login_submit'))
        .width('100%')
        .height(48)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#3B5998')
        .fontColor('#FFFFFF')
        .enabled(!this.isLoading)
        .opacity(this.isLoading ? 0.6 : 1)
        .onClick(() => {
          if (this.loginMode === 'password') {
            this.handleLogin();
          } else {
            this.handleSmsLogin();
          }
        })

      if (WECHAT_LOGIN_ENABLED) {
        Button(this.isLoading ? $r('app.string.auth_wechat_loggingIn') : $r('app.string.auth_wechat_login'))
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#FFFFFF')
          .fontColor('#07C160')
          .border({ width: 1, color: '#07C160' })
          .enabled(!this.isLoading)
          .opacity(this.isLoading ? 0.6 : 1)
          .onClick(() => {
            this.handleWechatLogin();
          })
      }
    }
    .width('100%')
  }
}

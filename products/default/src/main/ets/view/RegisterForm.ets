import { authViewModel } from '../viewmodel/AuthViewModel';
import { RegisterRequest } from '../model/AuthModels';
import { CaptchaUtil } from '../service/CaptchaUtil';
import { image } from '@kit.ImageKit';
import { I18n } from '../utils/I18n';

/**
 * 注册表单组件：用户名 + 密码 + 确认密码 + 图形验证码 + 注册按钮。
 */
@Component
export struct RegisterForm {
  /** 注册成功回调（由页面注入，用于提示与跳转） */
  onRegisterSuccess: () => void = () => {};

  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State code: string = '';
  @State captchaUuid: string = '';
  @State captchaEnabled: boolean = true;
  @State captchaPixelMap: image.PixelMap | undefined = undefined;
  @State smsCode: string = '';
  @State smsCountdown: number = 0;
  @State sendingSms: boolean = false;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    this.refreshCaptcha();
  }

  private get passwordMismatch(): boolean {
    return this.confirmPassword !== '' && this.password !== this.confirmPassword;
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
    const phone: string = this.username.trim();
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

  private async handleRegister(): Promise<void> {
    if (this.isLoading) {
      return;
    }
    if (this.username.trim() === '') {
      this.errorMessage = I18n.t('message.error.phoneRequired');
      return;
    }
    if (this.password.length < 6) {
      this.errorMessage = I18n.t('message.error.passwordTooShort');
      return;
    }
    if (this.password !== this.confirmPassword) {
      this.errorMessage = I18n.t('message.error.passwordMismatch');
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
      const req: RegisterRequest = {
        phoneNumber: this.username.trim(),
        password: this.password,
        smsCode: this.smsCode.trim(),
        code: this.code.trim(),
        uuid: this.captchaUuid
      };
      await authViewModel.register(req);
      this.onRegisterSuccess();
    } catch (err) {
      this.errorMessage = I18n.t((err as Error).message);
      this.refreshCaptcha();
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column({ space: 16 }) {
      TextInput({ placeholder: $r('app.string.auth_register_phonePlaceholder'), text: this.username })
        .onChange((value: string) => {
          this.username = value;
        })
        .height(48)
        .width('100%')
        .fontSize(15)
        .backgroundColor('#FFFFFF')
        .borderRadius(6)
        .border({ width: 1, color: '#D9D4CC' })

      Row({ space: 12 }) {
        TextInput({ placeholder: $r('app.string.common_smsCode'), text: this.smsCode })
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

      TextInput({ placeholder: $r('app.string.auth_register_passwordPlaceholder'), text: this.password })
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

      Column({ space: 4 }) {
        TextInput({ placeholder: $r('app.string.auth_register_confirmPasswordPlaceholder'), text: this.confirmPassword })
          .type(InputType.Password)
          .showPasswordIcon(true)
          .onChange((value: string) => {
            this.confirmPassword = value;
          })
          .height(48)
          .width('100%')
          .fontSize(15)
          .backgroundColor('#FFFFFF')
          .borderRadius(6)
          .border({ width: 1, color: this.passwordMismatch ? '#D94E3C' : '#D9D4CC' })

        if (this.passwordMismatch) {
          Text($r('app.string.message_error_passwordMismatch'))
            .fontSize(12)
            .fontColor('#D94E3C')
            .width('100%')
        }
      }
      .width('100%')

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

      Button(this.isLoading ? $r('app.string.auth_register_submitting') : $r('app.string.auth_register_submit'))
        .width('100%')
        .height(48)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#E8923C')
        .fontColor('#FFFFFF')
        .enabled(!this.isLoading)
        .opacity(this.isLoading ? 0.6 : 1)
        .onClick(() => {
          this.handleRegister();
        })
    }
    .width('100%')
  }
}

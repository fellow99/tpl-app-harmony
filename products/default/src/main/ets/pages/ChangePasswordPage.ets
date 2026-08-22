import { AuthService } from '../service/AuthService';
import { authViewModel } from '../viewmodel/AuthViewModel';
import { CaptchaUtil } from '../service/CaptchaUtil';
import { ChangePasswordRequest } from '../model/AuthModels';
import { LOGIN_ROUTE } from '../constants/RouteConstants';
import { image } from '@kit.ImageKit';
import { AppBar } from '../view/AppBar';
import { I18n } from '../utils/I18n';

/**
 * 修改密码页：当前密码 / 新密码 / 确认新密码 + 短信验证码 + 图形验证码。
 * 布局遵循「App 典型布局」：顶部应用栏（标题 + 返回按钮）+ 中间内容。
 */
@Entry
@Component
struct ChangePasswordPage {
  @State oldPassword: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';
  @State smsCode: string = '';
  @State smsCountdown: number = 0;
  @State sendingSms: boolean = false;
  @State captchaCode: string = '';
  @State captchaUuid: string = '';
  @State captchaEnabled: boolean = true;
  @State captchaPixelMap: image.PixelMap | undefined = undefined;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State isEmptyPassword: boolean = false;

  aboutToAppear(): void {
    this.refreshCaptcha();
    this.loadIsEmptyPassword();
  }

  private async loadIsEmptyPassword(): Promise<void> {
    try {
      this.isEmptyPassword = await AuthService.isEmptyPassword();
    } catch (err) {
      this.isEmptyPassword = false;
    }
  }

  private async refreshCaptcha(): Promise<void> {
    try {
      const resp = await authViewModel.fetchCaptcha();
      this.captchaEnabled = resp.captchaEnabled;
      this.captchaUuid = resp.uuid;
      this.captchaCode = '';
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
    const info = authViewModel.getUserInfo();
    const phone: string = info !== null ? info.phoneNumber : '';
    if (phone === '') {
      this.errorMessage = I18n.t('message.error.phoneEmptyForSms');
      return;
    }
    if (this.smsCountdown > 0 || this.sendingSms) {
      return;
    }
    this.sendingSms = true;
    this.errorMessage = '';
    try {
      await AuthService.sendSmsCode(phone);
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

  private async handleSubmit(): Promise<void> {
    if (this.isLoading) {
      return;
    }
    if (!this.isEmptyPassword && this.oldPassword === '') {
      this.errorMessage = I18n.t('message.error.currentPasswordRequired');
      return;
    }
    if (this.newPassword.length < 6) {
      this.errorMessage = I18n.t('message.error.passwordTooShort');
      return;
    }
    if (this.newPassword !== this.confirmPassword) {
      this.errorMessage = I18n.t('message.error.passwordMismatch');
      return;
    }
    if (this.smsCode.trim() === '') {
      this.errorMessage = I18n.t('message.error.smsCodeRequired');
      return;
    }
    if (this.captchaEnabled && this.captchaCode.trim() === '') {
      this.errorMessage = I18n.t('message.error.captchaRequired');
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';
    try {
      const req: ChangePasswordRequest = {
        oldPassword: this.oldPassword,
        newPassword: this.newPassword,
        confirmPassword: this.confirmPassword,
        smsCode: this.smsCode.trim(),
        code: this.captchaCode.trim(),
        uuid: this.captchaUuid
      };
      await AuthService.changePassword(req);
      // 修改密码后强制重新登录
      await authViewModel.logout();
      this.getUIContext().getRouter().replaceUrl({ url: LOGIN_ROUTE }).catch(() => {
      });
    } catch (err) {
      this.errorMessage = I18n.t((err as Error).message);
      this.refreshCaptcha();
    } finally {
      this.isLoading = false;
    }
  }

  @Builder
  private fieldLabel(label: ResourceStr) {
    Text(label)
      .fontSize(13)
      .fontColor('#6E6A65')
      .width('100%')
  }

  build() {
    Column() {
      AppBar({ title: $r('app.string.auth_profile_changePassword'), showBack: true })

      Row() {
        Column({ space: 16 }) {
          if (!this.isEmptyPassword) {
            Column({ space: 8 }) {
              this.fieldLabel($r('app.string.common_oldPassword'))
              TextInput({ placeholder: $r('app.string.common_oldPassword'), text: this.oldPassword })
                .type(InputType.Password)
                .showPasswordIcon(true)
                .onChange((value: string) => {
                  this.oldPassword = value;
                })
                .height(44)
                .width('100%')
                .fontSize(15)
                .backgroundColor('#FFFFFF')
                .borderRadius(6)
                .border({ width: 1, color: '#D9D4CC' })
            }
            .width('100%')
          }

          Column({ space: 8 }) {
            this.fieldLabel($r('app.string.common_newPassword'))
            TextInput({ placeholder: $r('app.string.common_newPassword'), text: this.newPassword })
              .type(InputType.Password)
              .showPasswordIcon(true)
              .onChange((value: string) => {
                this.newPassword = value;
              })
              .height(44)
              .width('100%')
              .fontSize(15)
              .backgroundColor('#FFFFFF')
              .borderRadius(6)
              .border({ width: 1, color: '#D9D4CC' })
          }
          .width('100%')

          Column({ space: 8 }) {
            this.fieldLabel($r('app.string.common_confirmPassword'))
            TextInput({ placeholder: $r('app.string.common_confirmPassword'), text: this.confirmPassword })
              .type(InputType.Password)
              .showPasswordIcon(true)
              .onChange((value: string) => {
                this.confirmPassword = value;
              })
              .height(44)
              .width('100%')
              .fontSize(15)
              .backgroundColor('#FFFFFF')
              .borderRadius(6)
              .border({ width: 1, color: '#D9D4CC' })
          }
          .width('100%')

          Row({ space: 12 }) {
            TextInput({ placeholder: $r('app.string.common_smsCode'), text: this.smsCode })
              .type(InputType.Number)
              .maxLength(6)
              .onChange((value: string) => {
                this.smsCode = value;
              })
              .layoutWeight(1)
              .height(44)
              .fontSize(15)
              .backgroundColor('#FFFFFF')
              .borderRadius(6)
              .border({ width: 1, color: '#D9D4CC' })

            Button(this.smsCountdown > 0 ? `${this.smsCountdown}s` : $r('app.string.common_getCode'))
              .height(44)
              .fontSize(13)
              .fontColor('#3B5998')
              .backgroundColor('#EEECE6')
              .enabled(this.smsCountdown === 0 && !this.sendingSms)
              .onClick(() => {
                this.handleSendSms();
              })
          }
          .width('100%')

          if (this.captchaEnabled) {
            Row({ space: 12 }) {
              TextInput({ placeholder: $r('app.string.common_captcha'), text: this.captchaCode })
                .onChange((value: string) => {
                  this.captchaCode = value;
                })
                .maxLength(4)
                .layoutWeight(1)
                .height(44)
                .fontSize(15)
                .backgroundColor('#FFFFFF')
                .borderRadius(6)
                .border({ width: 1, color: '#D9D4CC' })

              if (this.captchaPixelMap !== undefined) {
                Image(this.captchaPixelMap)
                  .width(90)
                  .height(44)
                  .objectFit(ImageFit.Contain)
                  .borderRadius(6)
                  .border({ width: 1, color: '#D9D4CC' })
                  .onClick(() => {
                    this.refreshCaptcha();
                  })
              } else {
                Text($r('app.string.common_captcha_retry'))
                  .width(90)
                  .height(44)
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

          Button(this.isLoading ? $r('app.string.auth_profile_submitting') : $r('app.string.auth_profile_submit'))
            .width('100%')
            .height(48)
            .fontSize(17)
            .fontColor('#FFFFFF')
            .backgroundColor('#E8923C')
            .enabled(!this.isLoading)
            .opacity(this.isLoading ? 0.6 : 1)
            .onClick(() => {
              this.handleSubmit();
            })
        }
        .width('100%')
        .constraintSize({ maxWidth: 480 })
        .padding({ left: 24, right: 24, top: 16, bottom: 16 })
        .layoutWeight(1)
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F5F0')
  }
}

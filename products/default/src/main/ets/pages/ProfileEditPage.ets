import { AuthService } from '../service/AuthService';
import { authViewModel } from '../viewmodel/AuthViewModel';
import { CaptchaUtil } from '../service/CaptchaUtil';
import { UserInfo } from '../model/UserInfo';
import { UpdateProfileRequest } from '../model/AuthModels';
import { image } from '@kit.ImageKit';
import { AppBar } from '../view/AppBar';
import { I18n } from '../utils/I18n';

/**
 * 修改信息页：昵称 / email / 生日 + 图形验证码。
 * 布局遵循「App 典型布局」：顶部应用栏（标题 + 返回按钮）+ 中间内容。
 */
@Entry
@Component
struct ProfileEditPage {
  @State nickName: string = '';
  @State email: string = '';
  @State birthDate: string = '';
  @State captchaCode: string = '';
  @State captchaUuid: string = '';
  @State captchaEnabled: boolean = true;
  @State captchaPixelMap: image.PixelMap | undefined = undefined;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    this.loadProfile();
    this.refreshCaptcha();
  }

  private loadProfile(): void {
    const info: UserInfo | null = authViewModel.getUserInfo();
    if (info !== null) {
      this.nickName = info.nickName;
      this.email = info.email;
      this.birthDate = info.birthDate;
    }
  }

  private showDatePicker(): void {
    const selected: Date = this.birthDate !== '' ? new Date(this.birthDate) : new Date();
    DatePickerDialog.show({
      start: new Date('1900-01-01'),
      end: new Date('2030-12-31'),
      selected: selected,
      onDateAccept: (value: Date) => {
        const y: number = value.getFullYear();
        const m: string = (value.getMonth() + 1).toString().padStart(2, '0');
        const d: string = value.getDate().toString().padStart(2, '0');
        this.birthDate = `${y}-${m}-${d}`;
      }
    });
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

  private async handleSave(): Promise<void> {
    if (this.isLoading) {
      return;
    }
    if (this.nickName.trim() === '') {
      this.errorMessage = I18n.t('message.error.nicknameRequired');
      return;
    }
    if (this.captchaEnabled && this.captchaCode.trim() === '') {
      this.errorMessage = I18n.t('message.error.captchaRequired');
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';
    try {
      const req: UpdateProfileRequest = {
        nickName: this.nickName.trim(),
        email: this.email.trim(),
        birthDate: this.birthDate.trim(),
        code: this.captchaCode.trim(),
        uuid: this.captchaUuid
      };
      await AuthService.updateProfile(req);
      await authViewModel.refreshUserInfo();
      this.getUIContext().getRouter().back();
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
      AppBar({ title: $r('app.string.auth_profile_editInfo'), showBack: true })

      Row() {
        Column({ space: 16 }) {
          Column({ space: 8 }) {
            this.fieldLabel($r('app.string.common_nickname'))
            TextInput({ placeholder: $r('app.string.auth_profile_nicknamePlaceholder'), text: this.nickName })
              .onChange((value: string) => {
                this.nickName = value;
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
            this.fieldLabel('Email')
            TextInput({ placeholder: $r('app.string.auth_profile_emailPlaceholder'), text: this.email })
              .type(InputType.Email)
              .onChange((value: string) => {
                this.email = value;
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
            this.fieldLabel($r('app.string.common_birthday'))
            Text(this.birthDate === '' ? $r('app.string.auth_profile_birthdayPlaceholder') : this.birthDate)
              .fontSize(15)
              .fontColor(this.birthDate === '' ? '#B0ADA8' : '#292522')
              .textAlign(TextAlign.Start)
              .width('100%')
              .height(44)
              .padding({ left: 12, right: 12 })
              .backgroundColor('#FFFFFF')
              .borderRadius(6)
              .border({ width: 1, color: '#D9D4CC' })
              .onClick(() => {
                this.showDatePicker();
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

          Button(this.isLoading ? $r('app.string.auth_profile_saving') : $r('app.string.auth_profile_save'))
            .width('100%')
            .height(48)
            .fontSize(17)
            .fontColor('#FFFFFF')
            .backgroundColor('#3B5998')
            .enabled(!this.isLoading)
            .opacity(this.isLoading ? 0.6 : 1)
            .onClick(() => {
              this.handleSave();
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

import { RegisterForm } from '../view/RegisterForm';

/**
 * 注册页。
 */
@Entry
@Component
struct RegisterPage {
  @State showSuccess: boolean = false;

  private handleRegisterSuccess(): void {
    this.showSuccess = true;
    setTimeout(() => {
      this.getUIContext().getRouter().back();
    }, 2000);
  }

  build() {
    Scroll() {
      Row() {
        Column() {
          Row() {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(24)
              .fontColor(['#292522'])
              .onClick(() => {
                this.getUIContext().getRouter().back();
              })
          }
          .width('100%')
          .height(56)
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)

          Column({ space: 8 }) {
            Text($r('app.string.auth_register_title'))
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#292522')
            Text($r('app.string.app_tagline'))
              .fontSize(13)
              .fontColor('#6E6A65')
          }
          .width('100%')
          .margin({ bottom: 32 })
          .alignItems(HorizontalAlign.Center)

          if (this.showSuccess) {
            Row({ space: 6 }) {
              Text('✓')
                .fontSize(15)
                .fontColor('#4AA878')
              Text($r('app.string.message_registerSuccessRedirect'))
                .fontSize(14)
                .fontColor('#4AA878')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#E6F4EE')
            .borderRadius(8)
            .margin({ bottom: 16 })
          }

          RegisterForm({
            onRegisterSuccess: () => {
              this.handleRegisterSuccess();
            }
          })

          Row({ space: 4 }) {
            Text($r('app.string.auth_register_hasAccount'))
              .fontSize(13)
              .fontColor('#6E6A65')
            Text($r('app.string.auth_register_goLogin'))
              .fontSize(13)
              .fontColor('#3B5998')
              .onClick(() => {
                this.getUIContext().getRouter().back();
              })
          }
          .margin({ top: 24, bottom: 40 })
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .constraintSize({ maxWidth: 480 })
        .padding({ left: 24, right: 24 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F5F0')
    .scrollBar(BarState.Off)
  }
}

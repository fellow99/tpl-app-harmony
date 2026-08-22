import { LoginForm } from '../view/LoginForm';
import { REGISTER_ROUTE, PROFILE_ROUTE } from '../constants/RouteConstants';
import { ThemeManager } from '../utils/ThemeManager';
import { I18n } from '../utils/I18n';

/**
 * 登录页：右上角提供圆形 emoji 主题切换按钮（🌙/☀️，light↔dark 显式切换）。
 */
@Entry
@Component
struct LoginPage {
  /** 当前是否暗色生效（ThemeManager 经 AppStorage 桥接，只读订阅，驱动按钮图标）。 */
  @StorageProp('effectiveDark') effectiveDark: boolean = false;

  /** 切换主题：light↔dark 显式选择，覆盖 system 默认。 */
  private handleToggleTheme(): void {
    ThemeManager.setMode(this.effectiveDark ? 'light' : 'dark');
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Scroll() {
        Row() {
          Column() {
            Column({ space: 8 }) {
              Text($r('app.string.app_name'))
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.color_primary'))
              Text($r('app.string.app_slogan'))
                .fontSize(14)
                .fontColor($r('app.color.color_text_secondary'))
            }
            .width('100%')
            .margin({ top: 80, bottom: 40 })
            .alignItems(HorizontalAlign.Center)

            LoginForm({
              onLoginSuccess: () => {
                this.getUIContext().getRouter().replaceUrl({ url: PROFILE_ROUTE }).catch(() => {
                });
              }
            })

            Row({ space: 4 }) {
              Text($r('app.string.auth_login_noAccount'))
                .fontSize(13)
                .fontColor($r('app.color.color_text_secondary'))
              Text($r('app.string.auth_login_goRegister'))
                .fontSize(13)
                .fontColor($r('app.color.color_primary'))
                .onClick(() => {
                  this.getUIContext().getRouter().pushUrl({ url: REGISTER_ROUTE }).catch(() => {
                  });
                })
            }
            .margin({ top: 24 })
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
      .backgroundColor($r('app.color.color_bg'))
      .scrollBar(BarState.Off)

      Row({ space: 8 }) {
        Row() {
          Text('🌐')
            .fontSize(20)
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.color_surface'))
        .borderRadius(22)
        .border({ width: 1, color: $r('app.color.color_border') })
        .bindMenu([
          { value: '简体中文', action: () => { I18n.setLocale('zh-CN'); } },
          { value: 'English', action: () => { I18n.setLocale('en-US'); } },
          { value: '繁體中文', action: () => { I18n.setLocale('zh-TW'); } },
        ])

        Row() {
          Text(this.effectiveDark ? '☀️' : '🌙')
            .fontSize(20)
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.color_surface'))
        .borderRadius(22)
        .border({ width: 1, color: $r('app.color.color_border') })
        .onClick(() => {
          this.handleToggleTheme();
        })
      }
      .margin({ top: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.color_bg'))
  }
}

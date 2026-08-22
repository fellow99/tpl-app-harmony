import { PROFILE_ROUTE } from '../constants/RouteConstants';

/**
 * 底部导航栏：应用主菜单切换（个人中心）。
 * 参考父工程 specs/002-user-auth/spec.md §9.2「App 典型布局」。
 */
@Component
export struct BottomNavBar {
  /** 当前激活的主菜单：profile */
  @Prop active: string = 'profile';

  @Builder
  private navItem(label: ResourceStr, key: string, route: string) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(11)
        .fontColor(this.active === key ? '#3B5998' : '#6E6A65')
        .fontWeight(this.active === key ? FontWeight.Medium : FontWeight.Normal)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.active !== key) {
        this.getUIContext().getRouter().replaceUrl({ url: route }).catch(() => {
        });
      }
    })
  }

  build() {
    Row() {
      this.navItem($r('app.string.auth_profile_title'), 'profile', PROFILE_ROUTE)
    }
    .width('100%')
    .height(56)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 1 }, color: '#EEECE6' })
  }
}

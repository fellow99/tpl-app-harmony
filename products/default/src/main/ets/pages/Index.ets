import { StorageService } from '../service/StorageService';
import { PROFILE_ROUTE, LOGIN_ROUTE } from '../constants/RouteConstants';

/**
 * Index 是应用首页入口，负责路由分发：
 * 已登录 → 个人中心；未登录 → 登录页。
 */
@Entry
@Component
struct Index {
  private hasDispatched: boolean = false;

  aboutToAppear(): void {
    this.dispatchRoute();
  }

  private dispatchRoute(): void {
    if (this.hasDispatched) {
      return;
    }
    this.hasDispatched = true;
    const isLoggedIn: boolean = StorageService.isLoggedIn();
    const targetRoute: string = isLoggedIn ? PROFILE_ROUTE : LOGIN_ROUTE;
    this.getUIContext().getRouter().replaceUrl({ url: targetRoute }).catch(() => {
      this.hasDispatched = false;
    });
  }

  build() {
    Column() {
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}

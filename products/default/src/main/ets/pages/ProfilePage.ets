import { AuthService } from '../service/AuthService';
import { StorageService } from '../service/StorageService';
import { UserInfo } from '../model/UserInfo';
import { SocialLoginRequest } from '../model/AuthModels';
import { ApiError } from '../service/ApiClient';
import { authViewModel } from '../viewmodel/AuthViewModel';
import { AppBar } from '../view/AppBar';
import { BottomNavBar } from '../view/BottomNavBar';
import { LOGIN_ROUTE, PROFILE_ROUTE, PROFILE_EDIT_ROUTE, CHANGE_PASSWORD_ROUTE } from '../constants/RouteConstants';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { WechatService } from '../service/WechatService';
import { WechatAuthBus, WechatAuthCallback } from '../service/WechatAuthBus';
import { WECHAT_LOGIN_ENABLED, WECHAT_SOURCE } from '../constants/WechatConstants';
import { I18n, LOCALES, AppLocale } from '../utils/I18n';
import { ThemeManager, THEME_MODES, ThemeMode } from '../utils/ThemeManager';

/** 语言选项展示名（自识别，语料暂无 language.* 键，暂硬编码，与 tpl-app-mini LANGUAGE_NAMES 一致）。 */
const LANGUAGE_NAMES: Record<AppLocale, string> = {
  'zh-CN': '简体中文',
  'en-US': 'English',
  'zh-TW': '繁體中文',
};

/** 主题选项展示名（自识别，语料暂无 theme.* 键，暂硬编码）。 */
const THEME_NAMES: Record<ThemeMode, string> = {
  'light': '浅色',
  'dark': '深色',
  'system': '跟随系统',
};

/**
 * 个人中心：展示当前用户信息，提供「修改信息」「修改密码」「切换语言」「切换主题」「退出登录」入口。
 * 布局遵循「App 典型布局」：顶部应用栏（标题）+ 中间内容 + 底部导航栏。
 */
@Entry
@Component
struct ProfilePage {
  @State isLoading: boolean = true;
  @State userInfo: UserInfo | null = null;

  /** 当前等待微信授权回调的处理函数（用于页面销毁时注销）。 */
  private wechatCallback: WechatAuthCallback | undefined = undefined;

  aboutToAppear(): void {
    if (!StorageService.isLoggedIn()) {
      this.redirectToLogin();
      return;
    }
    this.loadProfile();
  }

  aboutToDisappear(): void {
    if (this.wechatCallback !== undefined) {
      WechatAuthBus.unregister(this.wechatCallback);
      this.wechatCallback = undefined;
    }
  }

  private redirectToLogin(): void {
    this.getUIContext().getRouter().replaceUrl({ url: LOGIN_ROUTE }).catch(() => {
    });
  }

  private async loadProfile(): Promise<void> {
    this.isLoading = true;
    // 先展示本地缓存（如有），避免闪现全「-」
    const cached: UserInfo | null = authViewModel.getUserInfo();
    if (cached !== null) {
      this.userInfo = cached;
    }
    this.isLoading = false;
    try {
      const info: UserInfo = await AuthService.fetchUserInfo();
      this.userInfo = info;
      StorageService.saveUserInfo(info);
    } catch (err) {
      if (err instanceof ApiError && err.code === 401) {
        this.redirectToLogin();
        return;
      }
      // 获取失败沿用本地缓存
    }
  }

  private async handleLogout(): Promise<void> {
    await authViewModel.logout();
    this.redirectToLogin();
  }

  /** 切换语言：TextPickerDialog 列出三语言，选中后 setLocale + 重载当前页使静态 $r 重解析。 */
  private handleChangeLanguage(): void {
    TextPickerDialog.show({
      range: LOCALES.map((l: AppLocale): string => LANGUAGE_NAMES[l]),
      selected: LOCALES.indexOf(I18n.getCurrentLocale()),
      onAccept: (value: TextPickerResult) => {
        const idx: number = value.index as number;
        const locale: AppLocale = LOCALES[idx];
        if (locale !== undefined && locale !== I18n.getCurrentLocale()) {
          I18n.setLocale(locale);
          this.getUIContext().getRouter().replaceUrl({ url: PROFILE_ROUTE }).catch(() => {
          });
        }
      },
    });
  }

  /** 切换主题：TextPickerDialog 列出三态，选中后 setMode 即时生效（无需重载页面）。 */
  private handleChangeTheme(): void {
    TextPickerDialog.show({
      range: THEME_MODES.map((m: ThemeMode): string => THEME_NAMES[m]),
      selected: THEME_MODES.indexOf(ThemeManager.getCurrentMode()),
      onAccept: (value: TextPickerResult) => {
        const idx: number = value.index as number;
        const mode: ThemeMode = THEME_MODES[idx];
        if (mode !== undefined && mode !== ThemeManager.getCurrentMode()) {
          ThemeManager.setMode(mode);
        }
      },
    });
  }

  private generateState(): string {
    return 'tpl_' + Date.now().toString() + '_' + Math.floor(Math.random() * 1000000).toString();
  }

  private handleBindWechat(): void {
    const state: string = this.generateState();
    const callback: WechatAuthCallback = (code: string, respState: string): void => {
      if (respState !== state) {
        promptAction.showToast({ message: $r('app.string.message_error_wechatStateCheckFailed') });
        return;
      }
      this.completeBindWechat(code, state);
    };
    this.wechatCallback = callback;
    WechatAuthBus.register(callback);
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    WechatService.sendAuthReq(context, state).then((launched: boolean) => {
      if (!launched) {
        WechatAuthBus.unregister(callback);
        this.wechatCallback = undefined;
        promptAction.showToast({ message: $r('app.string.message_error_wechatLaunchFailed') });
      }
    }).catch(() => {
      WechatAuthBus.unregister(callback);
      this.wechatCallback = undefined;
      promptAction.showToast({ message: $r('app.string.message_error_wechatLaunchFailed') });
    });
  }

  private async completeBindWechat(code: string, state: string): Promise<void> {
    try {
      const req: SocialLoginRequest = {
        clientId: 'app',
        grantType: 'social',
        source: WECHAT_SOURCE,
        socialCode: code,
        socialState: state
      };
      await AuthService.socialCallback(req);
      promptAction.showToast({ message: $r('app.string.message_wechatBound') });
    } catch (err) {
      promptAction.showToast({ message: I18n.t((err as Error).message) });
    }
  }

  @Builder
  private infoRow(label: ResourceStr, value: string) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor($r('app.color.color_text_secondary'))
        .layoutWeight(1)
      Text(value)
        .fontSize(15)
        .fontColor($r('app.color.color_text'))
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding({ top: 14, bottom: 14 })
    .border({ width: { bottom: 1 }, color: $r('app.color.color_divider') })
  }

  build() {
    Column() {
      AppBar({ title: $r('app.string.auth_profile_title') })

      Row() {
        Column({ space: 16 }) {
          Column() {
            this.infoRow($r('app.string.common_nickname'), this.userInfo !== null ? this.userInfo.nickName : '-')
            this.infoRow($r('app.string.common_phone'), this.userInfo !== null ? this.userInfo.phoneNumber : '-')
            this.infoRow('Email', this.userInfo !== null && this.userInfo.email !== '' ? this.userInfo.email : '-')
            this.infoRow($r('app.string.common_birthday'), this.userInfo !== null && this.userInfo.birthDate !== '' ? this.userInfo.birthDate : '-')
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .backgroundColor($r('app.color.color_surface'))
          .borderRadius(12)

          Column({ space: 8 }) {
            Button($r('app.string.auth_profile_editInfo'))
              .width('100%')
              .height(44)
              .fontSize(15)
              .fontColor($r('app.color.color_surface'))
              .backgroundColor($r('app.color.color_primary'))
              .onClick(() => {
                this.getUIContext().getRouter().pushUrl({ url: PROFILE_EDIT_ROUTE }).catch(() => {
                });
              })

            Button($r('app.string.auth_profile_changePassword'))
              .width('100%')
              .height(44)
              .fontSize(15)
              .fontColor($r('app.color.color_primary'))
              .backgroundColor($r('app.color.color_surface'))
              .border({ width: 1, color: $r('app.color.color_primary') })
              .onClick(() => {
                this.getUIContext().getRouter().pushUrl({ url: CHANGE_PASSWORD_ROUTE }).catch(() => {
                });
              })

            if (WECHAT_LOGIN_ENABLED) {
              Button($r('app.string.auth_profile_bindWechat'))
                .width('100%')
                .height(44)
                .fontSize(15)
                .fontColor($r('app.color.color_wechat'))
                .backgroundColor($r('app.color.color_surface'))
                .border({ width: 1, color: $r('app.color.color_wechat') })
                .onClick(() => {
                  this.handleBindWechat();
                })
            }

            Button($r('app.string.auth_profile_language'))
              .width('100%')
              .height(44)
              .fontSize(15)
              .fontColor($r('app.color.color_primary'))
              .backgroundColor($r('app.color.color_surface'))
              .border({ width: 1, color: $r('app.color.color_primary') })
              .onClick(() => {
                this.handleChangeLanguage();
              })

            Button($r('app.string.auth_profile_theme'))
              .width('100%')
              .height(44)
              .fontSize(15)
              .fontColor($r('app.color.color_primary'))
              .backgroundColor($r('app.color.color_surface'))
              .border({ width: 1, color: $r('app.color.color_primary') })
              .onClick(() => {
                this.handleChangeTheme();
              })

            Button($r('app.string.auth_profile_logout'))
              .width('100%')
              .height(44)
              .fontSize(15)
              .fontColor($r('app.color.color_danger'))
              .backgroundColor($r('app.color.color_surface'))
              .onClick(() => {
                this.handleLogout();
              })
          }
          .width('100%')
        }
        .width('100%')
        .constraintSize({ maxWidth: 480 })
        .padding({ left: 24, right: 24, top: 16 })
        .layoutWeight(1)
      }
      .width('100%')
      .layoutWeight(1)

      BottomNavBar({ active: 'profile' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.color_bg'))
  }
}

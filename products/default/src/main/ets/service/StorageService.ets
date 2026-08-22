import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { UserInfo } from '../model/UserInfo';

/**
 * 本地存储服务：基于 @ohos.data.preferences 保存认证令牌与用户信息。
 * 敏感数据（密码）不落盘，仅保存 Token 与用户基本信息。
 */

const STORE_NAME: string = 'tpl_app_storage';
const KEY_TOKEN: string = 'auth_token';
const KEY_USER_INFO: string = 'user_info';
const KEY_LANGUAGE: string = 'language';
const KEY_THEME: string = 'theme';

export class StorageService {
  private static pref: preferences.Preferences | undefined = undefined;

  /**
   * 初始化存储实例，须在应用启动（DefaultAbility.onCreate）时调用一次。
   *
   * @param context 应用上下文。
   */
  static init(context: common.Context): void {
    if (StorageService.pref === undefined) {
      StorageService.pref = preferences.getPreferencesSync(context, { name: STORE_NAME });
    }
  }

  private static getPreferences(): preferences.Preferences {
    if (StorageService.pref === undefined) {
      throw new Error('StorageService 尚未初始化，请先调用 init()');
    }
    return StorageService.pref;
  }

  private static persist(): void {
    StorageService.getPreferences().flush().catch(() => {
      // 持久化失败不影响内存中的值，忽略即可
    });
  }

  /**
   * 保存认证令牌。
   */
  static saveToken(token: string): void {
    StorageService.getPreferences().putSync(KEY_TOKEN, token);
    StorageService.persist();
  }

  /**
   * 获取认证令牌；未登录返回空字符串。
   */
  static getToken(): string {
    return StorageService.getPreferences().getSync(KEY_TOKEN, '') as string;
  }

  /**
   * 清除认证令牌。
   */
  static clearToken(): void {
    StorageService.getPreferences().deleteSync(KEY_TOKEN);
    StorageService.persist();
  }

  /**
   * 保存用户信息。
   */
  static saveUserInfo(userInfo: UserInfo): void {
    StorageService.getPreferences().putSync(KEY_USER_INFO, JSON.stringify(userInfo));
    StorageService.persist();
  }

  /**
   * 获取用户信息；不存在返回 null。
   */
  static getUserInfo(): UserInfo | null {
    const json: string = StorageService.getPreferences().getSync(KEY_USER_INFO, '') as string;
    if (json === '') {
      return null;
    }
    return JSON.parse(json) as UserInfo;
  }

  /**
   * 清除用户信息。
   */
  static clearUserInfo(): void {
    StorageService.getPreferences().deleteSync(KEY_USER_INFO);
    StorageService.persist();
  }

  /**
   * 清除全部认证状态（Token + 用户信息）。
   */
  static clearAll(): void {
    StorageService.clearToken();
    StorageService.clearUserInfo();
  }

  /**
   * 是否已登录（存在 Token）。
   */
  static isLoggedIn(): boolean {
    return StorageService.getToken() !== '';
  }

  /**
   * 保存应用内语言偏好（如 'zh-CN' / 'en-US' / 'zh-TW'）。
   */
  static saveLanguage(language: string): void {
    StorageService.getPreferences().putSync(KEY_LANGUAGE, language);
    StorageService.persist();
  }

  /**
   * 获取应用内语言偏好；未设置返回空字符串（跟随系统）。
   */
  static getLanguage(): string {
    return StorageService.getPreferences().getSync(KEY_LANGUAGE, '') as string;
  }

  /**
   * 保存应用主题模式（'light' / 'dark' / 'system'）。
   */
  static saveTheme(theme: string): void {
    StorageService.getPreferences().putSync(KEY_THEME, theme);
    StorageService.persist();
  }

  /**
   * 获取应用主题模式；未设置返回 'system'（跟随系统）。
   */
  static getTheme(): string {
    return StorageService.getPreferences().getSync(KEY_THEME, 'system') as string;
  }
}

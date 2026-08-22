import { common } from '@kit.AbilityKit';
import { i18n, resourceManager } from '@kit.LocalizationKit';
import { StorageService } from '../service/StorageService';

/**
 * 应用支持的语言（与父工程语料三语言一致，连字符 BCP 47 格式）。
 */
export type AppLocale = 'zh-CN' | 'en-US' | 'zh-TW';

/**
 * 全部支持语言。
 */
export const LOCALES: AppLocale[] = ['zh-CN', 'en-US', 'zh-TW'];

/**
 * 语言 tag（连字符）→ 资源限定符（下划线，匹配 resources/{en_US,zh_TW}/ 目录）。
 * zh-CN 语料位于 base/（默认语言），覆盖为 zh_CN 时无对应目录，自动回退 base。
 */
const RESOURCE_LOCALE: Record<AppLocale, string> = {
  'zh-CN': 'zh_CN',
  'en-US': 'en_US',
  'zh-TW': 'zh_TW',
};

/**
 * 国际化翻译工具。
 *
 * - `t(key)`：后端点号 key（如 message.error.loginFailed）→ 运行时按当前语言解析文案，
 *   未命中回退原 key，保证界面不白屏。
 * - 应用内语言切换：`setLocale` / `applySavedLocale` + 覆盖资源解析（`getOverrideResourceManager`），
 *   使动态 key 即时随语言切换，不受系统语言资源缓存影响。
 */
export class I18n {
  /** 当前生效语言；冷启动由 applySavedLocale 初始化（跟随系统或恢复上次选择）。 */
  private static currentLocale: AppLocale = 'zh-CN';

  /** 覆盖语言后的资源管理器缓存；语言切换时失效。 */
  private static overrideManager: resourceManager.ResourceManager | undefined = undefined;

  /**
   * 获取当前生效语言。
   */
  static getCurrentLocale(): AppLocale {
    return I18n.currentLocale;
  }

  /**
   * 判断字符串是否为受支持的语言。
   */
  static isLocale(value: string): boolean {
    return (LOCALES as string[]).includes(value);
  }

  /**
   * 切换语言：更新内存态 → 持久化 → 设置应用偏好语言 → 失效覆盖资源缓存。
   */
  static setLocale(locale: AppLocale): void {
    I18n.currentLocale = locale;
    I18n.overrideManager = undefined;
    StorageService.saveLanguage(locale);
    try {
      i18n.System.setAppPreferredLanguage(locale);
    } catch (e) {
      // 忽略：偏好语言设置失败不影响运行时翻译（覆盖资源解析兜底）
    }
  }

  /**
   * 冷启动恢复语言：优先读持久化偏好，否则按系统语言归一化跟随系统。
   * 须在 StorageService.init 之后调用（DefaultAbility.onCreate）。
   */
  static applySavedLocale(): void {
    const saved: string = StorageService.getLanguage();
    if (I18n.isLocale(saved)) {
      I18n.currentLocale = saved as AppLocale;
    } else {
      I18n.currentLocale = I18n.normalizeSystemLocale(I18n.getSystemLanguageSafe());
    }
    I18n.overrideManager = undefined;
    try {
      i18n.System.setAppPreferredLanguage(I18n.currentLocale);
    } catch (e) {
      // 忽略
    }
  }

  /**
   * 读取系统语言；失败回退简体中文。
   */
  private static getSystemLanguageSafe(): string {
    try {
      return i18n.System.getSystemLanguage();
    } catch (e) {
      return 'zh-CN';
    }
  }

  /**
   * 将系统语言归一化为受支持语言。
   */
  private static normalizeSystemLocale(lang: string): AppLocale {
    const l: string = lang.toLowerCase();
    if (l.startsWith('zh') && (l.includes('tw') || l.includes('hk') || l.includes('mo') || l.includes('hant'))) {
      return 'zh-TW';
    }
    if (l.startsWith('zh')) {
      return 'zh-CN';
    }
    if (l.startsWith('en')) {
      return 'en-US';
    }
    return 'zh-CN';
  }

  /**
   * 获取按当前语言覆盖后的资源管理器（惰性创建 + 缓存）。
   */
  private static getOverrideManager(): resourceManager.ResourceManager {
    if (I18n.overrideManager !== undefined) {
      return I18n.overrideManager;
    }
    const ctx: common.Context = getContext() as common.Context;
    const resMgr: resourceManager.ResourceManager = ctx.resourceManager;
    const conf: resourceManager.Configuration = resMgr.getOverrideConfiguration();
    conf.locale = RESOURCE_LOCALE[I18n.currentLocale];
    I18n.overrideManager = resMgr.getOverrideResourceManager(conf);
    return I18n.overrideManager;
  }

  /**
   * 将点号 i18n key 翻译为当前语言的字符串。
   *
   * @param key 点号 i18n key（空串原样返回空串）。
   * @return 翻译后的文案；未命中时回退原 key。
   */
  static t(key: string): string {
    if (key === '') {
      return '';
    }
    const resourceName: string = key.replace(/\./g, '_');
    try {
      return I18n.getOverrideManager().getStringByNameSync(resourceName);
    } catch (e) {
      return key;
    }
  }
}

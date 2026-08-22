import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { StorageService } from '../service/StorageService';

/**
 * 应用主题模式（三态，与父工程 specs/005-theme/spec.md §4.1 一致）。
 */
export type ThemeMode = 'light' | 'dark' | 'system';

/**
 * 全部支持的主题模式。
 */
export const THEME_MODES: ThemeMode[] = ['light', 'dark', 'system'];

/**
 * AppStorage 键：用户三态选择（light/dark/system），供 @StorageLink/@StorageProp 订阅。
 */
export const THEME_MODE_KEY: string = 'themeMode';

/**
 * AppStorage 键：解析后「当前是否暗色生效」，供登录页按钮图标等只读订阅。
 */
export const EFFECTIVE_DARK_KEY: string = 'effectiveDark';

const DOMAIN = 0x0000;
const TAG = 'ThemeManager';

/**
 * 三态 → setColorMode 映射（父工程 spec.md §3.2 三态主题 / §4.1 状态模型）：
 * system → COLOR_MODE_NOT_SET（跟随系统）、light → COLOR_MODE_LIGHT、dark → COLOR_MODE_DARK。
 */
const COLOR_MODE: Record<ThemeMode, ConfigurationConstant.ColorMode> = {
  'light': ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT,
  'dark': ConfigurationConstant.ColorMode.COLOR_MODE_DARK,
  'system': ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET,
};

/**
 * 主题管理器。
 *
 * - 三态（light/dark/system，默认 system）+ 本地持久化（StorageService，key theme）。
 * - `setColorMode` 切换资源限定符（base ↔ dark），$r('app.color.*') 即时重解析。
 * - 经 AppStorage 桥接（themeMode / effectiveDark）驱动登录页按钮图标与个人中心选择器同步。
 */
export class ThemeManager {
  /** 当前生效主题模式；冷启动由 applySavedTheme 初始化（跟随系统或恢复上次选择）。 */
  private static currentMode: ThemeMode = 'system';

  /** 应用上下文（applySavedTheme 时由 DefaultAbility.onCreate 注入，setMode 复用）。 */
  private static appContext: common.Context | undefined = undefined;

  /**
   * 获取当前生效主题模式。
   */
  static getCurrentMode(): ThemeMode {
    return ThemeManager.currentMode;
  }

  /**
   * 判断字符串是否为受支持的主题模式。
   */
  static isMode(value: string): boolean {
    return (THEME_MODES as string[]).includes(value);
  }

  /**
   * 切换主题：更新内存态 → 持久化 → 更新 AppStorage → setColorMode。
   * 须在 applySavedTheme 之后调用（appContext 已注入）。
   */
  static setMode(mode: ThemeMode): void {
    ThemeManager.currentMode = mode;
    StorageService.saveTheme(mode);
    AppStorage.setOrCreate(THEME_MODE_KEY, mode);
    AppStorage.setOrCreate(EFFECTIVE_DARK_KEY, ThemeManager.resolveEffectiveDark());
    ThemeManager.applyColorMode();
  }

  /**
   * 冷启动恢复主题：注入上下文 → 读持久化偏好（否则 system）→ 更新 AppStorage → setColorMode。
   * 须在 StorageService.init 之后调用（DefaultAbility.onCreate）。
   */
  static applySavedTheme(context: common.Context): void {
    ThemeManager.appContext = context;
    const saved: string = StorageService.getTheme();
    ThemeManager.currentMode = ThemeManager.isMode(saved) ? saved as ThemeMode : 'system';
    AppStorage.setOrCreate(THEME_MODE_KEY, ThemeManager.currentMode);
    AppStorage.setOrCreate(EFFECTIVE_DARK_KEY, ThemeManager.resolveEffectiveDark());
    ThemeManager.applyColorMode();
  }

  /**
   * 当前是否以暗色生效（解析三态，供登录页按钮图标、切换方向判定使用）。
   */
  static isEffectiveDark(): boolean {
    return ThemeManager.resolveEffectiveDark();
  }

  /**
   * 系统深浅色变化回调（由 DefaultAbility.onConfigurationUpdate 调用）。
   * 仅 system 态下生效：setColorMode 写死 light/dark 后系统变化不会再触发配置更新。
   */
  static onSystemColorModeChanged(colorMode: ConfigurationConstant.ColorMode): void {
    if (ThemeManager.currentMode !== 'system') {
      return;
    }
    AppStorage.setOrCreate(EFFECTIVE_DARK_KEY, colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
  }

  /**
   * 解析当前生效的深浅色：dark 强制 true、light 强制 false、system 读系统 colorMode。
   */
  private static resolveEffectiveDark(): boolean {
    if (ThemeManager.currentMode === 'dark') {
      return true;
    }
    if (ThemeManager.currentMode === 'light') {
      return false;
    }
    return ThemeManager.readSystemDark();
  }

  /**
   * 读取系统当前深浅色；上下文缺失或异常兜底 false（浅色）。
   */
  private static readSystemDark(): boolean {
    try {
      if (ThemeManager.appContext === undefined) {
        return false;
      }
      const uiCtx: common.UIAbilityContext = ThemeManager.appContext as common.UIAbilityContext;
      return uiCtx.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    } catch (e) {
      return false;
    }
  }

  /**
   * 按当前模式调用 ApplicationContext.setColorMode，失败记录 hilog。
   */
  private static applyColorMode(): void {
    try {
      if (ThemeManager.appContext === undefined) {
        return;
      }
      ThemeManager.appContext.getApplicationContext().setColorMode(COLOR_MODE[ThemeManager.currentMode]);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
  }
}

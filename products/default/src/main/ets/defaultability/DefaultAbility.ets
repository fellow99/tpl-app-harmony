import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import * as wxopensdk from '@tencent/wechat_open_sdk';
import { StorageService } from '../service/StorageService';
import { WechatService } from '../service/WechatService';
import { WechatAuthBus } from '../service/WechatAuthBus';
import { I18n } from '../utils/I18n';
import { ThemeManager } from '../utils/ThemeManager';

const DOMAIN = 0x0000;

/**
 * 应用入口 Ability。
 *
 * 微信登录接入：实现 WXApiEventHandler（onReq/onResp），在 onCreate（冷启动）与
 * onNewWant（热启动返回）中调用 WechatService.handleWant 接收微信回调；
 * 在 onResp 中解析 SendAuthResp 的 code，经 WechatAuthBus 派发给登录/绑定页面。
 */
export default class DefaultAbility extends UIAbility implements wxopensdk.WXApiEventHandler {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 初始化本地存储，供登录态/语言/主题持久化使用
    StorageService.init(this.context);
    // 恢复上次选择的语言（未选择过则跟随系统）
    I18n.applySavedLocale();
    // 恢复上次选择的主题（未选择过则跟随系统），并应用 setColorMode
    ThemeManager.applySavedTheme(this.context);
    // 冷启动：由微信拉起本 App 时，接收微信回调
    WechatService.handleWant(want, this);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    // 颜色模式变化（仅 system 态下会触发，写死 light/dark 后不再通知），驱动登录页按钮图标联动
    const colorMode: ConfigurationConstant.ColorMode | undefined = newConfig.colorMode;
    if (colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ||
      colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      ThemeManager.onSystemColorModeChanged(colorMode);
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 热启动：从微信返回本 App 时，接收微信回调
    WechatService.handleWant(want, this);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onNewWant');
  }

  onReq(req: wxopensdk.BaseReq): void {
    // 从微信启动 App（如开放标签 LaunchFromWXReq）——当前仅支持授权登录，暂不处理
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'WeChat onReq');
  }

  onResp(resp: wxopensdk.BaseResp): void {
    // 登录授权回包（SendAuthResp）的 type 为 1（参考官方示例判断）
    if (resp.type === 1) {
      const authResp: wxopensdk.SendAuthResp = resp as wxopensdk.SendAuthResp;
      if (authResp.errCode === wxopensdk.ErrCode.ERR_OK) {
        WechatAuthBus.dispatch(authResp.code ?? '', authResp.state ?? '');
      } else {
        hilog.warn(DOMAIN, 'testTag', 'WeChat auth resp errCode: %{public}d', authResp.errCode);
      }
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}

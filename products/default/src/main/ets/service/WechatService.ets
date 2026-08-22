import * as wxopensdk from '@tencent/wechat_open_sdk';
import { common, Want } from '@kit.AbilityKit';
import { WECHAT_APP_ID, WECHAT_SCOPE } from '../constants/WechatConstants';

/**
 * 微信 OpenSDK（@tencent/wechat_open_sdk）封装。
 *
 * ⚠️ SDK 类型签名说明（供 Review 参考）：本文件基于微信开放平台官方《鸿蒙应用开发手册》
 * 的文档 API 编写。SDK 在当前环境未安装、无法读取实际 .d.ts，个别类型/签名存在不确定性：
 *   - 工厂方法官方文档为 `wxopensdk.WXAPIFactory.createWXAPI(appId)`（仅传 AppID，不传 context）；
 *     若实际签名为 `createWXAPI(context, appId)`，请按实际 .d.ts 调整。
 *   - 实例类型官方文档描述为「WXApi（第三方 app 与微信通信的 openApi 接口）」，此处以
 *     `wxopensdk.WXApi` 作为类型名；若实际导出名为 `IWXAPI`，请调整。
 *   - `sendReq(context, req)` 需要传入 UIAbilityContext，返回 Promise<boolean>（是否成功跳转）。
 */
export class WechatService {
  private static wxApi: wxopensdk.WXApi | undefined = undefined;

  /** 获取（懒加载）WXApi 实例。 */
  private static getWxApi(): wxopensdk.WXApi {
    if (WechatService.wxApi === undefined) {
      // 必须传移动应用 AppID（勿传小程序 AppID）
      WechatService.wxApi = wxopensdk.WXAPIFactory.createWXAPI(WECHAT_APP_ID);
    }
    return WechatService.wxApi;
  }

  /** 处理来自微信的回调（在 UIAbility onCreate/onNewWant 中调用）。 */
  static handleWant(want: Want, handler: wxopensdk.WXApiEventHandler): void {
    WechatService.getWxApi().handleWant(want, handler);
  }

  /** 拉起微信授权登录（scope=snsapi_userinfo）；返回是否成功跳转微信。 */
  static async sendAuthReq(context: common.UIAbilityContext, state: string): Promise<boolean> {
    const req: wxopensdk.SendAuthReq = new wxopensdk.SendAuthReq();
    req.scope = WECHAT_SCOPE; // 只能填 snsapi_userinfo
    req.state = state;
    return WechatService.getWxApi().sendReq(context, req);
  }
}

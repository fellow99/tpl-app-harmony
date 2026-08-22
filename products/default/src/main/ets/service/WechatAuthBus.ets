/**
 * 微信授权回调总线。
 *
 * UIAbility（DefaultAbility）在 onResp 中拿到 SendAuthResp 的 code/state 后，
 * 通过本总线派发给「当前等待授权回调的页面」（登录页或个人中心绑定页）。
 *
 * 设计为单槽位：同一时刻只有一个页面在等待微信授权回调；dispatch 一次性消费，
 * 避免页面销毁后回调残留导致误派发。
 */
export type WechatAuthCallback = (code: string, state: string) => void;

export class WechatAuthBus {
  private static handler: WechatAuthCallback | undefined = undefined;

  /** 注册等待授权回调的处理函数（页面发起 sendReq 前调用）。 */
  static register(handler: WechatAuthCallback): void {
    WechatAuthBus.handler = handler;
  }

  /** 注销处理函数（页面销毁或回调已消费时调用）。 */
  static unregister(handler: WechatAuthCallback): void {
    if (WechatAuthBus.handler === handler) {
      WechatAuthBus.handler = undefined;
    }
  }

  /** 派发授权回调结果（一次性消费）。 */
  static dispatch(code: string, state: string): void {
    const handler: WechatAuthCallback | undefined = WechatAuthBus.handler;
    WechatAuthBus.handler = undefined;
    if (handler !== undefined) {
      handler(code, state);
    }
  }
}

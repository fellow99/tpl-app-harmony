import BuildProfile from 'BuildProfile';

/**
 * 微信登录相关常量。
 * 编译开关与 AppID 通过 build-profile.json5 的 buildProfileFields 注入，经 BuildProfile 读取
 * （与 ApiConstants.ets 读取 API_BASE_URL 的模式一致）。
 */

/** 微信登录功能开关（debug/release 均默认 true）。 */
export const WECHAT_LOGIN_ENABLED: boolean = BuildProfile.WECHAT_LOGIN_ENABLED;

/**
 * 微信「移动应用」AppID（开放平台创建移动应用并审核通过后获得）。
 * ⚠️ 必须传移动应用 AppID，传小程序 AppID 会导致「第三方应用信息校验失败」。
 */
export const WECHAT_APP_ID: string = BuildProfile.WECHAT_APP_ID;

/** 移动应用授权 scope：只能填 snsapi_userinfo。 */
export const WECHAT_SCOPE: string = 'snsapi_userinfo';

/** 后端 source：移动应用拉起登录（对齐设计文档 §8.1）。 */
export const WECHAT_SOURCE: string = 'wechat_app';

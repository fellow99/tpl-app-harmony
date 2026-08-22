/**
 * 认证模块数据模型（重新对齐 002-user-auth）。
 * 与后端 tpl-app-api 的 DTO 契约保持一致。
 */

/**
 * 登录请求（统一登录，grantType 区分 password/sms）。
 */
export interface LoginRequest {
  grantType: string;
  phoneNumber: string;
  password?: string;
  smsCode?: string;
  code: string;
  uuid: string;
}

/**
 * 注册请求（手机注册，手机号即用户名）。
 */
export interface RegisterRequest {
  phoneNumber: string;
  password: string;
  smsCode: string;
  code: string;
  uuid: string;
}

/**
 * 登录/注册响应（仅 token）。
 */
export interface LoginResponse {
  access_token: string;
}

/**
 * 社交登录/绑定请求（微信登录 grantType=social）。
 * 对齐后端 SocialLoginBody：source 区分 wechat_open/wechat_app/wechat_xcx。
 */
export interface SocialLoginRequest {
  /** 客户端类型（后端 sys_client），移动端固定 'app' */
  clientId: string;
  /** 授权方式，固定 'social' */
  grantType: string;
  /** 第三方来源，移动端拉起为 'wechat_app' */
  source: string;
  /** 微信授权返回的 code */
  socialCode: string;
  /** 发起授权时生成的 state（防 CSRF） */
  socialState: string;
}

/**
 * 图形验证码响应。
 */
export interface CaptchaResponse {
  captchaEnabled: boolean;
  uuid: string;
  img: string;
}

/**
 * 修改个人信息请求。
 */
export interface UpdateProfileRequest {
  nickName: string;
  email: string;
  birthDate: string;
  code: string;
  uuid: string;
}

/**
 * 修改密码请求。
 */
export interface ChangePasswordRequest {
  oldPassword: string;
  newPassword: string;
  confirmPassword: string;
  smsCode: string;
  code: string;
  uuid: string;
}

import { ApiClient } from './ApiClient';
import {
  LoginRequest,
  RegisterRequest,
  LoginResponse,
  CaptchaResponse,
  UpdateProfileRequest,
  ChangePasswordRequest,
  SocialLoginRequest
} from '../model/AuthModels';
import { UserInfo } from '../model/UserInfo';
import {
  API_CAPTCHA,
  API_LOGIN,
  API_REGISTER,
  API_LOGOUT,
  API_USER_INFO,
  API_IS_EMPTY_PASSWORD,
  API_SMS_CODE,
  API_UPDATE_PROFILE,
  API_CHANGE_PASSWORD,
  API_SOCIAL_CALLBACK
} from '../constants/ApiConstants';

/**
 * 认证 API 服务：对接 tpl-app-api 的认证接口。
 */
export class AuthService {
  /** 获取图形验证码。 */
  static async fetchCaptcha(): Promise<CaptchaResponse> {
    return ApiClient.get<CaptchaResponse>(API_CAPTCHA);
  }

  /** 用户登录（密码 / 短信，加密）。 */
  static async login(req: LoginRequest): Promise<LoginResponse> {
    return ApiClient.post<LoginResponse>(API_LOGIN, req, true);
  }

  /** 用户注册（手机注册 + 自动登录，加密）。 */
  static async register(req: RegisterRequest): Promise<LoginResponse> {
    return ApiClient.post<LoginResponse>(API_REGISTER, req, true);
  }

  /** 微信登录（grantType=social，加密）。 */
  static async socialLogin(req: SocialLoginRequest): Promise<LoginResponse> {
    return ApiClient.post<LoginResponse>(API_LOGIN, req, true);
  }

  /** 绑定微信（需登录态，加密）。 */
  static async socialCallback(req: SocialLoginRequest): Promise<void> {
    await ApiClient.post<Object>(API_SOCIAL_CALLBACK, req, true);
  }

  /** 发送短信验证码。 */
  static async sendSmsCode(phoneNumber: string): Promise<void> {
    await ApiClient.get<Object>(`${API_SMS_CODE}?phoneNumber=${phoneNumber}`);
  }

  /** 退出登录。 */
  static async logout(): Promise<void> {
    const emptyBody: Record<string, string> = {};
    await ApiClient.post<Object>(API_LOGOUT, emptyBody);
  }

  /** 获取当前用户信息（后端 token 续期）。 */
  static async fetchUserInfo(): Promise<UserInfo> {
    return ApiClient.get<UserInfo>(API_USER_INFO);
  }

  /** 判断当前账号是否无密码（微信一键登录自动建号）。 */
  static async isEmptyPassword(): Promise<boolean> {
    return ApiClient.get<boolean>(API_IS_EMPTY_PASSWORD);
  }

  /** 修改个人信息（加密）。 */
  static async updateProfile(req: UpdateProfileRequest): Promise<void> {
    await ApiClient.put<Object>(API_UPDATE_PROFILE, req, true);
  }

  /** 修改密码（加密）。 */
  static async changePassword(req: ChangePasswordRequest): Promise<void> {
    await ApiClient.put<Object>(API_CHANGE_PASSWORD, req, true);
  }
}

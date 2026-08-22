import { AuthService } from '../service/AuthService';
import { StorageService } from '../service/StorageService';
import { LoginRequest, RegisterRequest, LoginResponse, CaptchaResponse, SocialLoginRequest } from '../model/AuthModels';
import { UserInfo } from '../model/UserInfo';

/**
 * 认证状态管理：登录/注册/退出、登录态持久化与恢复。
 */
export class AuthViewModel {
  private static instance: AuthViewModel | undefined = undefined;

  static getInstance(): AuthViewModel {
    if (AuthViewModel.instance === undefined) {
      AuthViewModel.instance = new AuthViewModel();
    }
    return AuthViewModel.instance;
  }

  /**
   * 是否已登录。
   */
  isLoggedIn(): boolean {
    return StorageService.isLoggedIn();
  }

  /**
   * 获取本地缓存的用户信息。
   */
  getUserInfo(): UserInfo | null {
    return StorageService.getUserInfo();
  }

  /**
   * 获取图形验证码。
   */
  async fetchCaptcha(): Promise<CaptchaResponse> {
    return AuthService.fetchCaptcha();
  }

  /**
   * 发送短信验证码。
   */
  async sendSmsCode(phoneNumber: string): Promise<void> {
    await AuthService.sendSmsCode(phoneNumber);
  }

  /**
   * 登录：成功后持久化 Token 并刷新用户信息。
   */
  async login(req: LoginRequest): Promise<void> {
    const resp: LoginResponse = await AuthService.login(req);
    StorageService.saveToken(resp.access_token);
    await this.refreshUserInfo();
  }

  /**
   * 注册：注册即登录，持久化 Token 并刷新用户信息。
   */
  async register(req: RegisterRequest): Promise<void> {
    const resp: LoginResponse = await AuthService.register(req);
    StorageService.saveToken(resp.access_token);
    await this.refreshUserInfo();
  }

  /**
   * 微信登录：成功后持久化 Token 并刷新用户信息。
   */
  async socialLogin(req: SocialLoginRequest): Promise<void> {
    const resp: LoginResponse = await AuthService.socialLogin(req);
    StorageService.saveToken(resp.access_token);
    await this.refreshUserInfo();
  }

  /**
   * 退出登录：清除本地认证状态。
   */
  async logout(): Promise<void> {
    try {
      await AuthService.logout();
    } finally {
      StorageService.clearAll();
    }
  }

  /**
   * 刷新并缓存用户信息。
   */
  async refreshUserInfo(): Promise<void> {
    try {
      const userInfo: UserInfo = await AuthService.fetchUserInfo();
      StorageService.saveUserInfo(userInfo);
    } catch (err) {
      // 获取失败时沿用本地缓存，静默忽略
    }
  }
}

export const authViewModel: AuthViewModel = AuthViewModel.getInstance();

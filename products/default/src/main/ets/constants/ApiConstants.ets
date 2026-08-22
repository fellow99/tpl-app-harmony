import BuildProfile from 'BuildProfile';

/**
 * API 常量：后端服务地址与接口路径。
 * 对接 tpl-app-api（Spring Boot 3.x，Sa-Token 认证）。
 */

/**
 * 后端服务基础地址。
 * 通过 build-profile.json5 的 buildProfileFields 按构建模式注入：
 * - debug：内网地址 http://127.0.0.1:38088
 * - release：公网地址 https://www.example.com
 */
export const BASE_URL: string = BuildProfile.API_BASE_URL;

/**
 * 接口路径。
 */
export const API_CAPTCHA: string = '/auth/code';
export const API_LOGIN: string = '/auth/login';
export const API_REGISTER: string = '/auth/register';
export const API_LOGOUT: string = '/auth/logout';
export const API_SOCIAL_CALLBACK: string = '/auth/social/callback';
export const API_USER_INFO: string = '/system/user/getInfo';
export const API_IS_EMPTY_PASSWORD: string = '/system/user/isEmptyPassword';
export const API_UPDATE_PROFILE: string = '/system/user/profile';
export const API_CHANGE_PASSWORD: string = '/system/user/password';
export const API_SMS_CODE: string = '/resource/sms/code';

/**
 * 请求头常量。
 */
export const HEADER_CONTENT_TYPE: string = 'Content-Type';
export const HEADER_AUTHORIZATION: string = 'Authorization';
export const HEADER_CLIENT_ID: string = 'clientid';
export const HEADER_ENCRYPT_KEY: string = 'encrypt-key';
export const CONTENT_TYPE_JSON: string = 'application/json';
export const CLIENT_ID_VALUE: string = 'app';

/**
 * 请求超时时间（毫秒）。
 */
export const HTTP_TIMEOUT: number = 15000;

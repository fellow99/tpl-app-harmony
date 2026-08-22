import { http } from '@kit.NetworkKit';
import { ApiResponse } from '../model/ApiResponse';
import { StorageService } from './StorageService';
import { CryptoUtil } from '../utils/CryptoUtil';
import {
  BASE_URL,
  HTTP_TIMEOUT,
  HEADER_CONTENT_TYPE,
  HEADER_AUTHORIZATION,
  HEADER_CLIENT_ID,
  HEADER_ENCRYPT_KEY,
  CONTENT_TYPE_JSON,
  CLIENT_ID_VALUE
} from '../constants/ApiConstants';

/**
 * API 异常，携带后端业务状态码。
 * message 为 i18n key（点号），展示层需经 I18n.t 解析为本地化文案。
 */
export class ApiError extends Error {
  /** 业务状态码；-1 表示网络层错误 */
  code: number;

  constructor(code: number, message: string) {
    super(message);
    this.name = 'ApiError';
    this.code = code;
  }
}

/**
 * HTTP 客户端封装（基于 @ohos.net.http）。
 * 统一处理请求头注入（Token）、AES+RSA 加密、JSON 序列化、响应解析与错误处理。
 */
export class ApiClient {
  private static httpRequest: http.HttpRequest = http.createHttp();

  /** 发送 GET 请求，返回业务数据。 */
  static async get<T>(path: string): Promise<T> {
    return ApiClient.request<T>(http.RequestMethod.GET, path, undefined, false);
  }

  /** 发送 POST 请求，返回业务数据。 */
  static async post<T>(path: string, body: object, isEncrypt: boolean = false): Promise<T> {
    return ApiClient.request<T>(http.RequestMethod.POST, path, body, isEncrypt);
  }

  /** 发送 PUT 请求，返回业务数据。 */
  static async put<T>(path: string, body: object, isEncrypt: boolean = false): Promise<T> {
    return ApiClient.request<T>(http.RequestMethod.PUT, path, body, isEncrypt);
  }

  private static async request<T>(
    method: http.RequestMethod,
    path: string,
    body?: object,
    isEncrypt: boolean = false
  ): Promise<T> {
    const url: string = BASE_URL + path;
    const token: string = StorageService.getToken();

    const header: Record<string, string> = {};
    header[HEADER_CONTENT_TYPE] = CONTENT_TYPE_JSON;
    header[HEADER_CLIENT_ID] = CLIENT_ID_VALUE;
    if (token !== '') {
      // 后端 Sa-Token 未配置 token-prefix，直接以原始 token 作为 Authorization 值（统一裸 token）
      header[HEADER_AUTHORIZATION] = token;
    }

    let payload: string | undefined = body !== undefined ? JSON.stringify(body) : undefined;

    // AES+RSA 混合加密：加密请求体 + 写入 encrypt-key 头
    if (isEncrypt && body !== undefined) {
      const aesKeyHex: string = CryptoUtil.generateAesKeyHex();
      const encryptedBody: string = await CryptoUtil.aesEncrypt(JSON.stringify(body), aesKeyHex);
      const aesKeyBase64: string = CryptoUtil.base64Encode(aesKeyHex);
      const encryptKey: string = await CryptoUtil.rsaEncrypt(aesKeyBase64);
      header[HEADER_ENCRYPT_KEY] = encryptKey;
      payload = encryptedBody;
    }

    const options: http.HttpRequestOptions = {
      method: method,
      header: header,
      expectDataType: http.HttpDataType.STRING,
      connectTimeout: HTTP_TIMEOUT,
      readTimeout: HTTP_TIMEOUT,
      extraData: payload
    };

    try {
      const response: http.HttpResponse = await ApiClient.httpRequest.request(url, options);
      if (response.responseCode !== 200) {
        if (response.responseCode === 401) {
          StorageService.clearAll();
          throw new ApiError(401, 'message.error.unauthorized');
        }
        throw new ApiError(response.responseCode, 'message.error.requestFailed');
      }
      const result: string = response.result as string;
      const parsed: ApiResponse<T> = JSON.parse(result) as ApiResponse<T>;
      if (parsed.code !== 200) {
        if (parsed.code === 401) {
          StorageService.clearAll();
          throw new ApiError(401, 'message.error.unauthorized');
        }
        // 后端返回的 msg 为 i18n key（点号），原样透传，由展示层经 I18n 解析
        throw new ApiError(parsed.code, parsed.msg !== '' ? parsed.msg : 'message.error.requestFailed');
      }
      return parsed.data;
    } catch (err) {
      if (err instanceof ApiError) {
        throw err;
      }
      throw new ApiError(-1, 'message.error.network');
    }
  }
}

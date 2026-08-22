/**
 * 后端统一响应模型。
 * 对应 tpl-app-api 的 R<T>（code=200 表示成功）。
 */
export interface ApiResponse<T> {
  /** 状态码，200 表示成功 */
  code: number;
  /** 响应消息 */
  msg: string;
  /** 业务数据 */
  data: T;
}

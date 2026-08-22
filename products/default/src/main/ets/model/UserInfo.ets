/**
 * 用户信息模型（对应后端 UserInfoVO，不含 password）。
 */
export interface UserInfo {
  /** 用户 ID */
  userId: number;
  /** 用户名（即手机号） */
  userName: string;
  /** 昵称 */
  nickName: string;
  /** 手机号 */
  phoneNumber: string;
  /** 邮箱 */
  email: string;
  /** 出生日期（YYYY-MM-DD） */
  birthDate: string;
}

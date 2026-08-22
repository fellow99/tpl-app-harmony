# 数据模型 (overall-data-model)

> 项目：tpl-app-harmony（tpl-workspace 鸿蒙App端）
> 版本：v1.0.0
> 最后更新：2026-08-12

---

## 一、说明

本文档定义 tpl-app-harmony 前端应用中的数据模型。后端数据库设计参见 `../docs/数据模型设计.md`。

前端数据模型分为两类：
1. **API 数据模型**：与后端接口交互的数据结构
2. **本地状态模型**：前端组件内部和跨页面共享的状态

---

## 二、API 数据模型

### 2.1 通用响应模型

```typescript
// 后端统一响应格式（参考 tpl-app-web 的 ApiResponse<T>）
interface ApiResponse<T> {
  code: number       // 状态码，200 表示成功
  msg: string        // 响应消息
  data: T            // 业务数据
}
```

### 2.2 认证相关

#### LoginRequest（登录请求）

| 字段 | 类型 | 必填 | 说明 |
|------|------|:--:|------|
| username | string | ✅ | 用户名 |
| password | string | ✅ | 密码（AES 加密后） |
| code | string | ✅ | 图形验证码 |
| uuid | string | ✅ | 验证码唯一标识 |

#### RegisterRequest（注册请求）

| 字段 | 类型 | 必填 | 说明 |
|------|------|:--:|------|
| username | string | ✅ | 用户名 |
| password | string | ✅ | 密码（AES 加密后） |
| code | string | ✅ | 图形验证码 |
| uuid | string | ✅ | 验证码唯一标识 |

#### LoginResponse（登录响应）

| 字段 | 类型 | 说明 |
|------|------|------|
| access_token | string | Sa-Token 认证令牌 |
| expire_in | number | 令牌过期时间（秒） |
| client_id | string | 客户端标识 |

#### CaptchaResponse（验证码响应）

| 字段 | 类型 | 说明 |
|------|------|------|
| uuid | string | 验证码唯一标识 |
| img | string | Base64 编码的验证码图片 |

### 2.3 个人中心


| 字段 | 类型 | 说明 |
|------|------|------|

### 2.4 用户信息

#### UserInfo（用户信息）

| 字段 | 类型 | 说明 |
|------|------|------|
| userId | number | 用户 ID |
| userName | string | 用户名 |
| nickName | string | 昵称 |
| avatar | string | 头像 URL |

---

## 三、本地状态模型

### 3.1 认证状态

```typescript
// 存储键
const STORAGE_KEY_TOKEN = 'auth_token'
const STORAGE_KEY_USER = 'user_info'

// 认证状态
interface AuthState {
  token: string | null        // 认证令牌
  user: UserInfo | null       // 当前用户
  isLoggedIn: boolean         // 是否已登录
}
```

### 3.2 个人中心状态

```typescript
interface ProfileState {
  isLoading: boolean                          // 是否加载中
  error: string | null                        // 错误信息
}
```


| 值 | 标签 | 学段 |
|----|------|------|
| G10 | 高一 | 高中 |
| G11 | 高二 | 高中 |
| G12 | 高三 | 高中 |

---

## 四、状态流转

### 4.1 认证状态机

```
[未登录] ──login() 成功──▶ [已登录]
                              │
                    logout()  │
                              ▼
                          [未登录]
                              │
              token 过期/401   │
                              ▼
                          [未登录]
```

### 4.2 个人中心加载状态

```
[初始化] ──▶ [加载中] ──成功──▶ [已加载]
                │                  │
                │  失败            │  重试
                ▼                  │
            [错误] ────────────────┘

[加载中] ──数据为空──▶ [空状态]
```

---

## 五、参考

| 文档 | 路径 |
|------|------|
| 后端数据模型 | `../docs/数据模型设计.md` |
| Web端 Store 实现 | `../tpl-app-web/src/stores/user.ts` |
| Web端 API 模型 | `../tpl-app-web/src/api/auth.ts` |

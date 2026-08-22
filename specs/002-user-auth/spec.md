# 用户认证规格 (002-user-auth/spec)

> 模块：002-user-auth
> 状态：已实现
> 最后更新：2026-08-16
> 参考：tpl-app-web 对应模块、docs/002-用户注册及登录设计.md
> 父工程规格引用：需求基准见 [../../specs/002-user-auth/spec.md](../../specs/002-user-auth/spec.md)，本文档仅补充本工程（鸿蒙端）特有规格

---

## 1. 模块概述

### 1.1 目的

用户认证模块负责用户的注册和登录功能，是应用的入口门禁。用户通过注册创建账号，通过登录获取认证令牌，从而访问个人中心等需要认证的功能。

### 1.2 解决的问题

- 已有用户通过用户名和密码登录
- 登录状态的保持和退出

### 1.3 范围

**包含（MVP）**：
- 用户注册（用户名 + 密码选择 + 图形验证码）
- 用户登录（用户名 + 密码 + 图形验证码）
- 微信登录（OpenSDK 拉起授权）
- 登录状态保持
- 退出登录

**不包含（本阶段）**：
- 短信验证码登录
- 修改密码
- 个人信息编辑

---

## 2. 用户故事

### US-AUTH-001：新用户注册


**验收标准**：
- 注册表单包含用户名、密码、确认密码选择、图形验证码
- 密码和确认密码不一致时给出即时提示
- 注册成功后提示用户前往登录

### US-AUTH-002：用户登录


**验收标准**：
- 登录表单包含用户名、密码、图形验证码
- 输入错误时显示具体错误提示（如"用户名或密码错误"）
- 登录成功后跳转到个人中心
- 登录失败时验证码自动刷新

### US-AUTH-003：登录状态保持

> 作为已登录用户，我关闭App后再次打开时，不需要重新登录。

**验收标准**：
- 登录成功后 Token 持久化存储
- 再次打开 App 时自动恢复登录状态，直接进入个人中心

### US-AUTH-004：退出登录

> 作为已登录用户，我可以退出当前账号。

**验收标准**：
- 退出后清除本地 Token 和用户信息
- 退出后跳转到登录页
- 无法再访问需要认证的页面

---

## 3. 功能需求

### 3.1 注册

- FR-002-001: 系统 MUST 提供注册页面，包含用户名、密码、确认密码、图形验证码字段
- FR-002-002: 系统 MUST 验证用户名不为空
- FR-002-003: 系统 MUST 验证密码长度不少于 6 位
- FR-002-004: 系统 MUST 在确认密码与密码不一致时给出即时提示
- FR-002-005: 系统 MUST 要求用户必须选择
- FR-002-007: 系统 MUST 在提交前验证所有字段
- FR-002-008: 系统 MUST 调用 POST /auth/register 接口提交注册
- FR-002-009: 系统 MUST 在注册成功后提示用户并跳转到登录页

### 3.2 登录

- FR-002-010: 系统 MUST 提供登录页面，包含用户名、密码、图形验证码字段
- FR-002-011: 系统 MUST 调用 POST /auth/login 接口提交登录
- FR-002-012: 系统 MUST 在登录成功后存储认证令牌
- FR-002-013: 系统 MUST 在登录成功后跳转到个人中心页面
- FR-002-014: 系统 MUST 在登录失败时显示后端返回的错误消息

### 3.3 验证码

- FR-002-015: 系统 MUST 在登录和注册页面加载时获取图形验证码
- FR-002-016: 系统 MUST 提供"点击刷新验证码"功能
- FR-002-017: 系统 MUST 将验证码的 uuid 随表单一起提交

### 3.4 会话管理

- FR-002-018: 系统 MUST 在应用启动时检查本地存储的 Token，自动恢复登录状态
- FR-002-019: 系统 MUST 在退出登录时清除本地 Token 和用户信息
- FR-002-020: 系统 MUST 在退出登录后跳转到登录页

### 3.5 表单体验

- FR-002-021: 系统 SHOULD 在表单字段失焦时进行即时校验
- FR-002-022: 系统 SHOULD 在提交时禁用按钮，防止重复提交
- FR-002-023: 系统 SHOULD 在密码输入框提供显示/隐藏切换

---

## 4. 关键实体

| 实体 | 说明 | 属性 |
|------|------|------|
| LoginForm | 登录表单数据 | username, password, code, uuid |
| AuthToken | 认证令牌 | access_token, expire_in |

---

## 5. 验收场景

### 场景 1：注册成功

- Given：用户在注册页
- Then：注册成功，显示成功提示，2 秒后自动跳转到登录页

### 场景 2：密码不一致

- Given：用户在注册页
- When：用户输入密码为 "123456"，确认密码为 "123457"
- Then：确认密码字段下方显示"两次密码输入不一致"的提示

### 场景 3：登录成功

- Given：用户已有账号，在登录页
- When：用户输入正确的用户名、密码、验证码，点击登录
- Then：登录成功，Token 持久化存储，页面跳转到个人中心

### 场景 4：登录失败

- Given：用户在登录页
- When：用户输入错误的密码，点击登录
- Then：显示"用户名或密码错误"提示，验证码自动刷新

### 场景 5：Token 自动恢复

- Given：用户之前已登录，Token 存储在本地
- When：用户再次打开 App
- Then：自动检测到有效的登录状态，直接进入个人中心

### 场景 6：退出登录

- Given：用户在已登录状态
- When：用户点击退出登录
- Then：清除本地 Token，跳转到登录页，无法再访问个人中心

---

## 6. 非功能性需求

- NFR-AUTH-001: 登录和注册请求的请求体必须加密传输（AES+RSA）
- NFR-AUTH-002: Token 必须安全存储，不可明文暴露
- NFR-AUTH-003: 密码输入框默认掩码显示
- NFR-AUTH-004: 表单布局需适配手机和平板

---

## 7. 假设与约束

| # | 假设 |
|---|------|
| A1 | 后端 tpl-app-api 的认证接口与 tpl-app-web 使用的一致 |
| A2 | 后端使用 Sa-Token 签发 JWT 令牌 |
| A3 | 图形验证码由后端生成并返回 base64 图片 |
| A4 | 加密方案与 tpl-app-web 的 AES+RSA 方案一致 |

---

## 8. 依赖

| 依赖 | 说明 |
|------|------|
| 001-app-shell | 路由导航、本地存储、HTTP 客户端 |
| tpl-app-api | 后端认证接口 |
| D:\tpl-workspace\DESIGN.md | 设计系统（颜色、字体、间距） |
| tpl-app-web | UI 交互参考 |

---

## 微信登录集成

> 需求基准见父工程 [../../specs/002-user-auth/spec.md](../../specs/002-user-auth/spec.md) §11，技术设计见 `docs/002-用户注册及登录设计-微信登录集成.md`（§8.6）。

### 功能需求

- **FR-002-024** 微信登录入口：登录页 MUST 提供「微信登录」按钮，受 `BuildProfile.WECHAT_LOGIN_ENABLED` 控制（默认 `false`）。
- **FR-002-025** 拉起授权：点击微信登录 MUST 通过 `SendAuthReq(scope="snsapi_userinfo")` 经 `WXApi.sendReq(context, req)` 拉起微信。
- **FR-002-026** 回调接收：`DefaultAbility` MUST 实现 `WXApiEventHandler`，在 `onCreate`/`onNewWant` 调用 `WXApi.handleWant`，从 `SendAuthResp` 提取 code/state 并经 `WechatAuthBus` 派发。
- **FR-002-027** 登录：回调 code 后 MUST 调用 `AuthService.socialLogin`（`POST /auth/login` grantType=social，`source=wechat_app`），成功后存储 Token。
- **FR-002-028** 绑定：个人中心 MUST 提供「绑定微信」入口，拉起授权后调用 `POST /auth/social/callback`（需 Token）。

### 关键实现

- 依赖：`@tencent/wechat_open_sdk`（ohpm）。
- 声明：`module.json5` 的 `querySchemes: ["weixin", "wxopensdk"]` + action `wxentity.action.open`。
- 编译开关：`WECHAT_LOGIN_ENABLED` / `WECHAT_APP_ID`（`buildProfileFields`，debug/release 均 `false`）。
- 注意：入口 Ability 为 `DefaultAbility`（非 EntryAbility）；`createWXAPI`/`SendAuthReq` 必须用移动应用 AppID。

---

## 无密码账号（微信一键登录自动建号）

微信一键登录自动建号的账号无密码（`sys_user.password` 为空），鸿蒙端处理：

- **密码登录**：不允许空密码（无密码账号无法密码登录）。
- **修改密码页**：调用 `GET /system/user/isEmptyPassword`；若为无密码账号，隐藏「当前密码」输入框，提交时当前密码传空字符串。

## 验证码开关（禁用验证码）

- tpl-app-api 提供图形验证码开关配置项 captcha.enable。
- captcha.enable: false（禁用）时：后端跳过验证码校验、GET /auth/code 返回 captchaEnabled: false、本端隐藏图形验证码表单项并禁用相关功能。
- 详见父工程需求基准 specs/002-user-auth/spec.md §10。
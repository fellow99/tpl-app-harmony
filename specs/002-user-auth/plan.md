# 用户认证技术方案 (002-user-auth/plan)

> 模块：002-user-auth
> 状态：待实现
> 最后更新：2026-08-12
> 参考：tpl-app-web/src/views/LoginPage.vue, RegisterPage.vue, stores/user.ts

---

## 1. 技术上下文

### 1.1 运行时环境

| 项目 | 值 |
|------|-----|
| 语言 | ArkTS |
| UI 框架 | ArkUI 声明式 |
| 状态管理 | @State + AppStorage |
| HTTP | @ohos.net.http |
| 加密 | @ohos.security.cryptoFramework |
| 本地存储 | @ohos.data.preferences |

### 1.2 对接后端接口

| 接口 | 路径 | 说明 |
|------|------|------|
| 获取验证码 | `GET /auth/code` | 返回 uuid + base64 图片 |
| 用户注册 | `POST /auth/register` | AES+RSA 加密 |
| 用户登录 | `POST /auth/login` | AES+RSA 加密 |
| 退出登录 | `POST /auth/logout` | 需 Token |
| 获取用户信息 | `GET /system/user/getInfo` | 需 Token |

---

## 2. 宪法合规检查

| 原则 | 状态 | 说明 |
|------|:--:|------|
| 代码一致性 | ✅ | 遵循 ArkTS 和项目命名规范 |
| 模块化优先 | — | 认证页面放在 products/default，服务层可复用 |
| 声明式 UI | ✅ | 使用 @Component + @State |
| 类型安全 | ✅ | 表单数据、API 响应均有类型定义 |
| 安全通信 | ✅ | AES+RSA 加密传输 |
| 响应式适配 | ✅ | 使用 BreakpointSystem + GridRow |
| 渐进实现 | ✅ | MVP 阶段只实现密码登录 |

---

## 3. 核心实现设计

### 3.1 页面结构

```
pages/
├── LoginPage.ets        # 登录页面入口
└── RegisterPage.ets     # 注册页面入口

view/
├── LoginForm.ets        # 登录表单组件
└── RegisterForm.ets     # 注册表单组件

viewmodel/
└── AuthViewModel.ets    # 认证状态管理

model/
├── LoginRequest.ets     # 登录请求模型
├── RegisterRequest.ets  # 注册请求模型
└── AuthResponse.ets     # 认证响应模型

service/
├── ApiClient.ets        # HTTP 客户端（在 app-shell 中实现）
└── AuthService.ets      # 认证 API 调用
```

### 3.2 登录页设计

**参考**：tpl-app-web 的 LoginPage.vue

```
┌──────────────────────────┐
│     tpl-workspace              │
│                          │
│  ┌────────────────────┐  │
│  │ 用户名              │  │
│  └────────────────────┘  │
│  ┌────────────────────┐  │
│  │ 密码         [👁]   │  │
│  └────────────────────┘  │
│  ┌──────────┐ ┌───────┐ │
│  │ 验证码    │ │ [图片] │ │
│  └──────────┘ └───────┘ │
│                          │
│  [      登  录      ]    │
│                          │
│  还没有账号？立即注册 →   │
└──────────────────────────┘
```

### 3.3 注册页设计

**参考**：tpl-app-web 的 RegisterPage.vue

```
┌──────────────────────────┐
│     创建账号              │
│                          │
│  用户名                  │
│  ┌────────────────────┐  │
│  └────────────────────┘  │
│  密码                    │
│  ┌────────────────────┐  │
│  └────────────────────┘  │
│  确认密码                │
│  ┌────────────────────┐  │
│  └────────────────────┘  │
│  ┌────────────────────┐  │
│  │   小学：G1 G2 ...   │  │
│  │   初中：G7 G8 G9    │  │
│  │   高中：G10 G11 G12 │  │
│  └────────────────────┘  │
│  验证码                  │
│  ┌──────────┐ ┌───────┐ │
│  │          │ │ [图片] │ │
│  └──────────┘ └───────┘ │
│                          │
│  [      注  册      ]    │
│                          │
│  已有账号？去登录 →       │
└──────────────────────────┘
```

### 3.4 路由流程

```
应用启动
  │
  ▼
检查本地 Token
  │
  ├── 有 Token → 直接进入个人中心
  │
  └── 无 Token → 显示登录页
                   │
                   ├── [立即注册] → 注册页
                   │                  │ 注册成功
                   │                  └──→ 登录页
                   │
                   └── [登录] → 个人中心
                                  │
                                  └── [退出] → 登录页
```

### 3.5 状态管理

```typescript
// AuthViewModel 状态
@State username: string = ''
@State password: string = ''
@State confirmPassword: string = ''
@State captchaCode: string = ''
@State captchaUuid: string = ''
@State captchaImage: string = ''  // base64
@State isLoading: boolean = false
@State errorMessage: string = ''

// 认证 Token 存储
// 使用 preferences 存储，AppStorage 中维护 isLoggedIn 标志
```

### 3.6 加密实现

登录和注册请求体加密（参考 tpl-app-web 方案）：
1. 获取 RSA 公钥
2. 生成随机 AES 密钥
3. 用 AES 加密请求体 JSON
4. 用 RSA 公钥加密 AES 密钥
5. 发送：`{ encryptedData, encryptedKey }`

使用 `@ohos.security.cryptoFramework` 实现。

---

## 4. 文件清单

| 文件 | 用途 | 状态 |
|------|------|:--:|
| `pages/LoginPage.ets` | 登录页面 | 待创建 |
| `pages/RegisterPage.ets` | 注册页面 | 待创建 |
| `view/LoginForm.ets` | 登录表单 | 待创建 |
| `view/RegisterForm.ets` | 注册表单 | 待创建 |
| `viewmodel/AuthViewModel.ets` | 认证状态 | 待创建 |
| `model/AuthModels.ets` | 请求/响应模型 | 待创建 |
| `service/AuthService.ets` | 认证 API | 待创建 |

---

## 5. 测试要点

- 表单字段空值校验
- 密码长度校验（≥ 6 位）
- 确认密码一致性校验
- 登录失败错误提示
- 登录成功跳转
- 注册成功跳转
- Token 持久化和恢复
- 退出登录清除状态

---

## 微信登录实现（OpenSDK 拉起）

> 详见父工程 [../../specs/002-user-auth/plan.md](../../specs/002-user-auth/plan.md) §9 与 `docs/002-用户注册及登录设计-微信登录集成.md`（§8.6）。

- 依赖：`@tencent/wechat_open_sdk`（ohpm）。
- 新增：`service/WechatService.ets`、`service/WechatAuthBus.ets`、`constants/WechatConstants.ets`。
- 声明：`module.json5` `querySchemes: ["weixin","wxopensdk"]` + action `wxentity.action.open`。
- Ability：`DefaultAbility` 实现 `WXApiEventHandler`，`onCreate`/`onNewWant` 调 `handleWant`，`onResp` 取 code 经 `WechatAuthBus` 派发。
- 流程：`SendAuthReq(scope=snsapi_userinfo)` → `sendReq(context, req)` → `AuthService.socialLogin(source=wechat_app)`；个人中心「绑定微信」→ `POST /auth/social/callback`。
- 编译开关：`WECHAT_LOGIN_ENABLED`/`WECHAT_APP_ID`（`buildProfileFields`）。

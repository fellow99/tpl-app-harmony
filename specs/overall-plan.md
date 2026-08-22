# 整体技术方案 (overall-plan)

> 项目：tpl-app-harmony（tpl-workspace 鸿蒙App端）
> 版本：v1.0.0
> 状态：脚手架阶段
> 最后更新：2026-08-12

---

## 一、技术上下文

### 1.1 运行时环境

| 项目 | 值 |
|------|-----|
| 操作系统 | HarmonyOS |
| API 级别 | 5.1(19) ~ 6.1(23) |
| 运行时 | ArkTS (ETS) |
| 构建系统 | Hvigor 6.1.0 |
| 开发工具 | DevEco Studio |
| 包管理器 | ohpm |

### 1.2 关键依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| `@kit.AbilityKit` | 内置 | UIAbility 生命周期 |
| `@kit.ArkUI` | 内置 | 声明式 UI 框架、路由导航 |
| `@kit.PerformanceAnalysisKit` | 内置 | hilog 日志 |
| `@ohos/hypium` | 1.0.25 | 单元测试框架 |
| `@ohos/hamock` | 1.0.0 | Mock 测试框架 |

---

## 二、宪法合规检查

| 原则 | 状态 | 说明 |
|------|:--:|------|
| 代码一致性 | ✅ | 已定义统一的命名和代码风格规范 |
| 模块化优先 | ✅ | 采用 HAP + HAR + HSP 分层架构 |
| 声明式 UI | ✅ | 全部使用 ArkUI `@Component` + `@Builder` |
| 类型安全 | ✅ | 启用 `strictMode`，禁用 `any` |
| 安全通信 | ⚠️ | 加密传输模块待实现（计划使用 `cryptoFramework`） |
| 响应式适配 | ✅ | 已实现 `BreakpointSystem` 断点系统 |
| 渐进实现 | ✅ | MVP 阶段聚焦三个模块 |
| 文档驱动 | ✅ | 本文档即文档驱动的产出 |

---

## 三、实现策略

### 3.1 当前阶段（脚手架）

项目当前处于脚手架阶段，已完成：
- 多模块项目结构搭建（1 HAP + 3 HAR）
- 公共工具模块（Logger、BreakpointSystem）
- 页面路由框架（4 个 demo 页面）
- 响应式布局基础能力

### 3.2 MVP 阶段（待实现）

按以下优先级实现业务功能：

```
Phase 1: 应用脚手架改造（001-app-shell）
  - 将 demo 页面替换为业务首页
  - 实现 HTTP 客户端封装
  - 实现本地存储（Token、用户信息）
  - 实现路由守卫

Phase 2: 用户认证（002-user-auth）
  - 实现登录页面
  - 实现注册页面
  - 对接后端 /auth/login、/auth/register 接口

Phase 3: 个人中心（101-profile）
  - 实现个人中心首页
```

### 3.3 模块目录规划

业务模块将按以下结构组织（参考 tpl-app-web 的模块划分）：

```
products/default/src/main/ets/
├── defaultability/        # 应用入口
├── pages/                 # 页面
│   ├── Index.ets          #   首页（路由分发）
│   ├── LoginPage.ets      #   登录页 [规划]
│   ├── RegisterPage.ets   #   注册页 [规划]
│   └── ProfilePage.ets  # 个人中心 [规划]
├── view/                  # 视图组件
│   ├── LoginForm.ets      #   登录表单 [规划]
│   ├── RegisterForm.ets   #   注册表单 [规划]
│   └── OverviewCard.ets   #   概览卡片 [规划]
├── viewmodel/             # 视图模型
│   ├── AuthViewModel.ets  #   认证状态 [规划]
│   └── ProfileViewModel.ets  # 个人中心状态 [规划]
├── model/                 # 数据模型 [规划]
│   ├── User.ets
├── service/               # API 服务 [规划]
│   ├── ApiClient.ets      #   HTTP 客户端
│   ├── AuthService.ets    #   认证服务
│   └── ProfileService.ets  # 个人中心服务
└── constants/             # 常量
    ├── ApiConstants.ets   #   API 地址 [规划]
    └── RouteConstants.ets #   路由路径
```

---

## 四、技术实现要点

### 4.1 HTTP 客户端

使用 `@ohos.net.http` 封装请求库，参考 tpl-app-web 的 Axios 实现：
- 请求拦截：注入 Token（从本地存储读取）
- 响应拦截：统一错误处理、401 跳转登录
- Base URL 配置

### 4.2 本地存储

使用 `@ohos.data.preferences` 存储：
- 认证令牌（Token）
- 用户基本信息

不使用明文存储密码。

### 4.3 路由守卫

利用 ArkUI Router API 的拦截能力或手动在页面 `aboutToAppear` 中检查登录状态：

```typescript
// 伪代码
aboutToAppear() {
  if (!AuthService.isLoggedIn()) {
    router.replaceUrl({ url: 'pages/LoginPage' })
  }
}
```

### 4.4 加密传输

参考 tpl-app-web 的 AES+RSA 加密方案，使用鸿蒙 `@ohos.security.cryptoFramework` 实现：
- 登录/注册请求体 AES 加密
- AES 密钥 RSA 加密传输

---

## 五、测试策略

| 层级 | 工具 | 范围 |
|------|------|------|
| 单元测试 | Hypium | 工具函数、数据模型、ViewModel 逻辑 |
| UI 测试 | 人工 + 模拟器 | 页面交互、表单验证、路由跳转 |
| 集成测试 | 人工 | 与后端 API 联调 |

---

## 六、部署策略

1. 使用 DevEco Studio 构建 HAP 包
2. 通过调试模式安装到模拟器/真机
3. 生产环境通过 AppGallery Connect 分发

---

## 七、参考文档

| 文档 | 路径 |
|------|------|
| 产品设计 | `../docs/产品概念设计.md` |
| 用户模块设计 | `../docs/002-用户注册及登录设计.md` |
| 个人中心设计 | `../docs/101-个人中心.md` |
| 数据模型设计 | `../docs/数据模型设计.md` |
| 设计系统 | `../DESIGN.md` |
| Web前端参考 | `../tpl-app-web/specs/` |

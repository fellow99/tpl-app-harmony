# tpl-app-harmony

> tpl-workspace鸿蒙App端 — 用户移动客户端

[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-5.1~6.1-FF6A00?logo=harmonyos)](./build-profile.json5)
[![ArkTS](https://img.shields.io/badge/ArkTS-6.1.0-3178C6?logo=typescript)](./oh-package.json5)
[![Hvigor](https://img.shields.io/badge/Hvigor-6.1-646CFF?logo=huawei)](./hvigor/hvigor-config.json5)
[![Hypium](https://img.shields.io/badge/Hypium-1.0.25-8B0000?logo=junit5)](./oh-package.json5)

---

## 项目简介


### tpl-workspace产品体系

```
tpl-workspace/
├── tpl-app-web/          # 用户端 Web 应用 (Vue 3)
├── tpl-app-api/          # 核心业务后端 (Spring Boot 3.x)
├── tpl-manage/           # 管理后台后端 (RuoYi-Vue-Plus)
├── tpl-manage-ui/        # 管理后台前端 (RuoYi-Vue-Plus-UI)
├── tpl-app-android/      # Android 客户端
├── tpl-app-harmony/      # 鸿蒙客户端 ★ 本仓库
├── tpl-app-mini/         # 微信小程序
└── docs/                # 产品文档与设计稿
```


**本工程定位**：为用户提供鸿蒙原生 App，实现用户注册、密码登录、个人中心仪表盘等核心功能。

---

## 架构特点

### HAP + HAR + HSP 多模块架构

采用 HarmonyOS 推荐的模块化分层架构：

```
products/default (HAP — 可独立运行的产品入口)
    │
    ├── @ohos/common (HAR — 公共工具静态库)
    │   ├── Logger.ets          # 日志工具
    │   ├── BreakpointSystem    # 断点响应式系统
    │   └── CommonConstants     # 公共常量
    │
    ├── @ohos/adaptivelayout (HAR — 自适应布局)
    │   └── AdaptiveLayout.ets  # 自适应布局演示
    │
    └── @ohos/responsivelayout (HAR — 响应式布局)
        └── ResponsiveLayout.ets  # 响应式布局演示
```

| 模块 | 类型 | 用途 |
|------|:--:|------|
| `products/default/` | HAP | 应用入口，页面、视图、ViewModel、Service |
| `common/` | HAR | 跨模块共享工具（Logger、BreakpointSystem） |
| `features/adaptiveLayout/` | HAR | 自适应布局演示模块 |
| `features/responsiveLayout/` | HAR | 响应式布局演示模块（Tabs + Grid） |

### 模块通信

- **页面导航**：通过 `UIContext.getRouter().pushUrl()` 进行路由跳转
- **全局状态**：`AppStorage` 共享断点信息，组件通过 `@StorageLink` 订阅
- **模块导出**：每个 HAR 通过 `Index.ets` 导出公共 API

### 工程依赖关系

```
tpl-app-harmony (本工程)
    │
    │ HTTPS REST API
    ▼
tpl-app-api (核心业务后端)
    │
    ├── Sa-Token 认证 (JWT)
    ├── 用户注册/登录接口
    └── 个人中心数据接口
```

---

## 快速开始

```bash
# 1. 使用 DevEco Studio 打开项目
#    File → Open → 选择 tpl-app-harmony 目录

# 2. 等待 IDE 自动安装依赖（ohpm install）

# 3. 选择运行设备（模拟器或真机）
#    Run → Run 'default'

# 4. 构建 HAP 包
#    Build → Build HAP(s)
```

> **注意**：运行前确保 tpl-app-api 后端服务已启动（默认 `localhost:8082`）。前端将通过 API 配置连接后端服务。

---

## 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| 操作系统 | HarmonyOS | API 5.1(19) ~ 6.1(23) |
| 开发语言 | ArkTS (TypeScript 超集) | — |
| UI 框架 | ArkUI 声明式 | — |
| 构建系统 | Hvigor | 6.1.0 |
| 包管理器 | ohpm | — |
| 单元测试 | Hypium | 1.0.25 |
| Mock 框架 | Hamock | 1.0.0 |
| 日志 | hilog (@kit.PerformanceAnalysisKit) | — |
| 路由 | Router API (@kit.ArkUI) | — |
| 响应式 | MediaQuery | — |
| IDE | DevEco Studio | — |

完整技术栈说明见 [specs/TECH.md](./specs/TECH.md)。

---

## 项目结构

```
tpl-app-harmony/
├── AppScope/                           # 应用全局配置
│   ├── app.json5                       #   bundleName、版本号、图标
│   └── resources/                      #   全局资源
├── build-profile.json5                 # 模块注册、SDK版本、签名配置
├── oh-package.json5                    # 根包依赖声明
├── products/
│   └── default/                        # ★ 默认产品入口 (HAP)
│       ├── src/main/ets/
│       │   ├── defaultability/         #   UIAbility 入口
│       │   │   └── DefaultAbility.ets  #     应用生命周期管理
│       │   ├── pages/                  #   页面
│       │   │   ├── Index.ets           #     首页（目录导航）
│       │   │   ├── LoginPage.ets       #     登录页 [规划]
│       │   │   ├── RegisterPage.ets    #     注册页 [规划]
│       │   │   └── ProfilePage.ets  # 个人中心 [规划]
│       │   ├── view/                   #   视图组件
│       │   │   └── CatalogueListComponent.ets  # 目录列表
│       │   ├── viewmodel/              #   视图模型
│       │   │   ├── CatalogueViewModel.ets
│       │   │   └── CatalogueItemData.ets
│       │   ├── model/                  #   数据模型 [规划]
│       │   ├── service/                #   API 服务 [规划]
│       │   └── constants/              #   常量定义
│       │       ├── RouteConstants.ets  #     路由路径常量
│       │       └── CommonConstants.ets #     UI 常量
│       └── src/ohosTest/               #   自动化测试
├── common/                             # 公共模块 (HAR)
│   ├── Index.ets                       #   模块导出入口
│   └── src/main/ets/utils/
│       ├── Logger.ets                  #   hilog 日志封装
│       └── BreakpointSystem.ets        #   响应式断点系统
├── features/                           # 功能特性模块 (HAR)
│   ├── adaptiveLayout/                 #   自适应布局演示
│   └── responsiveLayout/              #   响应式布局演示
├── specs/                              # 📋 规范文档（19 份）
│   ├── README.md                       #   文档索引
│   ├── ARCHITECTURE.md                 #   系统架构设计
│   ├── STRUCTURE.md                    #   目录结构与路由清单
│   ├── TECH.md                         #   技术选型
│   ├── constitution.md                 #   宪法原则（8 条）
│   ├── overall-spec.md                 #   整体功能规格
│   ├── overall-plan.md                 #   整体技术方案
│   ├── overall-data-model.md           #   数据模型
│   ├── overall-api.md                  #   API 接口模型
│   ├── overall-test-cases.md           #   测试用例索引
│   ├── SPECS_CHECKLIST.md              #   规格完成度追踪
│   ├── 001-app-shell/                  #   ⭐ 应用脚手架模块
│   ├── 002-user-auth/                  #   ⭐ 用户认证模块
│   └── 101-profile/            #   ⭐ 个人中心模块
├── hvigor/                             # Hvigor 构建配置
└── README.md                           # 本文件
```

---

## 功能模块

### 当前状态

项目处于**脚手架阶段**，已完成基础架构搭建：

| 模块 | 说明 | 状态 |
|------|------|:--:|
| **001-app-shell** | 应用入口 Ability、多模块架构、路由导航、响应式断点系统 | ✅ 已搭建 |

### 模块详情

#### 001-app-shell（✅ 已实现）

| 组件 | 说明 |
|------|------|
| `DefaultAbility` | 应用入口 UIAbility，加载首页 `pages/Index` |
| `BreakpointSystem` | MediaQuery 断点检测（sm/md/lg/xl），写入 AppStorage |
| `Logger` | hilog 封装，统一域名和前缀 |
| `CatalogueListComponent` | 首页功能目录列表（GridRow + ForEach） |

规格文档：[specs/001-app-shell/](./specs/001-app-shell/)

#### 002-user-auth（📋 已规划）

对接 tpl-app-api 后端接口，实现：
- 用户注册页：用户名 + 密码 + 确认密码 + 图形验证码
- 用户登录页：用户名 + 密码 + 图形验证码
- 登录状态保持（Token 持久化）、退出登录
- AES+RSA 加密传输（与 tpl-app-web 方案一致）

规格文档：[specs/002-user-auth/](./specs/002-user-auth/)

#### 101-profile（📋 已规划）

登录后的首页仪表盘：
- 四状态 UI：加载中 / 错误+重试 / 空数据 / 有数据

规格文档：[specs/101-profile/](./specs/101-profile/)

---

## 开发指南

### MVP 实现优先级

```
Phase 1: 脚手架改造 (001-app-shell)
  ├── 将 demo 首页替换为业务路由分发
  ├── 封装 HTTP 客户端（@ohos.net.http）
  ├── 实现本地存储（@ohos.data.preferences）
  └── 实现路由守卫

Phase 2: 用户认证 (002-user-auth)
  ├── LoginPage.ets   — 密码登录
  ├── RegisterPage.ets — 用户注册
  ├── AuthViewModel   — 认证状态管理
  └── AuthService.ets — API 调用

Phase 3: 个人中心 (101-profile)
  ├── ProfilePage.ets — 仪表盘
  └── ProfileService.ets — API 调用
```

### 新增业务模块

当需要新增模块时，参照 spec 规范：

1. 在 `specs/` 下创建 `NNN-module-name/` 目录
2. 编写 `spec.md`（功能规格）和 `plan.md`（技术方案）
3. 如包含 UI 交互，编写 `test-cases.md`
4. 在 `products/default/src/main/ets/` 下创建对应的 pages/view/viewmodel/service

### 与 Web 端对齐

本工程在模块划分、接口调用、设计规范上全面参照 tpl-app-web：

| 维度 | tpl-app-web | tpl-app-harmony |
|------|-----------|----------------|
| 模块编号 | 001 / 002 / 101 | 001 / 002 / 101 |
| 认证接口 | `POST /auth/login` | 同 |
| 注册接口 | `POST /auth/register` | 同 |
| 设计系统 | `../DESIGN.md` | 同 |
| 加密方案 | AES+RSA | 同（cryptoFramework 实现） |

---

## 相关文档

### 本工程规范文档

| 文档 | 路径 | 说明 |
|------|------|------|
| 规范文档索引 | [specs/README.md](./specs/README.md) | 全部 19 份规范文档导航 |
| 架构设计 | [specs/ARCHITECTURE.md](./specs/ARCHITECTURE.md) | HAP+HAR 分层架构、模块通信 |
| 技术选型 | [specs/TECH.md](./specs/TECH.md) | 鸿蒙技术栈与版本说明 |
| 宪法原则 | [specs/constitution.md](./specs/constitution.md) | 8 条项目开发原则 |
| 整体规格 | [specs/overall-spec.md](./specs/overall-spec.md) | 系统级功能需求与用户故事 |
| 整体方案 | [specs/overall-plan.md](./specs/overall-plan.md) | MVP 三阶段实现策略 |
| API 接口 | [specs/overall-api.md](./specs/overall-api.md) | 与后端 tpl-app-api 接口契约 |
| 数据模型 | [specs/overall-data-model.md](./specs/overall-data-model.md) | API 模型、本地状态、数据字典 |

### 后端工程文档（tpl-app-api）

| 文档 | 路径 | 说明 |
|------|------|------|
| tpl-app-api README | [../tpl-app-api/README.md](../tpl-app-api/README.md) | 后端项目说明（Spring Boot 3.x） |
| tpl-app-api specs | [../tpl-app-api/specs/README.md](../tpl-app-api/specs/README.md) | 后端规范文档索引 |

### 前端参考工程（tpl-app-web）

| 文档 | 路径 | 说明 |
|------|------|------|
| tpl-app-web README | [../tpl-app-web/README.md](../tpl-app-web/README.md) | Web 前端项目说明（Vue 3） |
| tpl-app-web specs | [../tpl-app-web/specs/README.md](../tpl-app-web/specs/README.md) | Web 端规范文档索引（20 份） |
| 用户认证模块 | [../tpl-app-web/specs/002-user-auth/](../tpl-app-web/specs/002-user-auth/) | Web 端认证模块 spec+plan+test-cases |
| 个人中心模块 | [../tpl-app-web/specs/101-profile/](../tpl-app-web/specs/101-profile/) | Web 端个人中心 spec+plan+test-cases |

### 产品与设计文档

| 文档 | 路径 | 说明 |
|------|------|------|
| 产品概念设计 | [../docs/产品概念设计.md](../docs/产品概念设计.md) | 产品整体定位与功能全景 |
| 数据模型设计 | [../docs/数据模型设计.md](../docs/数据模型设计.md) | 数据库表结构、字段、字典 |
| 技术选型 | [../docs/技术选型.md](../docs/技术选型.md) | 全产品线技术栈选型 |
| 用户模块设计 | [../docs/002-用户注册及登录设计.md](../docs/002-用户注册及登录设计.md) | 用户注册/登录接口定义 |
| 个人中心设计 | [../docs/101-个人中心.md](../docs/101-个人中心.md) | 个人中心功能设计 |
| 设计系统 | [../DESIGN.md](../DESIGN.md) | 「破茧」设计系统（Web/Android/HarmonyOS/Mini） |

---

## License

Proprietary. All rights reserved.

# 系统架构 (ARCHITECTURE)

> 项目：tpl-app-harmony（tpl-workspace 鸿蒙App端）
> 生成时间：2026-08-12

---

## 一、整体架构图

```
┌─────────────────────────────────────────────────────────────┐
│                     tpl-app-harmony                           │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              products/default (HAP)                   │   │
│  │                                                       │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌───────────────┐  │   │
│  │  │  Pages      │ │  ViewModels │ │  Constants     │  │   │
│  │  │  (页面层)    │ │  (视图模型)  │ │  (常量配置)    │  │   │
│  │  └──────┬──────┘ └──────┬──────┘ └───────────────┘  │   │
│  │         │               │                             │   │
│  │  ┌──────┴───────────────┴───────────────────────┐   │   │
│  │  │              View Components (视图组件)        │   │   │
│  │  └──────────────────────┬───────────────────────┘   │   │
│  └─────────────────────────┼───────────────────────────┘   │
│                            │                                │
│  ┌────────────┐ ┌──────────┴───────┐ ┌──────────────────┐ │
│  │  common    │ │ adaptiveLayout   │ │ responsiveLayout │ │
│  │  (HAR)     │ │ (HSP)            │ │ (HSP)            │ │
│  │            │ │                  │ │                  │ │
│  │ · Logger   │ │ · 自适应布局      │ │ · 响应式布局      │ │
│  │ · Breakpt  │ │ · 滑动组件       │ │ · 网格组件       │ │
│  │ · Constants│ │                  │ │                  │ │
│  └────────────┘ └──────────────────┘ └──────────────────┘ │
│                                                              │
└───────────────────────────┬─────────────────────────────────┘
                            │ HTTPS (REST API)
                            │
              ┌─────────────┴─────────────┐
              │      tpl-app-api            │
              │   (Spring Boot 3.x)        │
              │   后端核心服务              │
              └─────────────────────────────┘
```

---

## 二、分层架构

### 2.1 当前分层（脚手架状态）

| 层 | 目录 | 职责 | 当前文件 |
|----|------|------|----------|
| **页面层** | `pages/` | 页面入口，组装组件和状态 | `Index.ets`、`AdaptiveIndex.ets`、`ResponsiveIndex.ets`、`SystemCapabilitiesIndex.ets` |
| **视图模型层** | `viewmodel/` | 数据管理和页面状态 | `CatalogueViewModel.ets`、`CatalogueItemData.ets` |
| **视图组件层** | `view/` | 可复用的UI组件 | `CatalogueListComponent.ets` |
| **常量层** | `constants/` | 路由路径、UI常量 | `RouteConstants.ets`、`CommonConstants.ets` |
| **能力层** | `defaultability/` | 应用生命周期入口 | `DefaultAbility.ets` |

### 2.2 规划分层（业务开发后）

```
pages/                  # 页面入口
  ├── Index.ets         #   首页（目录导航 → 改为业务首页）
  ├── LoginPage.ets     #   登录页 [规划]
  ├── RegisterPage.ets  #   注册页 [规划]
  ├── ProfilePage.ets   #   个人中心 [规划]
  └── ProfileIndex.ets  # 个人中心 [规划]

viewmodel/              # 视图模型（状态管理）
  ├── AuthViewModel.ets         #   认证状态 [规划]
  ├── ProfileViewModel.ets  # 个人中心状态 [规划]

view/                   # 视图组件
  ├── CatalogueListComponent.ets  #   目录列表（可复用）
  ├── LoginForm.ets              #   登录表单 [规划]
  ├── RegisterForm.ets           #   注册表单 [规划]
  └── OverviewCards.ets          #   概览卡片 [规划]

service/                # 服务层（API调用）[规划]
  ├── ApiClient.ets            #   HTTP客户端封装
  ├── AuthService.ets          #   认证服务
  └── ProfileService.ets #  个人中心服务

model/                  # 数据模型 [规划]
  ├── User.ets                 #   用户模型
  ├── LoginRequest.ets         #   登录请求

constants/              # 常量
  ├── ApiConstants.ets         #   API地址常量 [规划]
  ├── RouteConstants.ets       #   路由常量
  └── CommonConstants.ets      #   UI常量
```

---

## 三、数据流

### 3.1 当前数据流（脚手架）

```
DefaultAbility.onWindowStageCreate()
  → loadContent('pages/Index')
    → Index.build()
      → CatalogueListComponent (Builder)
        → CatalogueViewModel.getCatalogueData()
          → List + ForEach
            → onClick: router.pushUrl(route)
```

### 3.2 规划数据流（业务开发后）

```
用户操作 → Page Component
  → ViewModel (状态管理)
    → Service (HTTP请求)
      → tpl-app-api (后端)
        → PostgreSQL / Redis
      ← 响应数据
    ← 数据模型
  ← UI 更新 (响应式绑定)
```

---

## 四、模块间通信

### 4.1 HAR/HSP 模块通信

```
common 模块导出 → features 和 products 导入

// common/Index.ets
export { Logger } from './src/main/ets/utils/Logger';
export { BreakpointSystem, BreakPointType } from './src/main/ets/utils/BreakpointSystem';

// products/default 中导入
import { BreakpointSystem } from '@ohos/common';
```

### 4.2 页面间通信

- **路由参数**：`router.pushUrl({ url, params })` 传递
- **全局状态**：`AppStorage` 共享（断点信息等）

---

## 五、部署与构建

### 5.1 构建模式

| 模式 | 命令 | 说明 |
|------|------|------|
| Debug | `hvigorw assembleHap --mode module -p product=default -p buildMode=debug` | 开发调试 |
| Release | `hvigorw assembleHap --mode module -p product=default -p buildMode=release` | 生产打包 |

### 5.2 产物

- `products/default/build/default/outputs/default/default-default-signed.hap` — HAP 安装包

---

## 六、关联工程

```
tpl-workspace/
├── tpl-app-harmony/     ← 本工程
│   对接 ↓
├── tpl-app-api/         # 后端 REST API（用户注册/登录、个人中心数据）
│   参考 ↓
├── tpl-app-web/         # Web 前端（模块划分、UI设计参考）
│   参考 ↓
├── docs/               # 产品设计文档
└── README.md           # 项目总说明
```

# 应用脚手架规格 (001-app-shell/spec)

> 模块：001-app-shell
> 状态：已实现（脚手架）
> 最后更新：2026-08-12

---

## 1. 模块概述

### 1.1 目的

应用脚手架是 tpl-app-harmony 的工程基础架构，提供应用启动入口、页面路由导航、公共工具、响应式适配等基础能力。它是所有业务模块运行的容器和框架。

### 1.2 解决的问题

- 应用启动和生命周期管理
- 多页面路由导航
- 跨模块的公共工具共享
- 多设备形态的响应式布局适配
- 统一的代码组织和模块化架构

### 1.3 范围

**包含**：
- 应用入口 Ability 和生命周期
- 页面路由系统
- 公共工具模块（Logger、BreakpointSystem）
- 自适应布局和响应式布局特性模块
- 构建配置和模块依赖管理

**不包含**：
- 任何业务逻辑（认证、个人中心等）
- HTTP 客户端和 API 调用
- 本地存储管理
- 路由守卫

---

## 2. 用户故事

### US-SHELL-001：应用启动

> 作为用户，我可以打开tpl-workspace鸿蒙App并看到首页，以便进入各个功能模块。

**验收标准**：
- 应用冷启动时间在可接受范围内
- 首页正常渲染，无崩溃

### US-SHELL-002：页面导航

> 作为用户，我可以点击首页的功能入口，跳转到对应的功能页面。

**验收标准**：
- 点击功能入口后正确跳转到目标页面
- 页面导航动画流畅

### US-SHELL-003：响应式适配

> 作为用户，无论我用手机（竖屏/横屏）还是平板打开App，界面都能合理布局。

**验收标准**：
- 不同设备宽度下界面布局自动适配
- 断点切换流畅，无明显闪烁

---

## 3. 功能需求

### 3.1 应用入口

- FR-001-001: 系统 MUST 在 `DefaultAbility.onWindowStageCreate` 中加载主页面
- FR-001-002: 系统 MUST 在 `DefaultAbility` 中正确实现生命周期回调（onCreate/onDestroy/onForeground/onBackground）

### 3.2 页面路由

- FR-001-003: 系统 MUST 使用 `UIContext.getRouter().pushUrl()` 进行页面导航
- FR-001-004: 系统 MUST 在 `main_pages.json` 中注册所有页面
- FR-001-005: 系统 SHOULD 将路由路径定义为常量，统一管理于 `RouteConstants.ets`

### 3.3 公共工具

- FR-001-006: 系统 MUST 提供 `Logger` 工具类，封装 hilog 的 debug/info/warn/error 方法
- FR-001-007: 系统 MUST 提供 `BreakpointSystem`，基于 MediaQuery 实现设备断点检测
- FR-001-008: 系统 MUST 提供 `BreakPointType<T>` 泛型类，支持按断点获取不同的配置值

### 3.4 响应式布局

- FR-001-009: 系统 SHOULD 使用 `GridRow`/`GridCol` 实现栅格布局
- FR-001-010: 系统 SHOULD 将断点系统的当前断点发布到 `AppStorage`，供各组件订阅

### 3.5 模块化

- FR-001-011: 系统 MUST 遵循 HAP + HAR + HSP 模块化架构
- FR-001-012: 系统 MUST 将公共模块（common）作为 HAR 静态库，供其他模块依赖
- FR-001-013: 系统 MUST 通过模块的 `Index.ets` 导出公共 API

---

## 4. 关键实体

| 实体 | 说明 | 类型 |
|------|------|------|
| DefaultAbility | 应用入口 UIAbility | 类 |
| BreakpointSystem | 响应式断点管理系统 | 类 |
| BreakPointType<T> | 按断点获取值的泛型类 | 泛型类 |
| Logger | 日志工具类 | 类 |
| CatalogueItemData | 目录列表数据模型 | 类 |

---

## 5. 验收场景

### 场景 1：应用正常启动

- Given：应用已安装到鸿蒙设备
- When：用户点击应用图标
- Then：应用启动，`DefaultAbility` 创建，加载 `pages/Index` 页面成功，首页渲染完成

### 场景 2：页面跳转

- Given：用户在首页
- When：用户点击功能列表中的某一项
- Then：通过 `router.pushUrl()` 跳转到对应页面，页面正常渲染

### 场景 3：断点切换

- Given：应用在手机竖屏状态运行
- When：用户旋转设备到横屏
- Then：`BreakpointSystem` 检测到宽度变化，更新 `AppStorage` 中的断点值，UI 自动适配

---

## 6. 非功能性需求

- NFR-SHELL-001: 应用启动时间 < 2 秒
- NFR-SHELL-002: 页面跳转响应 < 500ms
- NFR-SHELL-003: 断点切换 UI 无闪烁
- NFR-SHELL-004: 代码通过 `code-linter.json5` 中定义的规则检查

---

## 7. 假设与约束

| # | 假设 |
|---|------|
| A1 | 运行设备支持 HarmonyOS API 5.1 ~ 6.1 |
| A2 | 开发使用 DevEco Studio，构建使用 Hvigor |

---

## 8. 依赖

| 依赖 | 说明 |
|------|------|
| `@kit.AbilityKit` | UIAbility 生命周期管理 |
| `@kit.ArkUI` | 声明式 UI 框架、路由、MediaQuery |
| `@kit.PerformanceAnalysisKit` | hilog 日志 |
| `@ohos/hypium` | 单元测试 |

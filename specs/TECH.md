# 技术选型 (TECH)

> 项目：tpl-app-harmony（tpl-workspace 鸿蒙App端）
> 生成时间：2026-08-12

---

## 一、技术栈总览

| 层级 | 技术 | 版本 | 用途 |
|------|------|------|------|
| **操作系统** | HarmonyOS | API 5.1(19) ~ 6.1(23) | 目标运行平台 |
| **开发语言** | ArkTS (TypeScript 超集) | — | 应用主开发语言 |
| **UI 框架** | ArkUI (声明式) | — | 组件化UI构建 |
| **构建工具** | Hvigor | — | 鸿蒙原生构建系统 |
| **包管理** | ohpm | — | 鸿蒙原生包管理 |
| **测试框架** | Hypium | 1.0.25 | 鸿蒙单元测试框架 |
| **Mock 框架** | Hamock | 1.0.0 | 测试 Mock |
| **日志** | hilog | — | 系统日志（`@kit.PerformanceAnalysisKit`） |
| **路由** | Router API | — | 页面导航（`@kit.ArkUI`） |
| **响应式** | MediaQuery | — | 断点响应式布局 |
| **IDE** | DevEco Studio | — | 鸿蒙官方 IDE |

---

## 二、核心技术详解

### 2.1 ArkTS 语言

ArkTS 是 HarmonyOS 生态的 TypeScript 超集，添加了声明式UI语法（`@Entry`、`@Component`、`@State`、`@Builder` 等装饰器）。

**当前代码特点**：
- 使用 `class` 定义数据模型和视图模型
- 使用 `@Builder` 装饰函数组件
- 使用 `@Entry` + `@Component` 定义页面

### 2.2 ArkUI 声明式框架

```typescript
@Entry
@Component
struct MyPage {
  @State message: string = 'Hello';

  build() {
    Column() {
      Text(this.message)
      Button('Click').onClick(() => { /* ... */ })
    }
  }
}
```

**当前使用的组件**：
- `Column`、`Row`、`Stack` — 布局容器
- `GridRow` / `GridCol` — 栅格布局
- `List` / `ListItem` — 列表
- `Text`、`Image`、`Button` — 基础组件
- `SymbolGlyph` — 系统图标

### 2.3 路由导航

当前使用 `UIContext.getRouter().pushUrl()` 进行页面跳转，路由路径定义在 `RouteConstants.ets` 中。

```typescript
uiContext.getRouter().pushUrl({ url: 'pages/ResponsiveIndex' })
```

### 2.4 响应式断点系统

`common` 模块提供 `BreakpointSystem`，基于 `MediaQuery` 监听设备宽度变化：

| 断点 | 宽度范围 | 设备类型 |
|------|----------|----------|
| `sm` | < 600vp | 手机竖屏 |
| `md` | 600vp ~ 840vp | 手机横屏/小平板 |
| `lg` | 840vp ~ 1440vp | 大平板 |
| `xl` | ≥ 1440vp | 大屏/桌面 |

---

## 三、项目模块架构

采用 **HAP (HarmonyOS Ability Package)** 多模块架构：

```
products/default   ← 产品入口（可独立运行）
  ├── common              ← 公共工具（HAR静态库）
  ├── features/adaptiveLayout  ← 功能特性（HSP动态库）
  └── features/responsiveLayout ← 功能特性（HSP动态库）
```

| 模块类型 | 路径 | 类型 | 可独立运行 |
|----------|------|:--:|:--:|
| 产品模块 | `products/default/` | HAP | ✅ |
| 公共模块 | `common/` | HAR | ❌ |
| 功能模块 | `features/adaptiveLayout/` | HSP | ❌ |
| 功能模块 | `features/responsiveLayout/` | HSP | ❌ |

---

## 四、SDK 与 API 版本

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `targetSdkVersion` | 6.1.0(23) | 编译目标 SDK |
| `compatibleSdkVersion` | 5.1.1(19) | 最低兼容 SDK |
| `runtimeOS` | HarmonyOS | 运行时系统 |

---

## 五、依赖清单

### 5.1 直接依赖（根 `oh-package.json5`）

| 包 | 版本 | 说明 |
|----|------|------|
| `@ohos/hypium` | 1.0.25 | 测试框架（dev） |
| `@ohos/hamock` | 1.0.0 | Mock 框架（dev） |

### 5.2 产品模块依赖（`products/default/oh-package.json5`）

| 包 | 来源 | 说明 |
|----|------|------|
| `@ohos/common` | `file:../../common` | 公共工具模块 |
| `@ohos/adaptivelayout` | `file:../../features/adaptiveLayout` | 自适应布局 |
| `@ohos/responsivelayout` | `file:../../features/responsiveLayout` | 响应式布局 |

---

## 六、待引入的依赖（业务开发时）

根据 tpl-app-web 的技术栈和鸿蒙生态，后续业务开发可能需要引入：

| 类别 | 候选方案 | 用途 |
|------|----------|------|
| HTTP 客户端 | `@ohos.net.http` 或 `@ohos/axios` | API 请求 |
| 状态管理 | `@ohos/StateManagement` (V1/V2) | 全局状态 |
| 本地存储 | `@ohos.data.preferences` | 键值存储 |
| 数据持久化 | `@ohos.data.relationalStore` | SQLite 本地数据库 |
| 图片加载 | 自定义或 `@ohos/image` | 图片显示与缓存 |
| 加密 | `@ohos.security.cryptoFramework` | AES/RSA 加密 |
| 微信登录 | `@ohos/wechat` SDK | 第三方登录 |

---

## 七、与 tpl-app-web 技术对照

| 维度 | tpl-app-web (Web端) | tpl-app-harmony (鸿蒙端) |
|------|-------------------|------------------------|
| 语言 | TypeScript + Vue 3 | ArkTS |
| UI 框架 | Element Plus | ArkUI |
| 状态管理 | Pinia | AppStorage / StateManagement |
| 路由 | Vue Router 4 | Router API |
| HTTP | Axios | @ohos.net.http / @ohos/axios |
| 构建 | Vite | Hvigor |
| 包管理 | npm/pnpm | ohpm |
| 加密 | JSEncrypt | cryptoFramework |

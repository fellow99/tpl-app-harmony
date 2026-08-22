# 应用脚手架技术方案 (001-app-shell/plan)

> 模块：001-app-shell
> 状态：已实现（脚手架）
> 最后更新：2026-08-12

---

## 1. 技术上下文

### 1.1 运行时环境

| 项目 | 值 |
|------|-----|
| 运行框架 | HarmonyOS Stage Model |
| 入口类 | `DefaultAbility extends UIAbility` |
| 首页 | `pages/Index` |
| 构建系统 | Hvigor 6.1.0 |

### 1.2 模块依赖

```
products/default (HAP)
  ├── @ohos/common (HAR)          → Logger, BreakpointSystem
  ├── @ohos/adaptivelayout (HAR)  → 自适应布局演示
  └── @ohos/responsivelayout (HAR) → 响应式布局演示

features/adaptiveLayout (HAR)
  └── @ohos/common

features/responsiveLayout (HAR)
  └── @ohos/common
```

---

## 2. 宪法合规检查

| 原则 | 状态 | 说明 |
|------|:--:|------|
| 代码一致性 | ✅ | 已定义统一的命名和代码风格 |
| 模块化优先 | ✅ | HAP + 3 HAR 架构，通过 Index.ets 导出 |
| 声明式 UI | ✅ | 全部使用 @Component + @Builder |
| 类型安全 | ✅ | strictMode 启用，类型注解完整 |
| 响应式适配 | ✅ | BreakpointSystem + GridRow 实现 |
| 安全通信 | — | 脚手架阶段不涉及 |

---

## 3. 核心实现

### 3.1 应用入口

**文件**: `products/default/src/main/ets/defaultability/DefaultAbility.ets`

```typescript
export default class DefaultAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      // 处理加载结果
    });
  }
}
```

通过 `loadContent()` 加载首页 `pages/Index`，由 `main_pages.json` 注册。

### 3.2 页面注册

**文件**: `products/default/src/main/resources/base/profile/main_pages.json`

```json
{
  "src": [
    "pages/Index",
    "pages/AdaptiveIndex",
    "pages/ResponsiveIndex",
    "pages/SystemCapabilitiesIndex"
  ]
}
```

### 3.3 路由导航

**文件**: `products/default/src/main/ets/constants/RouteConstants.ets`

路由路径定义为常量：
- `RESPONSIVE_ROUTE` = `'pages/ResponsiveIndex'`
- `ADAPTIVE_ROUTE` = `'pages/AdaptiveIndex'`
- `SYSTEM_CAPABILITIES_ROUTE` = `'pages/SystemCapabilitiesIndex'`

导航通过 `UIContext.getRouter().pushUrl()` 实现，参数通过 `params` 传递。

### 3.4 断点系统

**文件**: `common/src/main/ets/utils/BreakpointSystem.ets`

| 断点 | 宽度范围 | 
|------|----------|
| sm | < 600vp |
| md | 600vp ~ 840vp |
| lg | 840vp ~ 1320vp |
| xl | ≥ 1320vp |

通过 `MediaQuery` 监听宽度变化，写入 `AppStorage.set('mainBreakpoint', name)`，组件通过 `@StorageLink('mainBreakpoint')` 订阅。

`BreakPointType<T>` 泛型类支持按断点获取配置值：
```typescript
new BreakPointType({ sm: 100, md: 200, lg: 300, xl: 400 })
  .getValue(currentBreakpoint)
```

### 3.5 日志工具

**文件**: `common/src/main/ets/utils/Logger.ets`

封装 `hilog`，提供 `debug()`、`info()`、`warn()`、`error()` 方法，统一 `domain` 和 `prefix`。

### 3.6 首页目录组件

**文件**: `products/default/src/main/ets/view/CatalogueListComponent.ets`

使用 `@Builder` 装饰的函数组件，通过 `GridRow`/`GridCol` 实现响应式栅格布局。列表项使用 `ForEach` 遍历，点击触发路由跳转。

---

## 4. 文件清单

| 文件 | 用途 | 行数 |
|------|------|:--:|
| `products/default/src/main/ets/defaultability/DefaultAbility.ets` | 应用入口 | 48 |
| `products/default/src/main/ets/pages/Index.ets` | 首页 | 17 |
| `products/default/src/main/ets/pages/AdaptiveIndex.ets` | 自适应布局页 | 41 |
| `products/default/src/main/ets/pages/ResponsiveIndex.ets` | 响应式布局页 | 14 |
| `products/default/src/main/ets/pages/SystemCapabilitiesIndex.ets` | 系统能力检测页 | 77 |
| `products/default/src/main/ets/constants/RouteConstants.ets` | 路由常量 | 17 |
| `products/default/src/main/ets/constants/CommonConstants.ets` | UI 常量 | 181 |
| `products/default/src/main/ets/view/CatalogueListComponent.ets` | 目录列表组件 | 67 |
| `products/default/src/main/ets/viewmodel/CatalogueViewModel.ets` | 目录视图模型 | 24 |
| `products/default/src/main/ets/viewmodel/CatalogueItemData.ets` | 目录数据模型 | 13 |
| `common/src/main/ets/utils/Logger.ets` | 日志工具 | 23 |
| `common/src/main/ets/utils/BreakpointSystem.ets` | 断点系统 | 74 |
| `common/src/main/ets/constants/CommonConstants.ets` | 公共常量 | 30 |

---

## 5. MVP 改造计划

当前脚手架为 HarmonyOS 官方模板的布局演示，MVP 阶段需改造为业务脚手架：

| 改造项 | 说明 |
|--------|------|
| 首页替换 | 将 demo 目录列表替换为路由分发（已登录→个人中心，未登录→登录页） |
| HTTP 客户端 | 封装 `@ohos.net.http`，实现请求拦截和响应处理 |
| 本地存储 | 使用 `@ohos.data.preferences` 存储 Token |
| 路由守卫 | 页面 `aboutToAppear` 中检查登录状态 |
| 加密模块 | 封装 `cryptoFramework` 实现 AES+RSA 加密 |

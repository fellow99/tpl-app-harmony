# 宪法原则 (constitution)

> 项目：tpl-app-harmony（tpl-workspace 鸿蒙App端）
> 版本：v1.0.0
> 批准日期：2026-08-12
> 最后修订：2026-08-12

---

## 一、项目信息

| 项目 | 值 |
|------|-----|
| **项目名称** | tpl-workspace 鸿蒙App端 |
| **英文名称** | tpl-app-harmony |
| **Bundle Name** | `org.fellow99.tpl.TplAppHarmony` |
| **目标平台** | HarmonyOS 5.1 ~ 6.1 |
| **开发语言** | ArkTS |
| **UI 框架** | ArkUI（声明式） |

---

## 二、治理原则

### 原则 1：代码一致性（Code Consistency）

**规则**：
- 所有 ArkTS 源码文件使用一致的代码风格
- 类名使用 PascalCase，方法名和变量名使用 camelCase
- 常量使用 UPPER_SNAKE_CASE
- 文件名与主导出类名一致

**理由**：一致风格降低认知负担，便于团队协作和代码审查。

---

### 原则 2：模块化优先（Modularity First）

**规则**：
- 公共工具放入 `common` 模块（HAR 静态库）
- 独立功能特性放入 `features/` 目录（HSP 动态库）
- 产品入口代码放入 `products/default/`（HAP）
- 每个模块通过 `Index.ets` 导出其公共 API
- 模块之间只能通过 `Index.ets` 导出的接口通信

**理由**：模块化是鸿蒙应用的基础架构模式，遵循官方推荐的 HAP/HAR/HSP 分层。

---

### 原则 3：声明式 UI（Declarative UI）

**规则**：
- 所有 UI 组件使用 ArkUI 声明式语法（`@Component`、`@Builder`）
- 不在 `build()` 方法外直接操作 UI
- 状态变更通过 `@State`、`@Prop`、`@Link`、`@StorageLink` 等装饰器驱动 UI 刷新
- 复用的 UI 片段提取为 `@Builder` 函数或独立 `@Component`

**理由**：声明式 UI 是 ArkUI 的核心范式，与鸿蒙框架深度集成，能最大化利用框架性能优化。

---

### 原则 4：类型安全（Type Safety）

**规则**：
- 所有函数参数和返回值必须有类型注解
- 禁止使用 `any` 类型（除非与鸿蒙系统 API 交互时不可避免）
- 数据模型使用 `class` 或 `interface` 明确定义
- 使用 `strictMode`（已在 `build-profile.json5` 中启用 `caseSensitiveCheck`）

**理由**：类型安全减少运行时错误，提供更好的 IDE 智能提示。

---

### 原则 5：安全通信（Secure Communication）

**规则**：
- 所有与后端的 API 通信使用 HTTPS
- 登录/注册请求体加密传输（AES+RSA，与 tpl-app-web 保持一致）
- Token 安全存储，不在日志中打印敏感信息
- 敏感数据（密码、Token）不持久化到明文存储

**理由**：用户数据安全是教育类应用的基本要求。

---

### 原则 6：响应式适配（Responsive Design）

**规则**：
- 所有页面必须适配不同屏幕尺寸（手机竖屏、横屏、平板）
- 使用 `BreakpointSystem` 或 `GridRow`/`GridCol` 实现响应式布局
- 布局参数（`vp` 单位）应定义在资源文件中，而非硬编码

**理由**：HarmonyOS 覆盖多种设备形态，响应式设计确保一致的用户体验。

---

### 原则 7：渐进实现（Progressive Implementation）

**规则**：
- 优先实现 MVP 功能：用户注册、用户登录、个人中心
- 严格按模块优先级顺序开发
- 每个模块开发完成后进行独立验证

**理由**：避免过度工程化，聚焦核心价值交付。

---

### 原则 8：文档驱动（Documentation-Driven）

**规则**：
- 每个模块必须有 `spec.md`（功能规格）和 `plan.md`（技术方案）
- 包含前端界面操作的模块必须有 `test-cases.md`（测试用例）
- 规格文档存放于 `specs/` 目录，按模块编号组织
- 文档使用中文编写，技术术语保留英文

**理由**：清晰的文档降低交接成本，提升团队效率。

---

## 三、治理规则

### 3.1 修订流程

1. 提出修订提案（Issue 或 MR）
2. 团队评审
3. 通过后更新本文档，递增版本号
4. 同步更新 `SPECS_CHECKLIST.md`

### 3.2 版本策略

- **MAJOR**：原则增删或重大重新定义
- **MINOR**：新增原则或扩展现有原则
- **PATCH**：措辞修正、格式调整

### 3.3 合规审查

- 每个模块的 `plan.md` 必须包含"宪法合规检查"章节
- 违反 MUST 级别规则需在 plan.md 中说明理由并寻求批准

---

## 四、编码规范速查

### 4.1 文件命名

| 类型 | 格式 | 示例 |
|------|------|------|
| 页面 | `XxxPage.ets` 或 `XxxIndex.ets` | `LoginPage.ets` |
| 组件 | `XxxComponent.ets` 或 `Xxx.ets` | `CatalogueListComponent.ets` |
| 视图模型 | `XxxViewModel.ets` | `AuthViewModel.ets` |
| 数据模型 | `XxxModel.ets` 或 `XxxData.ets` | `CatalogueItemData.ets` |
| 服务 | `XxxService.ets` | `AuthService.ets` |
| 常量 | `XxxConstants.ets` | `RouteConstants.ets` |

### 4.2 目录结构规范

```
<模块目录>/src/main/ets/
├── pages/         # 页面（@Entry组件）
├── view/          # 可复用视图组件（@Component / @Builder）
├── viewmodel/     # 视图模型（状态管理）
├── model/         # 数据模型/实体
├── service/       # API/业务服务层
└── constants/     # 常量定义
```

### 4.3 状态管理规范

| 场景 | 方案 |
|------|------|
| 组件内部状态 | `@State` |
| 父子组件传递 | `@Prop`（父→子）、`@Link`（双向） |
| 跨页面共享 | `AppStorage` + `@StorageLink` |
| 复杂全局状态 | `@Observed` + `@ObjectLink` 或 V2 状态管理 |

---

## 五、文档分工治理规则（与父工程对齐）

> 本节遵循父工程宪法 `../../specs/constitution.md` 第四章「文档分工治理规则」定义的文档分工契约。本工程 MUST 遵守以下规则：

1. **模块编号对齐**：本工程模块编号 MUST 与父工程模块编号对齐（同一产品功能跨工程使用一致编号，如 002-user-auth、101-profile）。
2. **父工程侧重需求规格**：产品功能需求的权威定义在父工程 `spec.md`，本工程 `spec.md` 不重复编写需求。
3. **父工程 plan 侧重实现逻辑**：父工程 `plan.md` 描述跨工程实现逻辑，本工程 `plan.md` 不重复。
4. **本工程侧重落地实现**：本工程规范文档 MUST 重点描述功能在本工程的落地实现，核心文档是 `plan.md` 与 `test-cases.md`。
5. **本工程 spec 引用父工程**：本工程 `spec.md` SHOULD 引用父工程对应 `spec.md`，再补充本工程必要的特有规格。

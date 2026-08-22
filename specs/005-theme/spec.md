# 主题皮肤切换功能规格 (005-theme/spec)

> 模块：005-theme（主题皮肤支持）
> 状态：实现中
> 最后更新：2026-08-18
> 参考：父工程 specs/005-theme/{spec,var,plan}.md、resources/{base,dark}/element/color.json、ThemeManager.ets
> 父工程规格引用：需求基准见 [../../../specs/005-theme/spec.md](../../../specs/005-theme/spec.md)，样式变量事实源见 [../../../specs/005-theme/var.md](../../../specs/005-theme/var.md)，本文档仅补充本工程（鸿蒙端）特有规格

> 本文档中的 MUST / SHOULD / MAY 遵循 RFC 2119 语义。

---

## 1. 模块概述

### 1.1 目的

主题皮肤模块负责让鸿蒙端界面随主题切换呈现「亮色（tpl-workspace）+ 暗色（护眼）」两套固定皮肤，并支持 `light`（浅色）/ `dark`（深色）/ `system`（跟随系统）三态选择。本工程复用父工程 `specs/005-theme/var.md` 的颜色单一事实源，通过鸿蒙原生资源限定符（`base` / `dark`）+ `setColorMode` 落地，并提供登录页右上角圆形 emoji 切换按钮与个人中心「切换主题」入口。

### 1.2 解决的问题

- 界面颜色硬编码散落 12 个 .ets 文件（135 处），品牌色与语义色无法统一切换。
- 无主题切换能力，夜间/护眼场景体验差。
- 缺少「语义色 → 鸿蒙资源名」的映射规范。

### 1.3 范围

**包含（本工程）**：

- 核心品牌色/中性色收敛到 `resources/base/element/color.json`，新增 `resources/dark/element/color.json`（dark 变体）。
- 三态主题状态管理（`ThemeManager`）+ 本地持久化（`StorageService`，key `theme`）。
- 登录页右上角圆形 emoji 按钮（🌙/☀️）。
- 个人中心「切换语言」下新增「切换主题」入口（三态选择）。

**不包含（本工程）**：

- 颜色事实源维护（父工程 `specs/005-theme/var.md` 负责）。
- 全部 135 处硬编码收敛（本轮聚焦登录页与个人中心两个页面，其余页面后续迭代）。

---

## 2. 用户故事

### US-THEME-001：登录页一键切换

> 作为用户，我可在登录页右上角点击圆形按钮，一键切换亮色/暗色主题。

**验收标准**：

- 亮色时按钮显示 `🌙`，点击后主题变暗、按钮变 `☀️`。
- 暗色时按钮显示 `☀️`，点击后主题变亮、按钮变 `🌙`。
- 全程无刷新、无白屏。

### US-THEME-002：个人中心切换主题

> 作为用户，登录后可在「个人中心」的「切换语言」下找到「切换主题」，随时切换浅色/深色/跟随系统。

**验收标准**：

- 个人中心提供「切换主题」入口，可选中三态之一。
- 切换后与登录页按钮状态一致（共享同一主题状态）。

### US-THEME-003：主题持久化

> 作为用户，我切换主题后重启 App，主题选择仍被保留。

**验收标准**：

- 切换为暗色后重启，仍为暗色。
- 未手动选择过时默认 `system`（跟随系统深浅色）。

### US-THEME-004：跟随系统

> 作为用户，首次使用未手动选择时，主题默认跟随系统深浅色，系统深浅色变化时实时联动。

**验收标准**：

- `system` 态下，系统切深色时应用实时切暗色，切浅色时实时切亮色。

---

## 3. 功能需求（本工程特有）

> 需求基准（三态模型、变量命名、暗色取值、切换模型等）见父工程 [../../../specs/005-theme/spec.md](../../../specs/005-theme/spec.md) §3 与 [../../../specs/005-theme/var.md](../../../specs/005-theme/var.md)，本文档不重复。

### 3.1 颜色资源落点

- FR-005-020: 核心品牌色/中性色 MUST 收敛到 `products/default/src/main/resources/base/element/color.json`，资源 `name` 遵循父工程 var.md §8 映射规则（`--` 去除、`-`→`_`），如 `--color-primary` → `color_primary`。
- FR-005-021: `resources/dark/element/color.json` MUST 提供与 `base` 同名变量的暗色取值（值见父工程 var.md §6），保证 `$r('app.color.*')` 随颜色模式自动解析。
- FR-005-022: `base/element/color.json` MUST 保留既有 `start_window_background` 资源，不得覆盖丢失。

### 3.2 主题状态管理

- FR-005-023: 系统 MUST 提供 `ThemeManager` 工具：三态 `light`/`dark`/`system`（默认 `system`），`setMode` / `applySavedTheme` / `isEffectiveDark` / `getCurrentMode`。
- FR-005-024: 三态 MUST 映射 `setColorMode`：`system` → `COLOR_MODE_NOT_SET`、`light` → `COLOR_MODE_LIGHT`、`dark` → `COLOR_MODE_DARK`。
- FR-005-025: 主题选择 MUST 经 `StorageService`（key `theme`）本地持久化，冷启动在 `DefaultAbility.onCreate` 恢复上次选择；未选择过时跟随系统。
- FR-005-026: 主题切换 MUST 即时生效，无需整页刷新或重启（依赖 `setColorMode` + 资源限定符自动重解析）。

### 3.3 登录页切换按钮

- FR-005-027: 登录页右上角 MUST 放置一个圆形 emoji 按钮（最小点击区域 ≥ 44px），亮色显示 `🌙`、暗色显示 `☀️`。
- FR-005-028: 按钮点击 MUST 在 light↔dark 之间切换（显式选择，覆盖 `system` 默认）。

### 3.4 个人中心「切换主题」

- FR-005-029: 个人中心在「切换语言」下 MUST 新增「切换主题」入口。
- FR-005-030: 「切换主题」MUST 提供三态选择（浅色/深色/跟随系统），与登录页按钮共享同一主题状态与持久化键。

### 3.5 安全与规范

- FR-005-031: 主题相关日志 MUST 使用 `hilog`，禁止 `console`。
- FR-005-032: 本模块 MUST 使用 V1 状态装饰器（`@StorageLink`/`@StorageProp`）与既有代码一致，禁止 V1/V2 混用。

---

## 4. 关键契约

### 4.1 主题状态模型

| 状态 | 值 | 语义 | setColorMode 映射 |
|------|-----|------|------------------|
| 浅色 | `light` | 强制 tpl-workspace亮色皮肤 | `COLOR_MODE_LIGHT` |
| 深色 | `dark` | 强制「护眼暗色」皮肤 | `COLOR_MODE_DARK` |
| 跟随系统 | `system`（默认） | 跟随系统深浅色 | `COLOR_MODE_NOT_SET` |

> 登录页按钮为两态切换（light↔dark，显式选择）；`system` 仅作为首次使用的默认值，由「切换主题」入口提供三态选择。

### 4.2 变量命名映射

| CSS 变量（var.md） | 鸿蒙资源名 | default（亮色） | dark（暗色） |
|--------------------|-----------|----------------|-------------|
| `--color-primary` | `color_primary` | `#3B5998` | `#5B7DB1` |
| `--color-accent` | `color_accent` | `#E8923C` | `#E8923C` |
| `--color-success` | `color_success` | `#4AA878` | `#7BC49A` |
| `--color-danger` | `color_danger` | `#D94E3C` | `#E0705F` |
| `--color-bg` | `color_bg` | `#F7F5F0` | `#1A1C1E` |
| `--color-surface` | `color_surface` | `#FFFFFF` | `#26282B` |
| `--color-text` | `color_text` | `#292522` | `#E8E4DE` |
| `--color-text-secondary` | `color_text_secondary` | `#6E6A65` | `#A8A29A` |
| `--color-border` | `color_border` | `#D9D4CC` | `#3A3A38` |
| `--color-disabled` | `color_disabled` | `#EEECE6` | `#2E3033` |

### 4.3 持久化键

| 项目 | 值 |
|------|-----|
| Preferences 存储名 | `tpl_app_storage`（复用 StorageService） |
| 主题键 | `theme`（值：`light` / `dark` / `system`，默认 `system`） |
| AppStorage 响应式键 | `themeMode`（三态）、`effectiveDark`（布尔，解析后生效深浅） |

---

## 5. 验收场景

### 场景 1：登录页一键切换

- Given：登录页（亮色），按钮显示 `🌙`。
- When：点击右上角圆形按钮。
- Then：主题切换为暗色、按钮变 `☀️`，全程无刷新、无白屏。

### 场景 2：个人中心切换主题

- Given：已登录进入个人中心。
- When：点击「切换主题」选择「深色」。
- Then：主题切暗色，且与登录页按钮状态一致。

### 场景 3：持久化

- Given：已切换为暗色。
- When：重启 App。
- Then：仍为暗色（`DefaultAbility.onCreate` 恢复上次选择）。

### 场景 4：系统跟随

- Given：未手动选择（`system`），系统为深色。
- When：启动 App。
- Then：应用实时呈现暗色；系统切浅色时实时联动。

### 场景 5：两入口同步

- Given：登录页切为暗色。
- When：登录进入个人中心，打开「切换主题」选择器。
- Then：当前选中项为「深色」，与登录页状态一致。

### 场景 6：品牌色一致

- Given：任一鸿蒙端主色。
- Then：均为靛青 `#3B5998`（暗色提亮为 `#5B7DB1`），非微信绿、非 Material 蓝。

---

## 6. 非功能性需求

- NFR-THEME-001: 颜色定义 MUST 单一来源（父工程 `var.md`），本工程不重复维护色值语义。
- NFR-THEME-002: 主题切换 MUST 即时生效、无白屏、无闪烁。
- NFR-THEME-003: 资源名 MUST 符合鸿蒙资源名规范（小写字母、数字、下划线）。
- NFR-THEME-004: 暗色皮肤 MUST 遵循 DESIGN.md「反色但保留靛青/金曦品牌识别度」原则。

---

## 7. 假设与约束

| # | 假设 |
|---|------|
| A1 | 颜色事实源由父工程 `var.md` 维护，本工程手工映射到 color.json，不引入生成脚本。 |
| A2 | 扩展色（wechat / placeholder / divider）暗色取值 var.md §6 未锁定，本工程取「wechat 保持品牌绿、placeholder 保持、divider 取 Frost 暗色近似值」并记录，后续视觉 QA 定稿。 |
| A3 | `setColorMode` 触发资源限定符切换后，ArkUI 自动重解析 `$r('app.color.*')`，无需手动重载页面（父工程 FR-005-010）。 |
| A4 | 后端 tpl-app-api 无主题需求，本模块为纯前端本地偏好。 |

---

## 8. 依赖

| 依赖 | 说明 |
|------|------|
| 父工程 `specs/005-theme/` | 颜色事实源（var.md）+ 三态需求基准（spec.md） |
| 001-app-shell | `StorageService`（Preferences 封装）、`DefaultAbility`（冷启动恢复） |
| 002-user-auth | 登录页（LoginPage）、个人中心（ProfilePage） |
| ../constitution.md | 本工程宪法原则（文档分工治理规则、V1 装饰器约定） |

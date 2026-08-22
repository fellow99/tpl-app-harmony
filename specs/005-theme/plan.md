# 主题皮肤切换技术方案 (005-theme/plan)

> 模块：005-theme
> 状态：实现中
> 最后更新：2026-08-18
> 参考：父工程 specs/005-theme/plan.md §4.4、var.md §6/§9、resources/{base,dark}/element/color.json

---

## 1. 技术上下文

### 1.1 运行时环境

| 项目 | 值 |
|------|-----|
| 语言 | ArkTS |
| UI 框架 | ArkUI 声明式 |
| 资源解析 | `$r('app.color.xxx')`（编译期）+ 资源限定符（`base`/`dark`）自动切换 |
| 颜色模式 API | `ApplicationContext.setColorMode`（`ConfigurationConstant.ColorMode`） |
| 本地持久化 | `StorageService`（Preferences，key `theme`） |
| 响应式桥接 | `AppStorage` + `@StorageProp`（V1） |

### 1.2 主题切换链路

```
用户操作（登录页按钮 / 个人中心「切换主题」）
  → ThemeManager.setMode(mode)
  → StorageService.saveTheme(mode)         # 持久化
  → AppStorage.setOrCreate('themeMode'/'effectiveDark')  # 通知 UI 层
  → ApplicationContext.setColorMode(...)   # 三态映射，触发资源限定符切换
  → ArkUI 重解析 $r('app.color.*')（base ↔ dark）
```

系统深浅色变化（`system` 态）→ `DefaultAbility.onConfigurationUpdate` → 更新 `AppStorage` 的 `effectiveDark` → 登录页按钮图标实时联动。

---

## 2. 宪法合规检查

| 原则 | 状态 | 说明 |
|------|:--:|------|
| 代码一致性 | ✅ | `ThemeManager` PascalCase、方法 camelCase，资源名全小写下划线 |
| 模块化优先 | ✅ | `ThemeManager` 置于 `products/default/ets/utils`，经 import 复用 |
| 声明式 UI | ✅ | 颜色经 `$r` 注入；状态经 `@StorageProp` 订阅，不在 build() 外直接操作 UI |
| 类型安全 | ✅ | `ThemeMode` 联合类型，无 `any` |
| 安全通信 | — | 本模块不涉及网络传输 |
| 响应式适配 | — | 本模块不涉及布局 |
| 渐进实现 | ✅ | 三态跟随系统 + 手动切换 + 持久化 + 双入口同步 |
| 文档驱动 | ✅ | spec + plan + test-cases 三件套 |

**文档分工治理规则符合性**（../constitution.md §五）：

- 模块编号 `005` 与父工程对齐 ✅
- 需求规格以父工程 `spec.md` 为权威，本工程不重复 ✅
- 跨工程实现逻辑以父工程 `plan.md` 为准，本工程不重复 ✅
- 本工程侧重落地实现（本 plan + test-cases） ✅
- 本工程 `spec.md` 引用父工程并补充特有规格 ✅

---

## 3. 核心实现设计

### 3.1 资源目录结构

```
products/default/src/main/resources/
├── base/element/color.json      # 亮色（default）：核心品牌色/中性色/扩展色 + start_window_background
└── dark/element/color.json      # 暗色变体：同名变量的 dark 取值（var.md §6）
```

要点：

- `base/` 为默认资源目录（亮色），`dark/` 为深色限定目录；颜色模式为暗色时 `$r('app.color.color_bg')` 自动解析 `dark/` 值，其余回退 `base`。
- 资源 `name` 遵循 var.md §8：`--color-primary` → `color_primary`（`--` 去除、`-`→`_`）。
- `base/element/color.json` 合并而非覆盖，保留既有 `start_window_background`。

### 3.2 颜色变量映射（核心品牌色/中性色/扩展色）

| CSS 变量 | 资源名 | default | dark |
|----------|--------|---------|------|
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
| `--color-wechat` | `color_wechat` | `#07C160` | `#07C160` |
| `--color-placeholder` | `color_placeholder` | `#B0ADA8` | `#B0ADA8` |
| `--color-divider` | `color_divider` | `#F0ECE6` | `#2E3033` |

> `wechat`/`placeholder`/`divider` 为扩展色（var.md §5），其暗色值 var.md §6 未锁定，本工程取「品牌绿保持、placeholder 保持、divider 取 Frost 暗色近似值」并记录为假设，后续视觉 QA 定稿。

### 3.3 ThemeManager.ets（三态状态管理）

新增 `utils/ThemeManager.ets`，核心 API：

```typescript
export type ThemeMode = 'light' | 'dark' | 'system';
export const THEME_MODES: ThemeMode[] = ['light', 'dark', 'system'];
export const THEME_MODE_KEY = 'themeMode';        // AppStorage：三态选择
export const EFFECTIVE_DARK_KEY = 'effectiveDark'; // AppStorage：解析后是否暗色

export class ThemeManager {
  static getCurrentMode(): ThemeMode
  static isMode(value: string): boolean
  static setMode(mode: ThemeMode): void        // 更新内存态 → 持久化 → AppStorage → setColorMode
  static applySavedTheme(): void               // 冷启动恢复（读 StorageService，默认 system）
  static isEffectiveDark(): boolean            // 解析三态：dark→true / light→false / system→读系统
  static onSystemColorModeChanged(colorMode): void // system 态下系统变化时更新 effectiveDark
}
```

三态映射（`COLOR_MODE: Record<ThemeMode, ConfigurationConstant.ColorMode>`）：

| mode | ColorMode |
|------|-----------|
| `light` | `COLOR_MODE_LIGHT` |
| `dark` | `COLOR_MODE_DARK` |
| `system` | `COLOR_MODE_NOT_SET` |

实现要点：

1. `setMode`：更新 `currentMode` → `StorageService.saveTheme(mode)` → `AppStorage.setOrCreate(THEME_MODE_KEY, mode)` → `AppStorage.setOrCreate(EFFECTIVE_DARK_KEY, resolveEffectiveDark())` → `getContext().getApplicationContext().setColorMode(...)`（`try/catch` + `hilog.error`）。
2. `applySavedTheme`：读 `StorageService.getTheme()`，合法则恢复，否则 `system`；随后 `init()`（`AppStorage.setOrCreate` 两键）+ `applyColorMode()`。
3. `isEffectiveDark`：`dark`→true、`light`→false、`system`→读 `getContext().config.colorMode === COLOR_MODE_DARK`（`try/catch` 兜底 false）。
4. `onSystemColorModeChanged(colorMode)`：仅 `currentMode === 'system'` 时更新 `AppStorage.setOrCreate(EFFECTIVE_DARK_KEY, colorMode === COLOR_MODE_DARK)`。

> 依据：`setColorMode(COLOR_MODE_NOT_SET)` 表示「不覆盖，跟随系统」，系统模式变化会触发 `onConfigurationUpdate`；一旦写死 DARK/LIGHT，系统变化不再通知（官方示例 ColorAdaptionApp 行为）。故 `system` 态靠 `onConfigurationUpdate` 联动，显式态靠 `setMode` 直接更新 AppStorage。

### 3.4 StorageService.ets（theme 持久化）

- 新增 `KEY_THEME = 'theme'`、`saveTheme(theme: string)`、`getTheme(): string`（默认返回 `'system'`）。
- 复用既有 `putSync` / `getSync` / `flush` 模式，无新增依赖。

### 3.5 DefaultAbility.ets（冷启动恢复 + 系统联动）

- 用 `ThemeManager.applySavedTheme()` 替换硬编码的 `setColorMode(COLOR_MODE_NOT_SET)`。
- 新增 `onConfigurationUpdate(newConfig: Configuration): void`：读 `newConfig.colorMode`，仅当为 `COLOR_MODE_DARK`/`COLOR_MODE_LIGHT` 时调 `ThemeManager.onSystemColorModeChanged(...)`（配置变化可能由语言/方向触发，`colorMode` 需空值判断）。

### 3.6 登录页切换按钮（LoginPage.ets）

- 页面根容器改为 `Stack({ alignContent: Alignment.TopEnd })`：内容区（`Scroll`）+ 右上角圆形按钮。
- 圆形按钮：44×44、`borderRadius(22)`、`backgroundColor($r('app.color.color_surface'))`、`border($r('app.color.color_border'))`，文本为 emoji。
- 图标响应式：`@StorageProp('effectiveDark') effectiveDark: boolean`，`effectiveDark ? '☀️' : '🌙'`。
- 点击：`ThemeManager.setMode(effectiveDark ? 'light' : 'dark')`（显式覆盖 system）。
- 硬编码色收敛：`#3B5998`→`$r('app.color.color_primary')`、`#6E6A65`→`$r('app.color.color_text_secondary')`、`#F7F5F0`→`$r('app.color.color_bg')`。

### 3.7 个人中心「切换主题」（ProfilePage.ets）

- 「切换语言」按钮下新增「切换主题」按钮（文案 `$r('app.string.auth_profile_theme')`），样式与「切换语言」一致。
- 点击 `TextPickerDialog.show` 列出三态（自识别文案常量 `THEME_NAMES`，与 LANGUAGE_NAMES 同法：`light`→浅色 / `dark`→深色 / `system`→跟随系统），`selected` 回显 `ThemeManager.getCurrentMode()`。
- `onAccept` 拿到下标 → `ThemeManager.setMode(mode)`（无需重载页面，`setColorMode` 即时生效）。
- 硬编码色收敛：`#6E6A65`→`color_text_secondary`、`#292522`→`color_text`、`#F0ECE6`→`color_divider`、`#FFFFFF`→`color_surface`、`#3B5998`→`color_primary`、`#07C160`→`color_wechat`、`#D94E3C`→`color_danger`、`#F7F5F0`→`color_bg`。

### 3.8 文案资源

- 新增 `auth_profile_theme`（切换主题 / Theme / 切換主題）加入三份 `string.json`（base / en_US / zh_TW）。
- 三态自识别名称（浅色 / 深色 / 跟随系统）作为常量硬编码（与 LANGUAGE_NAMES 一致，语料暂无 `theme.*` 键）。

---

## 4. 文件清单

| 文件 | 用途 | 状态 |
|------|------|:--:|
| `specs/005-theme/{spec,plan,test-cases}.md` | 本工程规格/方案/测试用例 | 新建 |
| `products/default/src/main/resources/base/element/color.json` | 亮色核心颜色收敛 | 改造 |
| `products/default/src/main/resources/dark/element/color.json` | 暗色变体（var.md §6） | 改造 |
| `products/default/src/main/ets/utils/ThemeManager.ets` | 三态主题管理器 | 新建 |
| `products/default/src/main/ets/service/StorageService.ets` | 新增 `theme` 持久化 | 改造 |
| `products/default/src/main/ets/defaultability/DefaultAbility.ets` | 恢复主题 + `onConfigurationUpdate` | 改造 |
| `products/default/src/main/ets/pages/LoginPage.ets` | 圆形 emoji 按钮 + 颜色收敛 | 改造 |
| `products/default/src/main/ets/pages/ProfilePage.ets` | 「切换主题」入口 + 颜色收敛 | 改造 |
| `products/default/src/main/resources/{base,en_US,zh_TW}/element/string.json` | 新增 `auth_profile_theme` | 改造 |

---

## 5. 测试要点

- 三态 `setColorMode` 映射正确（system/light/dark）。
- `ThemeManager.setMode` 持久化 + AppStorage 联动。
- 冷启动 `applySavedTheme` 恢复上次选择；未选择默认 system。
- 登录页按钮图标随 `effectiveDark` 切换、点击 light↔dark 显式覆盖。
- 个人中心「切换主题」三态选择、两入口状态同步。
- `$r('app.color.*')` 在 base/dark 两套取值下正确解析。
- 无 `console`、无 V1/V2 混用。

详细用例见 [test-cases.md](./test-cases.md)。

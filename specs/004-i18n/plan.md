# 多语言国际化技术方案 (004-i18n/plan)

> 模块：004-i18n
> 状态：已实现
> 最后更新：2026-08-18
> 参考：父工程 specs/004-i18n/plan.md §4.5、i18n/scripts/sync-i18n.mjs

---

## 1. 技术上下文

### 1.1 运行时环境

| 项目 | 值 |
|------|-----|
| 语言 | ArkTS |
| UI 框架 | ArkUI 声明式 |
| 资源解析 | `$r()`（编译期） + `ResourceManager.getStringByNameSync()`（运行时） |
| 全局上下文 | `getContext()`（@kit.AbilityKit） |
| 语料来源 | 父工程 `i18n/{common,app}/{zh-CN,en-US,zh-TW}.json` |

### 1.2 语料生成链路

父工程 `i18n/scripts/sync-i18n.mjs` 读取 `i18n/{common,app}/*.json`（合并为扁平键集，共 214 key），按端生成原生格式。本工程的生成规则：

| 语料 locale | 本工程目录 | 说明 |
|-------------|-----------|------|
| zh-CN | `base/element/string.json` | 默认语言，与既有资源合并 |
| en-US | `en_US/element/string.json` | 纯语料 |
| zh-TW | `zh_TW/element/string.json` | 纯语料 |

转换规则：点号 key 转下划线资源名（`.` → `_`），生成 `{"name": "...", "value": "..."}` 数组。生成物标记为 Auto-generated，语料变更后重跑 sync 覆盖。

---

## 2. 宪法合规检查

| 原则 | 状态 | 说明 |
|------|:--:|------|
| 代码一致性 | ✅ | `I18n` 类名 PascalCase、方法 camelCase，资源名全小写下划线 |
| 模块化优先 | ✅ | `I18n` 工具置于 `products/default/ets/utils`，经 import 复用 |
| 声明式 UI | ✅ | 文案经 `$r` / `I18n.t` 注入，不在 build() 外直接操作 UI |
| 类型安全 | ✅ | `t(key, context?)` 参数与返回值均有类型注解，无 `any` |
| 安全通信 | — | 本模块不涉及网络传输 |
| 响应式适配 | — | 本模块不涉及布局 |
| 渐进实现 | ✅ | 三语言跟随系统 + 后端 key 翻译 + 应用内手动切换 |
| 文档驱动 | ✅ | spec + plan + test-cases 三件套 |

**文档分工治理规则符合性**（../constitution.md §五）：

- 模块编号 `004` 与父工程对齐 ✅
- 需求规格以父工程 `spec.md` 为权威，本工程不重复 ✅
- 跨工程实现逻辑以父工程 `plan.md` 为准，本工程不重复 ✅
- 本工程侧重落地实现（本 plan + test-cases） ✅
- 本工程 `spec.md` 引用父工程并补充特有规格 ✅

---

## 3. 核心实现设计

### 3.1 资源目录结构

```
products/default/src/main/resources/
├── base/element/string.json      # 默认中文：214 条语料 + 9 条既有系统资源（app_name/ability_label 等）
├── en_US/element/string.json     # 英文：214 条语料
└── zh_TW/element/string.json     # 繁体中文：214 条语料
```

要点：

- `base/` 为鸿蒙默认资源目录，无 locale 限定符；系统语言不匹配任何限定目录时回退 `base`。
- zh-CN 语料写入 `base/`（而非 `zh_CN/`），保证 `$r()` 与 `getStringByNameSync` 在任意语言下都能解析到中文兜底。
- sync 脚本对 `base/string.json` 做合并而非覆盖，避免丢失既有 `app_name`、`ability_label`、`module_desc` 等系统资源。

### 3.2 key 到资源名映射

| 场景 | i18n key | 资源名 |
|------|----------|--------|
| 错误消息 | `message.error.loginFailed` | `message_error_loginFailed` |
| 登录 UI | `auth.login.title` | `auth_login_title` |

规则：`key.replace(/\./g, '_')`，点号全部替换为下划线，其余字符原样保留。鸿蒙资源名不允许点号，因此必须做此映射。

### 3.3 I18n.ets 运行时解析

新增 `utils/I18n.ets`，核心 API：

```typescript
export class I18n {
  static t(key: string, context?: common.Context): string
}
```

实现逻辑：

1. 空 key：原样返回空串（`key === ''` 短路）。
2. 资源名映射：`key.replace(/\./g, '_')`。
3. 上下文获取：`context ?? getGlobalContext()`，其中 `getGlobalContext()` 内部 `getContext()` 失败返回 `undefined`。
4. 资源解析：`ctx.resourceManager.getStringByNameSync(resourceName)`。
5. 兜底：`try/catch` 捕获解析异常或上下文缺失，返回原 key。

**为什么不用 `$r()`**：`$r('app.string.xxx')` 只接受编译期字面量，无法拼接运行时动态 key。后端返回的 `R.msg` 是运行时字符串，只能经 `ResourceManager.getStringByNameSync` 按名解析。二者分工：

- 编译期已知的静态文案 → `$r('app.string.xxx')`（编译期校验、性能最优）。
- 运行时动态 key（后端消息、字典值） → `I18n.t(key)`。

### 3.4 ApiClient.ets 错误 key 化

`service/ApiClient.ets` 的 `ApiError extends Error`，`message` 字段承载 i18n key（点号），展示层经 `I18n.t` 解析。`code` 字段承载业务状态码（`-1` 表示网络层错误）。

| 触发点 | ApiError.code | ApiError.message（i18n key） |
|--------|:--:|------|
| HTTP 401 | 401 | `message.error.unauthorized` |
| HTTP 非 200（非 401） | responseCode | `message.error.requestFailed` |
| 业务 code 401 | 401 | `message.error.unauthorized` |
| 业务 code 非 200 | parsed.code | `parsed.msg`（后端 key，空则 `message.error.requestFailed`） |
| 网络异常（catch） | -1 | `message.error.network` |

关键点：后端返回的 `R.msg` 原样透传为 `ApiError.message`，不在服务层替换为真实文案；401 时先 `StorageService.clearAll()` 清理登录态再抛错。

### 3.5 pages / view 文案迁移

各 pages / view 的硬编码中文迁移为两类引用：

| 类型 | 写法 | 适用场景 |
|------|------|---------|
| 编译期字面量 | `$r('app.string.auth_login_title')` | 页面标题、按钮、占位符等静态文案 |
| 运行时 key | `I18n.t('message.error.phoneInvalid')` | 表单校验、后端错误、动态字典 |

后端错误统一经 `I18n.t((err as Error).message)` 解析（见 `LoginForm.ets` / `RegisterForm.ets`）。表单即时校验错误用 `I18n.t('message.error.xxx')` 字面量 key。

### 3.7 应用内语言切换

**背景**：`i18n.System.setAppPreferredLanguage` 只影响编译期 `$r()` 静态资源，且需重载页面才生效；`resourceManager.getStringByNameSync` 用缓存的系统语言，不随偏好语言变化。因此动态 key 需走「覆盖资源解析」实现即时切换。

**语言状态与持久化（`I18n.ets`）**：

- 新增 `AppLocale = 'zh-CN' | 'en-US' | 'zh-TW'`、`LOCALES` 常量与 `getCurrentLocale()` / `setLocale(locale)`。
- `setLocale(locale)`：更新内存态 → `StorageService.saveLanguage(locale)` 持久化 → `i18n.System.setAppPreferredLanguage(locale)`（连字符 tag）→ 失效覆盖资源管理器缓存。
- 冷启动在 `DefaultAbility.onCreate` 调 `I18n.applySavedLocale()`：读 `StorageService.getLanguage()`，有值则应用，无值则按 `i18n.System.getSystemLanguage()` 归一化跟随系统。

**动态 key 覆盖解析（`I18n.t`）**：

```typescript
const RESOURCE_LOCALE: Record<AppLocale, string> = {
  'zh-CN': 'zh_CN', 'en-US': 'en_US', 'zh-TW': 'zh_TW',
};

static t(key: string): string {
  if (key === '') return '';
  const resourceName = key.replace(/\./g, '_');
  try {
    return I18n.getOverrideManager().getStringByNameSync(resourceName);
  } catch (e) {
    return key;
  }
}

private static getOverrideManager(): resourceManager.ResourceManager {
  if (I18n.overrideManager !== undefined) return I18n.overrideManager;
  const resMgr = (getContext() as common.UIAbilityContext).resourceManager;
  const conf = resMgr.getOverrideConfiguration();
  conf.locale = RESOURCE_LOCALE[I18n.currentLocale];
  I18n.overrideManager = resMgr.getOverrideResourceManager(conf);
  return I18n.overrideManager;
}
```

**个人中心入口（`ProfilePage.ets`）**：

- 新增「切换语言」按钮（文案 `$r('app.string.auth_profile_language')`），点击用 `TextPickerDialog.show` 列出三语言（自识别文案 简体中文 / English / 繁體中文），`selected` 回显当前语言。
- `onAccept` 拿到选中下标 → `I18n.setLocale(locale)` → `router.replaceUrl({ url: PROFILE_ROUTE })` 重载当前页，使静态 `$r()` 随 `setAppPreferredLanguage` 重解析。

**新增资源**：`auth_profile_language`（切换语言 / Language / 切換語言）加入三份 `string.json`；三语言自识别名称（简体中文 / English / 繁體中文）作为常量硬编码（与 tpl-app-mini `LANGUAGE_NAMES` 一致，语料暂无 `language.*` 键）。

---

## 4. 文件清单

| 文件 | 用途 | 状态 |
|------|------|:--:|
| `products/default/src/main/resources/base/element/string.json` | 默认中文语料 + 系统资源 | 已生成 |
| `products/default/src/main/resources/en_US/element/string.json` | 英文语料 | 已生成 |
| `products/default/src/main/resources/zh_TW/element/string.json` | 繁体中文语料 | 已生成 |
| `products/default/src/main/ets/utils/I18n.ets` | 运行时 key 翻译工具 | 已实现 |
| `products/default/src/main/ets/service/ApiClient.ets` | ApiError message 改用 i18n key | 已改造 |
| `products/default/src/main/ets/pages/*.ets` | 页面静态文案 `$r` / 动态 key `I18n.t` | 已迁移 |
| `products/default/src/main/ets/view/*.ets` | 视图文案 `$r` / `I18n.t` | 已迁移 |
| `products/default/src/main/ets/utils/I18n.ets` | 语言状态 + `setLocale` + 覆盖资源解析 | 改造 |
| `products/default/src/main/ets/service/StorageService.ets` | 新增 `language` 持久化 | 改造 |
| `products/default/src/main/ets/defaultability/DefaultAbility.ets` | `onCreate` 恢复上次语言 | 改造 |
| `products/default/src/main/ets/pages/ProfilePage.ets` | 新增「切换语言」入口 | 改造 |

> 资源文件由父工程 `i18n/scripts/sync-i18n.mjs` 生成，勿手动编辑。

---

## 5. 测试要点

- 三语言 `string.json` 的 `name` 集合一致性（点号转下划线后）。
- `I18n.t` 对后端 key 的解析（三语言）。
- `I18n.t` 未命中回退原 key、空 key 返回空串、上下文缺失回退。
- `base` 默认语言回退。
- `$r` 静态文案解析、页面无硬编码中文。
- `ApiClient` 各错误分支的 `ApiError.message` 为正确 key。

详细用例见 [test-cases.md](./test-cases.md)。

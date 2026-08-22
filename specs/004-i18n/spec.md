# 多语言国际化功能规格 (004-i18n/spec)

> 模块：004-i18n（多语言国际化）
> 状态：已实现
> 最后更新：2026-08-18
> 参考：父工程 specs/004-i18n/spec.md、i18n/{common,app}/*.json、i18n/scripts/sync-i18n.mjs
> 父工程规格引用：需求基准见 [../../../specs/004-i18n/spec.md](../../../specs/004-i18n/spec.md)，本文档仅补充本工程（鸿蒙端）特有规格

> 本文档中的 MUST / SHOULD / MAY 遵循 RFC 2119 语义。

---

## 1. 模块概述

### 1.1 目的

多语言国际化模块负责让鸿蒙端界面文案与后端反馈消息随系统语言切换（简体中文 / 英文 / 繁体中文）。本工程复用父工程 `i18n/` 语料单一事实源，通过鸿蒙原生资源限定符承载语料，并提供运行时 key 解析能力。

### 1.2 解决的问题

- 界面文案硬编码中文，语言不可切换。
- 后端返回 i18n key（点号），前端需要运行时把 key 解析为本地化文案。
- 鸿蒙 `$r()` 只接受编译期字面量，无法直接解析运行时动态 key。

### 1.3 范围

**包含（本工程）**：

- 原生字符串资源多语言（`string.json` 资源限定）。
- 后端 key 翻译（运行时 `I18n.t` 解析）。
- 各 pages / view 硬编码中文迁移为资源引用。
- 应用内手动切换语言并本地持久化（个人中心「切换语言」入口）。

**不包含（本工程）**：

- 语料事实源维护（父工程 `i18n/` 负责）。
- 语料生成与校验脚本（父工程 `i18n/scripts/` 负责）。

---

## 2. 用户故事

### US-I18N-001：系统语言跟随

> 作为用户，我把设备语言设为英文或繁体，App 界面与后端提示随之切换，无需在应用内单独设置。

**验收标准**：

- 设备语言为简体中文时，界面显示简体文案。
- 设备语言为英文时，界面与后端消息显示英文。
- 设备语言为繁体时，界面与后端消息显示繁体。

### US-I18N-002：后端错误消息翻译

> 作为用户，登录或提交表单失败时，我看到的错误提示是本地化文案，而不是一串 key。

**验收标准**：

- 后端返回 `message.error.loginFailed` 时，界面显示"登录失败"（或对应语言文案）。

### US-I18N-003：未命中兜底

> 作为用户，即使语料缺失某个 key，界面也不白屏，仍能看到可读的提示（原 key）。

**验收标准**：

- 翻译未命中时显示原 key，不抛异常，不影响主流程。

### US-I18N-004：应用内切换语言

> 作为用户，我可在个人中心手动切换中文 / 英文 / 繁体，界面与后端提示随之切换，选择被记住，下次启动仍生效。

**验收标准**：

- 个人中心提供「切换语言」入口，可选中三语言之一。
- 切换后当前页与后端消息即时切换到目标语言。
- 选择持久化，重启后仍为目标语言。
- 未选择过时默认跟随系统语言。

---

## 3. 功能需求（本工程特有）

> 需求基准（语料事实源、命名规范、后端 key 契约、语言切换模型等）见父工程 [../../../specs/004-i18n/spec.md](../../../specs/004-i18n/spec.md) §3，本文档不重复。

### 3.1 语料资源落点

- FR-004-021: 系统 MUST 用原生资源限定 `products/default/src/main/resources/{base,en_US,zh_TW}/element/string.json` 承载语料，其中 `base` 为默认语言（简体中文）。
- FR-004-022: 语料 key MUST 做「点号转下划线」映射后作为资源名，例如 `message.error.loginFailed` → `message_error_login_failed`。
- FR-004-023: `base/element/string.json` MUST 与既有系统资源（`app_name`、`ability_label` 等）合并，不得覆盖丢失。

### 3.2 运行时翻译

- FR-004-024: 系统 MUST 提供 `I18n.t(key, context?)` 工具：点号 key → 下划线资源名 → `resourceManager.getStringByNameSync(name)` 运行时解析。
- FR-004-025: 页面静态文案（编译期已知）MUST 用 `$r('app.string.xxx')` 引用资源。
- FR-004-026: 翻译未命中（资源不存在或上下文缺失）时 MUST 回退显示原 key，不得抛异常或导致白屏。
- FR-004-027: 空 key MUST 原样返回空字符串。

### 3.3 后端 key 翻译

- FR-004-028: `ApiClient` 抛出的 `ApiError.message` MUST 为 i18n key（点号），展示层经 `I18n.t` 解析为本地化文案。
- FR-004-029: 后端 `R.msg` 返回的 key MUST 原样透传至展示层，由 `I18n.t` 翻译，不得在服务层替换为真实文案。

### 3.4 数据字典翻译


### 3.5 应用内语言切换

- FR-004-031: 语言 MUST 默认跟随系统；应用内可手动切换并本地持久化（父工程 FR-004-017）。
- FR-004-032: `I18n` MUST 提供 `getCurrentLocale()` / `setLocale(locale)`，切换时写 `StorageService`（key `language`）并调 `i18n.System.setAppPreferredLanguage(tag)`（BCP 47 连字符格式）。
- FR-004-033: `I18n.t` MUST 经 `resourceManager.getOverrideResourceManager`（`conf.locale` 设为当前语言对应资源限定，下划线格式）解析，保证运行时动态 key 即时随语言切换，不受系统语言缓存影响。
- FR-004-034: 个人中心 MUST 提供「切换语言」入口，弹出选择器（简体中文 / English / 繁體中文），选中后切换 + 持久化 + 重载当前页（`router.replaceUrl`）。
- FR-004-035: 语言偏好 MUST 经 `StorageService`（key `language`）持久化，冷启动在 `DefaultAbility.onCreate` 恢复上次选择；未选择过时跟随系统。

---

## 4. 关键契约

### 4.1 语料源与生成物

| 项目 | 值 |
|------|-----|
| 事实源 | 父工程 `i18n/{common,app}/{zh-CN,en-US,zh-TW}.json` |
| 合并键数 | 214（common + app 域合并后） |
| 生成脚本 | 父工程 `i18n/scripts/sync-i18n.mjs` |
| 本工程落点 | `resources/{base,en_US,zh_TW}/element/string.json` |

### 4.2 key 到资源名映射

| i18n key | 资源名 |
|----------|--------|
| `message.error.loginFailed` | `message_error_loginFailed` |
| `auth.login.title` | `auth_login_title` |

规则：`.` 全部替换为 `_`，其余字符原样保留。

### 4.3 资源目录语义

| 目录 | 语言 | 条目数 | 说明 |
|------|------|:--:|------|
| `base/` | 简体中文（默认） | 223 | 214 条语料 + 9 条既有系统资源合并 |
| `en_US/` | 英文 | 214 | 纯语料 |
| `zh_TW/` | 繁体中文（台湾） | 214 | 纯语料 |

### 4.4 语言 tag 与资源限定映射

| 语言 tag（`setAppPreferredLanguage`，连字符） | 资源限定（`Configuration.locale`，下划线） | 资源目录 |
|------|------|------|
| `zh-CN` | `zh_CN`（回退 `base`） | `base/` |
| `en-US` | `en_US` | `en_US/` |
| `zh-TW` | `zh_TW` | `zh_TW/` |

---

## 5. 验收场景

### 场景 1：后端 key 翻译

- Given：系统语言为简体中文，后端返回 `R.msg = "message.error.loginFailed"`。
- When：展示层调用 `I18n.t("message.error.loginFailed")`。
- Then：显示"登录失败"。

### 场景 2：三语言切换

- Given：系统语言依次设为 zh-CN、en-US、zh-TW。
- When：渲染页面并触发一次后端错误。
- Then：界面与后端消息分别显示中文、英文、繁体。

### 场景 3：未命中兜底

- Given：语料无 `message.error.notExist` 该 key。
- When：调用 `I18n.t("message.error.notExist")`。
- Then：返回原 key `"message.error.notExist"`，不抛异常。

### 场景 4：默认语言回退

- Given：系统语言为语料未覆盖的语言（如 ja-JP）。
- When：解析任意资源。
- Then：回退到 `base` 默认中文文案。

### 场景 5：应用内切换语言

- Given：当前语言为简体中文，进入个人中心。
- When：点击「切换语言」，选择 English。
- Then：个人中心界面与后端消息即时切换为英文，选择持久化，重启后仍为英文。

### 场景 6：切换后动态 key 即时生效

- Given：已切换为 en-US，后端返回 `R.msg = "message.error.loginFailed"`。
- When：触发一次登录失败。
- Then：`I18n.t` 经覆盖资源解析返回 "Login failed"，而非受系统语言缓存影响仍返回中文。

---

## 6. 非功能性需求

- NFR-I18N-001: 语料资源文件 MUST 为 UTF-8 编码。
- NFR-I18N-002: 未命中兜底 MUST 不抛异常、不影响主流程。
- NFR-I18N-003: 资源名 MUST 符合鸿蒙资源名规范（小写字母、数字、下划线）。

---

## 7. 假设与约束

| # | 假设 |
|---|------|
| A1 | 语料事实源由父工程 `i18n/` 维护，本工程不手工编辑生成物。 |
| A2 | 生成物由父工程 `sync-i18n.mjs` 生成，zh-CN 写入 `base/`（默认语言），en-US / zh-TW 写限定目录。 |
| A3 | 后端 tpl-app-api 已按父工程 FR-004-009 将 `R.msg` 改为返回 i18n key。 |
| A4 | 语言切换默认跟随系统，应用内可手动切换并持久化（父工程 FR-004-017）；动态 key 经覆盖资源解析即时生效。 |

---

## 8. 依赖

| 依赖 | 说明 |
|------|------|
| 父工程 `i18n/` | 语料事实源 + 生成/校验脚本 |
| tpl-app-api | 后端 `R.msg` 返回 key |
| 001-app-shell | `getContext()` 全局上下文、路由导航 |
| 002-user-auth / 101-profile | 消费翻译的页面与视图 |
| ../constitution.md | 本工程宪法原则（文档分工治理规则） |

# 规格文档索引

**项目名称：** tpl-workspace 鸿蒙App端（tpl-app-harmony）
**Bundle Name：** org.fellow99.tpl.TplAppHarmony
**版本：** 1.0.0
**技术栈：** ArkTS + ArkUI + HarmonyOS (API 5.1~6.1)
**文档生成时间：** 2026-08-12
**最后更新：** 2026-08-12

---

## 一、文档总览

| 层级 | 分类 | 文档数量 | 说明 |
|------|------|:--:|------|
| 整体 | 项目级顶层文档 | 6 | 架构、技术、宪法等全局文档 |
| 整体 | 整体规格文档 | 4 | overall-* 系列文档 |
| 模块 | 基础设施模块 | 2 | 001-app-shell（脚手架） |
| 模块 | 业务模块 | 6 | 002-user-auth + 101-profile |
| **合计** | **5 目录 / 18 文件** | **18** | |

---

## 二、项目级顶层文档

全局性的架构、技术、宪法等文档，定义项目基线和开发准则。

| 文档 | 路径 | 说明 |
|------|------|------|
| **方案总纲** | [ARCHITECTURE.md](./ARCHITECTURE.md) | 系统整体架构设计（HAP+HAR+HSP 分层） |
| **技术选型** | [TECH.md](./TECH.md) | 核心技术栈选型：ArkTS、ArkUI、Hvigor、Hypium |
| **宪法原则** | [constitution.md](./constitution.md) | 8 条项目开发原则与治理规则 |
| **项目结构** | [STRUCTURE.md](./STRUCTURE.md) | 源码目录结构、页面与路由清单 |
| **检查清单** | [SPECS_CHECKLIST.md](./SPECS_CHECKLIST.md) | 18 份规格文档完成度追踪 |

### 整体规格文档

描述跨模块的全局规格、方案和数据模型。

| 文档 | 路径 | 说明 |
|------|------|------|
| **整体规格** | [overall-spec.md](./overall-spec.md) | 系统级功能规格（5 个用户故事、20+ 功能需求） |
| **整体方案** | [overall-plan.md](./overall-plan.md) | 系统级技术方案（MVP 分阶段实现策略） |
| **数据模型** | [overall-data-model.md](./overall-data-model.md) | API 数据模型、本地状态模型数据字典 |
| **接口模型** | [overall-api.md](./overall-api.md) | 与后端 tpl-app-api 的 REST API 接口契约 |
| **测试用例索引** | [overall-test-cases.md](./overall-test-cases.md) | 全模块测试用例索引（共 39 条） |

---

## 三、基础设施模块（001）

### 001 — 应用脚手架（app-shell）

> 应用启动入口、页面路由导航、公共工具（Logger、BreakpointSystem）、响应式适配等基础能力。

| 文档 | 链接 | 说明 |
|------|------|------|
| 功能规格 | [001-app-shell/spec.md](./001-app-shell/spec.md) | 13 条功能需求，覆盖启动/路由/工具/适配/模块化 |
| 技术方案 | [001-app-shell/plan.md](./001-app-shell/plan.md) | 13 个核心文件清单，MVP 改造计划 |

---

## 四、业务模块（002 ~ 101）

### 002 — 用户认证（user-auth）


| 文档 | 链接 | 说明 |
|------|------|------|
| 功能规格 | [002-user-auth/spec.md](./002-user-auth/spec.md) | 23 条功能需求，4 个用户故事 |
| 技术方案 | [002-user-auth/plan.md](./002-user-auth/plan.md) | 页面结构设计、路由流程、加密实现方案 |
| 测试用例 | [002-user-auth/test-cases.md](./002-user-auth/test-cases.md) | 26 条 UI 功能测试用例 |

### 101 — 个人中心（profile）


| 文档 | 链接 | 说明 |
|------|------|------|
| 功能规格 | [101-profile/spec.md](./101-profile/spec.md) | 8 条功能需求，2 个用户故事 |
| 技术方案 | [101-profile/plan.md](./101-profile/plan.md) | 页面布局、四状态 UI、API 调用设计 |
| 测试用例 | [101-profile/test-cases.md](./101-profile/test-cases.md) | 13 条 UI 功能测试用例 |

---

## 五、模块编号一览

| 编号 | 模块名 | 英文名 | 分类 | 状态 |
|:--:|------|------|------|:--:|
| 001 | 应用脚手架 | app-shell | 基础设施 | 已实现 |
| 002 | 用户认证 | user-auth | 业务模块 | 待实现 |
| 101 | 个人中心 | profile | 业务模块 | 待实现 |


---

## 六、模块文档结构规范

每个模块目录 `NNN-name/` 下包含以下标准文档：

| 文件 | 命名 | 必填 | 说明 |
|------|------|:--:|------|
| 功能规格 | `spec.md` | ✅ | 定义模块的功能需求、用户故事、验收标准 |
| 技术方案 | `plan.md` | ✅ | 模块的技术实现方案、架构决策、组件设计 |
| 测试用例 | `test-cases.md` | 🔶 | 如模块包含前端 UI 交互则必须提供 |

---

## 七、快速导航

| 目标读者 | 推荐阅读顺序 |
|---------|-------------|
| **新加入开发者** | constitution.md → STRUCTURE.md → overall-spec.md → 具体模块 spec.md → plan.md |
| **架构师 / Tech Lead** | ARCHITECTURE.md → TECH.md → overall-plan.md → overall-api.md |
| **前端开发（鸿蒙）** | STRUCTURE.md → TECH.md → 001-app-shell/plan.md → 002-user-auth/plan.md → 101-profile/plan.md |
| **后端开发** | overall-api.md → overall-data-model.md |
| **测试 / QA** | overall-test-cases.md → 002-user-auth/test-cases.md → 101-profile/test-cases.md |
| **产品经理** | overall-spec.md → 各模块 spec.md |

---

## 八、关联工程

| 工程 | 路径 | 说明 |
|------|------|------|
| **后端 API** | `../tpl-app-api/` | Spring Boot 3.x REST API，提供认证和个人中心接口 |
| **Web 前端** | `../tpl-app-web/` | Vue 3 + TypeScript，模块划分和 UI 交互参考源 |
| **产品文档** | `../docs/` | 产品概念设计、功能模块设计、数据模型设计 |
| **设计系统** | `../DESIGN.md` | "破茧" 设计系统 v1.0，颜色/字体/间距规范 |
| **项目总览** | `../README.md` | tpl-workspace 项目总说明 |

---

## 九、父工程规范文档（tpl-workspace 产品线）

tpl-workspace产品线级规范文档位于父工程 `../../specs/`，用于理解本工程在整体产品中的定位与约束。

| 文档 | 链接 | 说明 |
|------|------|------|
| 父工程规范索引 | [../../specs/README.md](../../specs/README.md) | 产品线级规范文档索引（22 份） |
| 整体架构 | [../../specs/ARCHITECTURE.md](../../specs/ARCHITECTURE.md) | 产品线整体架构、子工程依赖关系、部署拓扑 |
| 宪法原则 | [../../specs/constitution.md](../../specs/constitution.md) | 产品线级开发原则（10 条） |
| 整体规格 | [../../specs/overall-spec.md](../../specs/overall-spec.md) | 系统级功能规格（6 大产品模块） |

---

**文档维护者：** tpl-workspace开发团队

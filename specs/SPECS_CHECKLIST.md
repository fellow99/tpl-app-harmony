# 规格文档完成度追踪

> 项目：tpl-app-harmony（tpl-workspace 鸿蒙App端）
> 最后更新：2026-08-12

## 整体进度

| 分类 | 总数 | 已完成 | 进度 |
|------|:--:|:--:|:--:|
| 项目级文档 | 10 | 10 | 100% |
| 模块文档 | 8 | 8 | 100% |
| **合计** | **18 文件** | **18** | **100%** |

---

## 一、项目级顶层文档

| # | 文档 | 路径 | 状态 | 备注 |
|---|------|------|:--:|------|
| P-01 | 目录结构 | [STRUCTURE.md](./STRUCTURE.md) | ✅ 已完成 | |
| P-02 | 技术选型 | [TECH.md](./TECH.md) | ✅ 已完成 | |
| P-03 | 系统架构 | [ARCHITECTURE.md](./ARCHITECTURE.md) | ✅ 已完成 | |
| P-04 | 宪法原则 | [constitution.md](./constitution.md) | ✅ 已完成 | |
| P-05 | 整体规格 | [overall-spec.md](./overall-spec.md) | ✅ 已完成 | |
| P-06 | 整体方案 | [overall-plan.md](./overall-plan.md) | ✅ 已完成 | |
| P-07 | 数据模型 | [overall-data-model.md](./overall-data-model.md) | ✅ 已完成 | |
| P-08 | 接口模型 | [overall-api.md](./overall-api.md) | ✅ 已完成 | |
| P-09 | 测试用例索引 | [overall-test-cases.md](./overall-test-cases.md) | ✅ 已完成 | |
| P-10 | 文档索引 | [README.md](./README.md) | ✅ 已完成 | Phase 3 最后生成 |

---

## 二、模块文档

### 001-app-shell（脚手架）

| # | 文档 | 路径 | 状态 | 备注 |
|---|------|------|:--:|------|
| M01-01 | 功能规格 | [001-app-shell/spec.md](./001-app-shell/spec.md) | ✅ 已完成 | 只需 spec + plan |
| M01-02 | 技术方案 | [001-app-shell/plan.md](./001-app-shell/plan.md) | ✅ 已完成 | |

### 002-user-auth（用户注册及登录）

| # | 文档 | 路径 | 状态 | 备注 |
|---|------|------|:--:|------|
| M02-01 | 功能规格 | [002-user-auth/spec.md](./002-user-auth/spec.md) | ✅ 已完成 | |
| M02-02 | 技术方案 | [002-user-auth/plan.md](./002-user-auth/plan.md) | ✅ 已完成 | |
| M02-03 | 测试用例 | [002-user-auth/test-cases.md](./002-user-auth/test-cases.md) | ✅ 已完成 | 前端UI测试用例 |

### 101-profile（个人中心）

| # | 文档 | 路径 | 状态 | 备注 |
|---|------|------|:--:|------|
| M03-01 | 功能规格 | [101-profile/spec.md](./101-profile/spec.md) | ✅ 已完成 | |
| M03-02 | 技术方案 | [101-profile/plan.md](./101-profile/plan.md) | ✅ 已完成 | |
| M03-03 | 测试用例 | [101-profile/test-cases.md](./101-profile/test-cases.md) | ✅ 已完成 | 前端UI测试用例 |

---

## 图例

| 标记 | 含义 |
|:--:|------|
| ⬜ | 待生成 |
| 🔄 | 生成中 |
| ✅ | 已完成 |

---

## 关联工程

| 工程 | 路径 | 说明 |
|------|------|------|
| tpl-app-api | `../tpl-app-api/` | 配套后端，提供 REST API |
| tpl-app-web | `../tpl-app-web/` | 配套 Web 前端，模块划分参考源 |
| docs | `../docs/` | 产品设计文档 |

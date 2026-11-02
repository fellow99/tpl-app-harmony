# AGENTS.md — tpl-app-harmony（鸿蒙客户端）

> 本文件为本子工程（`tpl-app-harmony/`）的 AI Agent 工作规范，是父工程 `tpl-workspace/AGENTS.md` 在本工程的具体化。
> 所有规范均基于本工程实际存在的技能、README 与 specs 编写。

---

## 一、项目简介

tpl-app-harmony 是「tpl-workspace」产品体系的**用户移动端鸿蒙客户端**，基于
**HarmonyOS 5.1~6.1 + ArkTS（Stage 模型）** 构建，提供用户注册、密码登录、个人中心等核心功能。

采用 **HAP + HAR + HSP** 多模块分层架构。

## 二、技术栈

| 层级 | 技术 |
|------|------|
| 系统 | HarmonyOS 5.1~6.1 |
| 语言 | ArkTS 6.1.0 |
| 构建 | Hvigor 6.1 |
| 测试 | Hypium 1.0.25 |
| 模块化 | HAP（产品入口）+ HAR（公共静态库）+ HSP |

## 三、代码结构

```
products/default (HAP — 可独立运行的产品入口)
    ├── @ohos/common (HAR — 公共工具：Logger、BreakpointSystem、CommonConstants)
    ├── @ohos/adaptivelayout (HAR — 自适应布局)
    └── @ohos/responsivelayout (HAR — 响应式布局)
```
详见 `README.md` 架构特点。

## 四、规格文档（specs）

`specs/` 下存放规格：`001-app-shell`、`002-user-auth`、`004-i18n`、`005-theme` 及系统文档
（`ARCHITECTURE.md`、`STRUCTURE.md`、`TECH.md`、`constitution.md`）。

## 五、常用开发命令

```bash
hvigorw clean && hvigorw assembleHap   # 构建 HAP
# 设备/模拟器安装、UI 测试见 harmonyos-app-testing 技能（hdc / aa start / bm install）
```

## 六、代码库探索规范（codegraph）

本工程已配置 codegraph 代码地图（`.codegraph/` 索引），并在 git `post-commit` 钩子中
自动增量更新（`codegraph sync`）。

- **提交后**无需手动操作，索引自动与 HEAD 保持同步。
- **探索代码**优先使用 codegraph，而非 grep/Read 循环：
  - `codegraph status` — 检查索引状态
  - `codegraph context "<任务>"` — 生成任务相关代码简报
  - `codegraph query <符号>` — 查找符号定义
  - `codegraph callers <符号>` / `codegraph callees <符号>` — 调用关系
  - `codegraph impact <符号>` — 变更影响范围
  - `codegraph files --filter <目录>` — 索引文件树
- 索引过期（切换分支/外部 pull）时手动 `codegraph sync` 增量更新。
- `codegraph` 查询不到时先 `sync` 再重查；确属 codegraph 不支持的语法（如部分 ArkTS/装饰器特性）才回退 grep。

> 索引目录 `.codegraph/` 已在 `.gitignore` 排除，不入库。

## 七、Git 提交规范

遵循父工程 `tpl-workspace/AGENTS.md` 的 Conventional Commits 规范，提交前加载 `git-commit` 技能。

## 八、开发流程与技能

- 鸿蒙开发**必须**使用 `harmonyos-app-dev` 技能（ArkTS/ArkUI/Stage 模型、代码审查、安全审计）。
- 鸿蒙测试/自动化**必须**使用 `harmonyos-app-testing` 技能（hdc 工具链）。
- 常规开发流程遵循父工程规范（`specs-based-devflow`、`requesting-code-review`、`systematic-debugging`）。
- 代码库探索一律走 **codegraph**（见第六节）。

---

> 维护者：fellow99 · 属「tpl-workspace 多端业务应用框架」

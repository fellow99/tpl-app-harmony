# 目录结构 (STRUCTURE)

> 项目：tpl-app-harmony（tpl-workspace 鸿蒙App端）
> 生成时间：2026-08-12
> 源码根目录：`D:\tpl-workspace\tpl-app-harmony\`

---

## 一、顶层目录结构

```
tpl-app-harmony/
├── .codegraph/                  # Codegraph 知识图谱索引
├── .git/                        # Git 版本控制
├── .gitignore                   # Git 忽略规则
├── .hvigor/                     # Hvigor 构建缓存
├── .idea/                       # IDE 配置
├── AppScope/                    # 应用全局配置
│   ├── app.json5                #   应用清单（bundleName、版本号）
│   └── resources/               #   全局资源（图标、字符串）
├── build-profile.json5          # 模块构建配置
├── code-linter.json5            # 代码检查配置
├── common/                      # 公共模块（共享工具）
│   ├── build-profile.json5      #
│   ├── consumer-rules.txt       #
│   ├── hvigorfile.ts            #
│   ├── Index.ets                #   模块导出入口
│   ├── obfuscation-rules.txt    #
│   ├── oh-package.json5         #   模块依赖声明
│   └── src/                     #
│       ├── main/ets/            #
│       │   ├── constants/       #     公共常量
│       │   │   └── CommonConstants.ets
│       │   └── utils/           #     公共工具
│       │       ├── BreakpointSystem.ets  #   响应式断点系统
│       │       └── Logger.ets            #   日志工具
│       └── test/                #   单元测试
├── features/                    # 功能特性模块
│   ├── adaptiveLayout/          #   自适应布局特性
│   │   ├── build-profile.json5  #
│   │   ├── hvigorfile.ts        #
│   │   ├── Index.ets            #     模块导出入口
│   │   ├── oh-package.json5     #
│   │   └── src/main/ets/        #
│   │       ├── constants/       #
│   │       ├── pages/           #       AdaptiveLayout.ets
│   │       └── view/            #       SliderComponent.ets
│   └── responsiveLayout/        #   响应式布局特性
│       ├── build-profile.json5  #
│       ├── hvigorfile.ts        #
│       ├── Index.ets            #     模块导出入口
│       ├── oh-package.json5     #
│       └── src/main/ets/        #
│           ├── constants/       #
│           ├── pages/           #       ResponsiveLayout.ets
│           └── view/            #       GridComponent.ets
├── hvigor/                      # Hvigor 构建配置
├── hvigorfile.ts                # 根构建配置
├── local.properties             # 本地环境配置
├── oh_modules/                  # 依赖模块（链接）
├── oh-package-lock.json5        # 依赖锁文件
├── oh-package.json5             # 根包配置
├── products/                    # 产品模块
│   └── default/                 #   默认产品
│       ├── build-profile.json5  #
│       ├── hvigorfile.ts        #
│       ├── obfuscation-rules.txt
│       ├── oh-package.json5     #     产品依赖
│       ├── oh_modules/          #
│       └── src/                 #
│           ├── main/ets/        #
│           │   ├── constants/   #
│           │   │   ├── CommonConstants.ets    # 公共UI常量
│           │   │   └── RouteConstants.ets     # 路由路径常量
│           │   ├── defaultability/
│           │   │   └── DefaultAbility.ets     # 应用入口Ability
│           │   ├── defaultbackupability/
│           │   │   └── DefaultBackupAbility.ets
│           │   ├── pages/       #     页面
│           │   │   ├── Index.ets                #   首页（目录导航）
│           │   │   ├── AdaptiveIndex.ets        #   自适应布局展示页
│           │   │   ├── ResponsiveIndex.ets      #   响应式布局展示页
│           │   │   └── SystemCapabilitiesIndex.ets  # 系统能力检测页
│           │   ├── view/        #     视图组件
│           │   │   └── CatalogueListComponent.ets   # 目录列表组件
│           │   └── viewmodel/   #     视图模型
│           │       ├── CatalogueItemData.ets    #   目录项数据模型
│           │       └── CatalogueViewModel.ets   #   目录视图模型
│           ├── ohosTest/        #   自动化测试
│           └── test/            #   单元测试
├── README.md                    # 项目说明
└── specs/                       # 规格文档（本文档目录）
```

---

## 二、页面/路由清单

### 2.1 当前已实现的页面（脚手架模板）

| 路由路径 | 页面组件 | 说明 | 入口方式 |
|----------|----------|------|----------|
| `pages/Index` | `Index.ets` | 应用首页，目录导航列表 | `DefaultAbility.loadContent()` |
| `pages/ResponsiveIndex` | `ResponsiveIndex.ets` | 响应式布局演示页 | 首页列表点击跳转 |
| `pages/AdaptiveIndex` | `AdaptiveIndex.ets` | 自适应布局演示页 | 首页列表点击跳转 |
| `pages/SystemCapabilitiesIndex` | `SystemCapabilitiesIndex.ets` | 系统能力检测页 | 首页列表点击跳转 |

### 2.2 路由常量定义

定义于 `products/default/src/main/ets/constants/RouteConstants.ets`：

| 常量 | 值 | 说明 |
|------|-----|------|
| `RESPONSIVE_ROUTE` | `'pages/ResponsiveIndex'` | 响应式布局路由 |
| `ADAPTIVE_ROUTE` | `'pages/AdaptiveIndex'` | 自适应布局路由 |
| `SYSTEM_CAPABILITIES_ROUTE` | `'pages/SystemCapabilitiesIndex'` | 系统能力检测路由 |

### 2.3 待实现的业务页面（规划中）

以下页面为本次规格文档规划的业务页面，尚未在代码中实现：

| 模块 | 建议路由 | 页面 | 说明 |
|------|----------|------|------|
| 002-user-auth | `pages/LoginPage` | 登录页 | 密码登录 + 短信登录 + 微信登录 |
| 002-user-auth | `pages/RegisterPage` | 注册页 | 用户名 + 密码选择 |
| 002-user-auth | `pages/ProfilePage` | 个人中心 | 个人信息查看与编辑 |
| 101-profile | `pages/ProfileIndex` | 个人中心首页 | 仪表盘 |

---

## 三、模块依赖关系

```
products/default
  ├── @ohos/common          (公共工具模块)
  ├── @ohos/adaptivelayout  (自适应布局模块)
  └── @ohos/responsivelayout (响应式布局模块)

features/adaptiveLayout
  └── @ohos/common

features/responsiveLayout
  └── @ohos/common
```

---

## 四、关键配置文件

| 文件 | 路径 | 说明 |
|------|------|------|
| 应用清单 | `AppScope/app.json5` | bundleName、版本号、图标 |
| 构建配置 | `build-profile.json5` | 模块注册、SDK版本、签名配置 |
| 根包配置 | `oh-package.json5` | 工程级依赖声明 |
| 产品配置 | `products/default/oh-package.json5` | 产品模块依赖 |
| 公共模块配置 | `common/oh-package.json5` | 公共模块声明 |

---

## 五、源码统计

| 类别 | 文件数 | 说明 |
|------|:--:|------|
| `.ets` ArkTS源码 | 15 | 不含 `oh_modules` 副本 |
| `.json5` 配置文件 | 8 | |
| `.ts` TypeScript | 5 | hvigorfile |
| `.txt` / 其他 | 6 | obfuscation、consumer、gitignore 等 |
| **合计** | **~34** | 不计 node_modules/oh_modules |

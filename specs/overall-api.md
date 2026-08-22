# 接口模型 (overall-api)

> 项目：tpl-app-harmony（tpl-workspace 鸿蒙App端）
> 版本：v1.0.0
> 最后更新：2026-08-12

---

## 一、说明

本文档定义 tpl-app-harmony 与后端 tpl-app-api 之间的 REST API 接口契约。

后端 API 地址通过配置管理，开发环境默认指向本地服务。

---

## 二、认证接口

### 2.1 获取图形验证码

```
GET /auth/code

Response:
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "uuid": "abc123def456",
    "img": "data:image/png;base64,..."
  }
}
```

### 2.2 用户注册

```
POST /auth/register
Content-Type: application/json
Encrypt: AES+RSA

Request (AES 加密前):
{
  "username": "zhangsan",
  "password": "******",
  "code": "abcd",
  "uuid": "abc123"
}

Response (成功):
{
  "code": 200,
  "msg": "注册成功"
}
```

### 2.3 用户登录（密码）

```
POST /auth/login
Content-Type: application/json
Encrypt: AES+RSA

Request (AES 加密前):
{
  "username": "zhangsan",
  "password": "******",
  "code": "abcd",
  "uuid": "abc123",
  "clientId": "app",
  "grantType": "password"
}

Response (成功):
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "access_token": "sa-token-xxx...",
    "expire_in": 7200,
    "client_id": "app"
  }
}
```

### 2.4 退出登录

```
POST /auth/logout
Authorization: Bearer {token}

Response:
{
  "code": 200,
  "msg": "退出成功"
}
```

### 2.5 获取用户信息

```
GET /system/user/getInfo
Authorization: Bearer {token}

Response:
{
  "code": 200,
  "data": {
    "userId": 1,
    "userName": "zhangsan",
    "nickName": "张三",
    "avatar": "/profile/avatar/xxx.jpg"
  }
}
```

---

## 三、个人中心接口


```
Authorization: Bearer {token}

Response (有数据):
{
  "code": 200,
  "data": {
    "totalErrorQuestions": 156
  }
}

Response (无数据):
{
  "code": 200,
  "data": {
    "totalErrorQuestions": 0
  }
}
```

---

## 四、通用约定

### 4.1 请求头

| 头部 | 值 | 说明 |
|------|-----|------|
| `Authorization` | `Bearer {token}` | 认证令牌（登录后所有请求携带） |
| `Content-Type` | `application/json` | 请求体格式 |
| `clientid` | `app` | 客户端标识 |

### 4.2 错误码

| code | 含义 | 前端处理 |
|:--:|------|----------|
| 200 | 成功 | 正常处理 data |
| 401 | 未认证/Token过期 | 清除 Token，跳转登录页 |
| 500 | 服务器错误 | 显示错误提示 |

### 4.3 加密约定

登录和注册接口的请求体使用 AES+RSA 混合加密（与 tpl-app-web 一致）：
1. 生成随机 AES 密钥
2. 使用 AES 密钥加密请求体
3. 使用 RSA 公钥加密 AES 密钥
4. 将加密后的数据和加密后的密钥一起发送

> 具体实现参考 tpl-app-web 的加密逻辑。

---

## 五、参考

| 文档 | 路径 |
|------|------|
| 用户模块设计（含详细接口定义） | `../docs/002-用户注册及登录设计.md` |
| 个人中心设计 | `../docs/101-个人中心.md` |
| Web端 API 实现 | `../tpl-app-web/src/api/` |

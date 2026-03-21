# Walkthrough - 攻击指南 🔓

> ⚠️ 仅用于学习目的！请在合法授权的环境下进行测试。

## 1. SQL 注入 - 登录页 (`/login/`)

### Low
万能密码，直接绕过登录：
- 用户名：`' OR 1=1 --`
- 密码：随便填

或者：
- 用户名：`admin' --`
- 密码：随便填

### Medium
单引号被过滤了，但可以用其他方式：
- 尝试双重编码
- 使用 `\` 转义绕过

### High
使用了 PreparedStatement，无法注入。

---

## 2. SQL 注入 + XSS - 课表查询 (`/schedule/`)

### Low - SQL Injection
输入：`' UNION SELECT 1,2,username,password FROM users --`

### Low - Reflected XSS
班级输入框输入：`<script>alert('XSS')</script>`

### Medium
`<` 被替换为 `&lt;`，但可以尝试其他 XSS 向量。
单引号被转义但可能有绕过方式。

### High
参数化查询 + 输出编码，安全。

---

## 3. 越权访问 - 成绩查询 (`/grades/`)

### Low
无需登录即可查询任意学生成绩：
- 直接输入学号 `2009001`、`2009002`、`2009003`

还可以 SQL 注入：
- `2009001' UNION SELECT 1,username,password,role,'a','b' FROM users --`

### Medium
需要登录，但任何登录用户都可以查看其他学生的成绩（IDOR）。

### High
学生只能查看自己的成绩，教师和管理员可以查看所有。

---

## 4. 存储型 XSS - 通知公告 (`/notice/`)

### Low
在标题或内容中插入：
```html
<script>alert(document.cookie)</script>
```
所有查看该通知的用户都会触发。

### Medium
`<script>` 标签被过滤，但大小写混合可以绕过：
```html
<Script>alert('XSS')</Script>
<img src=x onerror="alert('XSS')">
<svg onload="alert('XSS')">
```

### High
所有 HTML 标签都被编码，安全。

---

## 5. 文件上传 (`/upload/`)

### Low
- 直接上传 JSP webshell
- 上传后访问 `http://target:8080/school/upload/files/shell.jsp`
- 可执行任意命令

### Medium
- 客户端 JS 验证，用 Burp Suite 拦截请求绕过
- 或直接用 curl 发送 POST 请求

### High
- 服务端白名单验证
- 文件重命名为随机名
- 存储在非 Web 目录

---

## 6. 未授权访问 - 后台管理 (`/admin/`)

### Low
- 直接访问 `/admin/index.jsp`，无需登录
- 管理后台直接显示所有用户的明文密码
- 泄露系统路径、Java 版本等敏感信息

### Medium
- 需要登录但不检查角色
- 用 `student1/student1` 登录也能访问管理后台

### High
- 需要 admin 角色才能访问

---

## 7. Tomcat 默认管理后台

### 额外漏洞
- 访问 `http://target:8080/admin/` — Tomcat Admin Console
- 访问 `http://target:8080/manager/html` — Tomcat Manager
- 默认凭据：`admin/admin`、`tomcat/tomcat`、`manager/manager`

---

## 工具推荐

- **Burp Suite** — Web 代理抓包
- **sqlmap** — 自动化 SQL 注入
- **nmap** — 端口扫描
- **dirbuster** — 目录枚举
- **nikto** — Web 漏洞扫描

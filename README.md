# Legacy Vuln Lab 🏫

> 模拟国内体制内老旧服务器场景的安全靶场

**"某某高中教务管理系统 v2.0"** — 一个故意写满漏洞的 Web 应用，用于学习 Web 安全攻防。

## 🎯 靶场特色

- 基于 **Windows XP + Tomcat 5.5 + JDK 1.6 + MySQL 5.0**，还原真实老旧环境
- 每个漏洞模块支持 **Low / Medium / High** 三档难度切换
- 前端风格还原 2009 年体制内系统审美（蓝色渐变 + 宋体 + 表格布局）

## 📋 漏洞模块

| 模块 | 漏洞类型 | 路径 |
|------|---------|------|
| 登录页 | SQL 注入 | `/login/` |
| 课表查询 | SQL 注入 + XSS | `/schedule/` |
| 成绩查询 | 越权访问 | `/grades/` |
| 通知公告 | 存储型 XSS | `/notice/` |
| 文件上传 | 任意文件上传 | `/upload/` |
| 后台管理 | 弱口令 + 未授权 | `/admin/` |

## 🔧 环境要求

- Windows XP SP3（推荐 VMware 虚拟机）
- JDK 1.6（推荐 6u45）
- Apache Tomcat 5.5
- MySQL 5.0

## 🚀 部署步骤

### 1. 初始化数据库

```sql
mysql -u root -p < sql/init.sql
```

### 2. 配置数据库连接

编辑 `webapp/WEB-INF/web.xml`，修改数据库连接信息。

### 3. 部署到 Tomcat

将 `webapp` 文件夹复制到 Tomcat 的 `webapps` 目录下，重命名为 `school`：

```cmd
xcopy /E /I webapp C:\tomcat5.5\webapps\school
```

### 4. 启动 Tomcat

```cmd
C:\tomcat5.5\bin\startup.bat
```

### 5. 访问

浏览器打开 `http://localhost:8080/school/`

## 🔑 默认账号

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | goz123 | 管理员 |
| teacher1 | 123456 | 教师 |
| student1 | student1 | 学生 |

## 📖 难度说明

- **Low**：无任何防御，可直接利用漏洞
- **Medium**：有基本过滤（黑名单），但可以绕过
- **High**：接近真实防御（白名单 + 参数化查询），需要组合技

通过 URL 参数 `?difficulty=low|medium|high` 切换难度，默认为 `low`。

## ⚠️ 免责声明

本项目仅供安全学习和研究使用。请勿将所学技术用于非法活动。使用本靶场即表示您同意仅在合法授权的环境下进行测试。

## 📜 License

MIT

## 🏗️ Contributors

- [WeepingDogel](https://github.com/WeepingDogel)
- [Claudius](https://github.com/EnsueCollectR)

---

*Copyright © 2009 Goz High School 信息中心* 😂

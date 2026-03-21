<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>后台管理 - 某某高中教务管理系统</title>
<link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="header">
    <h1>某某高中教务管理系统 v2.0</h1>
    <span class="subtitle">Goz High School Educational Management System — 管理后台</span>
</div>

<div class="navbar">
    <a href="../index.jsp">首页</a>
    <a href="../schedule/index.jsp">课表查询</a>
    <a href="../grades/index.jsp">成绩查询</a>
    <a href="../notice/index.jsp">通知公告</a>
    <a href="../upload/index.jsp">文件上传</a>
    <a href="index.jsp" class="active">后台管理</a>
</div>

<div class="content">
<%
    String difficulty = (String) session.getAttribute("difficulty");
    if (difficulty == null) { difficulty = "low"; session.setAttribute("difficulty", difficulty); }
%>

<div class="difficulty-bar">
    当前安全级别：<b><%= difficulty.toUpperCase() %></b>
    | <a href="../setup.jsp">修改设置</a>
</div>

<%
    if ("low".equals(difficulty)) {
        // LOW: No authentication check at all - anyone can access admin panel
    } else if ("medium".equals(difficulty)) {
        // MEDIUM: Checks if logged in, but doesn't check role
        String loggedUser = (String) session.getAttribute("username");
        if (loggedUser == null) {
            out.println("<p class='error'>请先登录。</p>");
            out.println("<p><a href='../login/index.jsp?difficulty=" + difficulty + "'>去登录</a></p>");
            return;
        }
    } else {
        // HIGH: Checks login + admin role
        String loggedUser = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");
        if (loggedUser == null) {
            out.println("<p class='error'>请先登录。</p>");
            out.println("<p><a href='../login/index.jsp?difficulty=" + difficulty + "'>去登录</a></p>");
            return;
        }
        if (!"admin".equals(role)) {
            out.println("<p class='error'>权限不足，仅管理员可访问。</p>");
            return;
        }
    }
%>

<h2>系统管理后台</h2>

<table width="100%">
<tr>
<td width="50%" valign="top">

    <h3 style="font-size: 12px; color: #1B5FAA;">📊 系统统计</h3>
    <%
        Connection conn = null;
        try {
            Class.forName("com.mysql.jdbc.Driver");
            String dbUrl = application.getInitParameter("db.url");
            String dbUser = application.getInitParameter("db.user");
            String dbPass = application.getInitParameter("db.password");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            Statement stmt = conn.createStatement();
    %>
    <table class="data-table" width="80%">
        <tr><th>项目</th><th>数量</th></tr>
        <%
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as cnt FROM users");
            rs.next();
        %>
        <tr><td>注册用户</td><td><%=rs.getInt("cnt")%></td></tr>
        <%
            rs = stmt.executeQuery("SELECT COUNT(*) as cnt FROM students");
            rs.next();
        %>
        <tr><td>学生档案</td><td><%=rs.getInt("cnt")%></td></tr>
        <%
            rs = stmt.executeQuery("SELECT COUNT(*) as cnt FROM notices");
            rs.next();
        %>
        <tr><td>通知公告</td><td><%=rs.getInt("cnt")%></td></tr>
        <%
            rs = stmt.executeQuery("SELECT COUNT(*) as cnt FROM uploads");
            rs.next();
        %>
        <tr><td>上传文件</td><td><%=rs.getInt("cnt")%></td></tr>
    </table>
    <%
            rs.close();
            stmt.close();
        } catch (Exception e) {
            out.println("<p class='error'>统计加载失败</p>");
        } finally {
            try { if (conn != null) conn.close(); } catch(Exception e) {}
        }
    %>

</td>
<td width="50%" valign="top">

    <h3 style="font-size: 12px; color: #1B5FAA;">👤 用户列表</h3>
    <%
        Connection conn2 = null;
        try {
            Class.forName("com.mysql.jdbc.Driver");
            String dbUrl = application.getInitParameter("db.url");
            String dbUser = application.getInitParameter("db.user");
            String dbPass = application.getInitParameter("db.password");
            conn2 = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            Statement stmt = conn2.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM users ORDER BY id");
    %>
    <table class="data-table">
        <tr>
            <th>ID</th>
            <th>用户名</th>
            <% if ("low".equals(difficulty)) { %>
                <th>密码</th>
            <% } %>
            <th>角色</th>
            <th>姓名</th>
        </tr>
        <%
            while (rs.next()) {
        %>
        <tr>
            <td><%=rs.getInt("id")%></td>
            <td><%=rs.getString("username")%></td>
            <% if ("low".equals(difficulty)) { %>
                <!-- LOW: Passwords visible in admin panel! -->
                <td><%=rs.getString("password")%></td>
            <% } %>
            <td><%=rs.getString("role")%></td>
            <td><%=rs.getString("real_name")%></td>
        </tr>
        <%
            }
        %>
    </table>
    <%
            rs.close();
            stmt.close();
        } catch (Exception e) {
            out.println("<p class='error'>用户列表加载失败</p>");
        } finally {
            try { if (conn2 != null) conn2.close(); } catch(Exception e) {}
        }
    %>

</td>
</tr>
</table>

<br>

<h3 style="font-size: 12px; color: #1B5FAA;">⚙️ 系统信息</h3>
<table class="data-table" width="60%">
    <tr><td>Java 版本</td><td><%=System.getProperty("java.version")%></td></tr>
    <tr><td>操作系统</td><td><%=System.getProperty("os.name")%> <%=System.getProperty("os.version")%></td></tr>
    <tr><td>服务器信息</td><td><%=application.getServerInfo()%></td></tr>
    <tr><td>数据库</td><td>MySQL 5.0</td></tr>
    <% if ("low".equals(difficulty)) { %>
        <!-- LOW: Expose sensitive system properties -->
        <tr><td>Java Home</td><td><%=System.getProperty("java.home")%></td></tr>
        <tr><td>用户目录</td><td><%=System.getProperty("user.dir")%></td></tr>
        <tr><td>系统路径</td><td><%=System.getProperty("java.class.path")%></td></tr>
    <% } %>
</table>

</div>

<div class="footer">
    Copyright &copy; 2009 Goz High School 信息中心 All Rights Reserved.
</div>

</body>
</html>

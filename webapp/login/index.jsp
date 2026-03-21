<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>用户登录 - 狗子高中教务管理系统</title>
<link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="header">
    <h1>狗子高中教务管理系统 v2.0</h1>
    <span class="subtitle">Goz High School Educational Management System</span>
</div>

<div class="navbar">
    <a href="../index.jsp">首页</a>
    <a href="../schedule/index.jsp">课表查询</a>
    <a href="../grades/index.jsp">成绩查询</a>
    <a href="../notice/index.jsp">通知公告</a>
    <a href="../upload/index.jsp">文件上传</a>
    <a href="../admin/index.jsp">后台管理</a>
    <a href="index.jsp" class="active" style="float:right;">登录</a>
</div>

<div class="content">
<% request.setCharacterEncoding("UTF-8"); %>
<%
    // Get difficulty level
    String difficulty = (String) session.getAttribute("difficulty");
    if (difficulty == null) { difficulty = "low"; session.setAttribute("difficulty", difficulty); }
%>

<div class="difficulty-bar">
    当前安全级别：<b><%= difficulty.toUpperCase() %></b>
    | <a href="../setup.jsp">修改设置</a>
</div>

<div class="form-box">
    <h3>用户登录</h3>

    <%
        String errorMsg = "";
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username != null && password != null) {
            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.jdbc.Driver");
                String dbUrl = application.getInitParameter("db.url");
                String dbUser = application.getInitParameter("db.user");
                String dbPass = application.getInitParameter("db.password");
                conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

                if ("low".equals(difficulty)) {
                    // LOW: Direct string concatenation - classic SQL injection
                    String sql = "SELECT * FROM users WHERE username='" + username + "' AND password='" + password + "'";
                    stmt = conn.createStatement();
                    rs = stmt.executeQuery(sql);

                } else if ("medium".equals(difficulty)) {
                    // MEDIUM: Basic blacklist filtering (bypassable)
                    username = username.replace("'", "");
                    username = username.replace("--", "");
                    username = username.replace("#", "");
                    password = password.replace("'", "");

                    String sql = "SELECT * FROM users WHERE username='" + username + "' AND password='" + password + "'";
                    stmt = conn.createStatement();
                    rs = stmt.executeQuery(sql);

                } else {
                    // HIGH: Parameterized query (proper defense)
                    String sql = "SELECT * FROM users WHERE username=? AND password=?";
                    PreparedStatement pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, username);
                    pstmt.setString(2, password);
                    rs = pstmt.executeQuery();
                }

                if (rs.next()) {
                    session.setAttribute("username", rs.getString("username"));
                    session.setAttribute("role", rs.getString("role"));
                    session.setAttribute("real_name", rs.getString("real_name"));
                    response.sendRedirect("../index.jsp");
                    return;
                } else {
                    errorMsg = "用户名或密码错误！";
                }

            } catch (Exception e) {
                // LOW: Show full error message (information disclosure)
                if ("low".equals(difficulty)) {
                    errorMsg = "数据库错误: " + e.getMessage();
                } else {
                    errorMsg = "登录失败，请重试。";
                }
            } finally {
                try { if (rs != null) rs.close(); } catch(Exception e) {}
                try { if (stmt != null) stmt.close(); } catch(Exception e) {}
                try { if (conn != null) conn.close(); } catch(Exception e) {}
            }
        }
    %>

    <% if (!"".equals(errorMsg)) { %>
        <p class="error"><%=errorMsg%></p>
    <% } %>

    <form method="POST" action="index.jsp">
        <label>用户名：</label>
        <input type="text" name="username" value="<%=username != null ? username : ""%>">
        <label>密&nbsp;&nbsp;&nbsp;码：</label>
        <input type="password" name="password">
        <br>
        <input type="submit" value="登  录">
    </form>

    <p style="font-size: 11px; color: #999; margin-top: 10px; text-align: center;">
        没有账号？<a href="register.jsp">注册新用户</a><br><br>
        默认管理员账号：admin<br>
        如忘记密码请联系信息中心
    </p>
</div>

</div>

<div class="footer">
    Copyright &copy; 2009 Goz High School 信息中心 All Rights Reserved.
</div>

</body>
</html>

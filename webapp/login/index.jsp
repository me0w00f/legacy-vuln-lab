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
<%@ include file="/WEB-INF/difficulty.jsp" %>

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

                } else if ("high".equals(difficulty)) {
                    // HIGH: Parameterized query (proper defense)
                    String sql = "SELECT * FROM users WHERE username=? AND password=?";
                    PreparedStatement pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, username);
                    pstmt.setString(2, password);
                    rs = pstmt.executeQuery();
                } else {
                    // IMPOSSIBLE: Parameterized + account lockout after 3 failed attempts
                    // Check if account is locked
                    PreparedStatement lockCheck = conn.prepareStatement(
                        "SELECT failed_attempts, locked_until FROM users WHERE username=?");
                    lockCheck.setString(1, username);
                    ResultSet lockRs = lockCheck.executeQuery();
                    if (lockRs.next()) {
                        int attempts = lockRs.getInt("failed_attempts");
                        java.sql.Timestamp lockedUntil = lockRs.getTimestamp("locked_until");
                        if (lockedUntil != null && lockedUntil.after(new java.sql.Timestamp(System.currentTimeMillis()))) {
                            errorMsg = "账户已锁定，请15分钟后再试。";
                            lockRs.close();
                            lockCheck.close();
                        } else {
                            lockRs.close();
                            lockCheck.close();
                            // Attempt login
                            String sql = "SELECT * FROM users WHERE username=? AND password=?";
                            PreparedStatement pstmt = conn.prepareStatement(sql);
                            pstmt.setString(1, username);
                            pstmt.setString(2, password);
                            rs = pstmt.executeQuery();
                            if (!rs.next()) {
                                // Increment failed attempts
                                PreparedStatement failStmt = conn.prepareStatement(
                                    "UPDATE users SET failed_attempts = COALESCE(failed_attempts,0) + 1 WHERE username=?");
                                failStmt.setString(1, username);
                                failStmt.executeUpdate();
                                failStmt.close();
                                if (attempts >= 2) {
                                    // Lock account for 15 minutes
                                    PreparedStatement lockStmt = conn.prepareStatement(
                                        "UPDATE users SET locked_until = DATE_ADD(NOW(), INTERVAL 15 MINUTE) WHERE username=?");
                                    lockStmt.setString(1, username);
                                    lockStmt.executeUpdate();
                                    lockStmt.close();
                                    errorMsg = "连续登录失败3次，账户已锁定15分钟。";
                                } else {
                                    errorMsg = "用户名或密码错误！剩余尝试次数：" + (2 - attempts);
                                }
                                rs = null;
                            } else {
                                // Reset failed attempts on success
                                PreparedStatement resetStmt = conn.prepareStatement(
                                    "UPDATE users SET failed_attempts = 0, locked_until = NULL WHERE username=?");
                                resetStmt.setString(1, username);
                                resetStmt.executeUpdate();
                                resetStmt.close();
                            }
                        }
                    } else {
                        lockRs.close();
                        lockCheck.close();
                        errorMsg = "用户名或密码错误！";
                    }
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

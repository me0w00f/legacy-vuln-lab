<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>用户注册 - 狗子高中教务管理系统</title>
<link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="header">
    <h1>狗子高中教务管理系统 v2.0</h1>
    <span class="subtitle">Goz High School Educational Management System</span>
</div>

<div class="navbar">
    <a href="../index.jsp">首页</a>
    <a href="index.jsp">登录</a>
    <a href="register.jsp" class="active">注册</a>
</div>

<div class="content">
<% request.setCharacterEncoding("UTF-8"); %>

<div class="form-box" style="width: 400px;">
    <h3>新用户注册</h3>

<%@ include file="/WEB-INF/difficulty.jsp" %>
<%

        String errorMsg = "";
        String successMsg = "";
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String realName = request.getParameter("real_name");

        if (username != null && password != null) {
            if ("".equals(username.trim()) || "".equals(password.trim())) {
                errorMsg = "用户名和密码不能为空！";
            } else {
                Connection conn = null;
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    String dbUrl = application.getInitParameter("db.url");
                    String dbUser = application.getInitParameter("db.user");
                    String dbPass = application.getInitParameter("db.password");
                    conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

                    if ("low".equals(difficulty)) {
                        // LOW: SQL injection in INSERT, no input validation
                        Statement stmt = conn.createStatement();
                        String sql = "INSERT INTO users (username, password, role, real_name) VALUES ('" + username + "', '" + password + "', 'student', '" + (realName != null ? realName : "") + "')";
                        stmt.executeUpdate(sql);
                        stmt.close();
                    } else if ("medium".equals(difficulty)) {
                        // MEDIUM: Parameterized but no password complexity check
                        PreparedStatement pstmt = conn.prepareStatement(
                            "INSERT INTO users (username, password, role, real_name) VALUES (?, ?, 'student', ?)");
                        pstmt.setString(1, username);
                        pstmt.setString(2, password);
                        pstmt.setString(3, realName != null ? realName : "");
                        pstmt.executeUpdate();
                        pstmt.close();
                    } else {
                        // HIGH: Parameterized + password complexity + username uniqueness check
                        if (password.length() < 8) {
                            errorMsg = "密码长度至少8位！";
                        } else {
                            // Check if username exists
                            PreparedStatement checkStmt = conn.prepareStatement("SELECT id FROM users WHERE username = ?");
                            checkStmt.setString(1, username);
                            ResultSet checkRs = checkStmt.executeQuery();
                            if (checkRs.next()) {
                                errorMsg = "用户名已存在！";
                            } else {
                                PreparedStatement pstmt = conn.prepareStatement(
                                    "INSERT INTO users (username, password, role, real_name) VALUES (?, ?, 'student', ?)");
                                pstmt.setString(1, username);
                                pstmt.setString(2, password);
                                pstmt.setString(3, realName != null ? realName : "");
                                pstmt.executeUpdate();
                                pstmt.close();
                            }
                            checkRs.close();
                            checkStmt.close();
                        }
                    }

                    if ("".equals(errorMsg)) {
                        successMsg = "注册成功！请返回登录。";
                    }
                } catch (Exception e) {
                    if ("low".equals(difficulty)) {
                        errorMsg = "注册失败: " + e.getMessage();
                    } else {
                        errorMsg = "注册失败，请重试。";
                    }
                } finally {
                    try { if (conn != null) conn.close(); } catch(Exception e) {}
                }
            }
        }
    %>

    <% if (!"".equals(errorMsg)) { %>
        <p class="error"><%=errorMsg%></p>
    <% } %>
    <% if (!"".equals(successMsg)) { %>
        <p class="success"><%=successMsg%></p>
    <% } %>

    <form method="POST" action="register.jsp">
        <label>用户名：</label>
        <input type="text" name="username" value="<%=username != null ? username : ""%>">
        <label>密&nbsp;&nbsp;&nbsp;码：</label>
        <input type="password" name="password">
        <label>姓&nbsp;&nbsp;&nbsp;名：</label>
        <input type="text" name="real_name" value="<%=realName != null ? realName : ""%>">
        <br>
        <input type="submit" value="注  册">
    </form>

    <p style="font-size: 11px; color: #999; margin-top: 10px; text-align: center;">
        已有账号？<a href="index.jsp">返回登录</a>
    </p>
</div>

</div>

<div class="footer">
    Copyright &copy; 2009 Goz High School 信息中心 All Rights Reserved.
</div>

</body>
</html>

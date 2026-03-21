<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/auth_check.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>个人信息 - 狗子高中教务管理系统</title>
<link rel="stylesheet" href="../css/style.css">
</head>
<body>
<% request.setCharacterEncoding("UTF-8"); %>

<div class="header">
    <h1>狗子高中教务管理系统 v2.0</h1>
    <span class="subtitle">Goz High School Educational Management System</span>
</div>

<div class="navbar">
    <a href="../index.jsp">首页</a>
    <a href="../schedule/index.jsp">课表查询</a>
    <a href="../grades/index.jsp">成绩查询</a>
    <a href="../notice/index.jsp">通知公告</a>
    <a href="index.jsp" class="active">个人信息</a>
    <a href="../admin/index.jsp">后台管理</a>
</div>

<div class="content">
<%
    <%@ include file="/WEB-INF/difficulty.jsp" %>
<%
    // difficulty loaded from database via include
%>

    String loggedUser = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    String realName = (String) session.getAttribute("real_name");
%>

<div class="difficulty-bar">
    当前安全级别：<b><%= difficulty.toUpperCase() %></b>
    | <a href="../setup.jsp">修改设置</a>
</div>

<h2>个人信息</h2>

<%
    Connection conn = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        String dbUrl = application.getInitParameter("db.url");
        String dbUser = application.getInitParameter("db.user");
        String dbPass = application.getInitParameter("db.password");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // Handle password change
        String action = request.getParameter("action");
        if ("change_password".equals(action)) {
            String oldPwd = request.getParameter("old_password");
            String newPwd = request.getParameter("new_password");

            if ("low".equals(difficulty)) {
                // LOW: SQL injection in password change + no old password verification
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("UPDATE users SET password='" + newPwd + "' WHERE username='" + loggedUser + "'");
                stmt.close();
                out.println("<p class='success'>密码修改成功！</p>");
            } else if ("medium".equals(difficulty)) {
                // MEDIUM: Checks old password but still vulnerable to SQL injection
                Statement stmt = conn.createStatement();
                ResultSet checkRs = stmt.executeQuery("SELECT id FROM users WHERE username='" + loggedUser + "' AND password='" + oldPwd + "'");
                if (checkRs.next()) {
                    stmt.executeUpdate("UPDATE users SET password='" + newPwd + "' WHERE username='" + loggedUser + "'");
                    out.println("<p class='success'>密码修改成功！</p>");
                } else {
                    out.println("<p class='error'>旧密码错误！</p>");
                }
                checkRs.close();
                stmt.close();
            } else {
                // HIGH: Parameterized + old password check + complexity
                if (newPwd.length() < 8) {
                    out.println("<p class='error'>新密码长度至少8位！</p>");
                } else {
                    PreparedStatement checkStmt = conn.prepareStatement("SELECT id FROM users WHERE username=? AND password=?");
                    checkStmt.setString(1, loggedUser);
                    checkStmt.setString(2, oldPwd);
                    ResultSet checkRs = checkStmt.executeQuery();
                    if (checkRs.next()) {
                        PreparedStatement updateStmt = conn.prepareStatement("UPDATE users SET password=? WHERE username=?");
                        updateStmt.setString(1, newPwd);
                        updateStmt.setString(2, loggedUser);
                        updateStmt.executeUpdate();
                        updateStmt.close();
                        out.println("<p class='success'>密码修改成功！</p>");
                    } else {
                        out.println("<p class='error'>旧密码错误！</p>");
                    }
                    checkRs.close();
                    checkStmt.close();
                }
            }
        }

        // Handle profile update
        if ("update_profile".equals(action)) {
            String newName = request.getParameter("real_name");
            String newPhone = request.getParameter("phone");

            if ("low".equals(difficulty)) {
                // LOW: SQL injection in UPDATE + can change any field
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("UPDATE users SET real_name='" + newName + "' WHERE username='" + loggedUser + "'");
                stmt.close();
                session.setAttribute("real_name", newName);

                // Also update student/teacher phone
                if ("student".equals(role)) {
                    stmt = conn.createStatement();
                    stmt.executeUpdate("UPDATE students SET phone='" + newPhone + "' WHERE user_id=(SELECT id FROM users WHERE username='" + loggedUser + "')");
                    stmt.close();
                }
                out.println("<p class='success'>信息更新成功！</p>");
            } else {
                PreparedStatement pstmt = conn.prepareStatement("UPDATE users SET real_name=? WHERE username=?");
                pstmt.setString(1, newName);
                pstmt.setString(2, loggedUser);
                pstmt.executeUpdate();
                pstmt.close();
                session.setAttribute("real_name", newName);

                if ("student".equals(role)) {
                    PreparedStatement pstmt2 = conn.prepareStatement("UPDATE students SET phone=? WHERE user_id=(SELECT id FROM users WHERE username=?)");
                    pstmt2.setString(1, newPhone);
                    pstmt2.setString(2, loggedUser);
                    pstmt2.executeUpdate();
                    pstmt2.close();
                }
                out.println("<p class='success'>信息更新成功！</p>");
            }
        }

        // Display user info
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM users WHERE username='" + loggedUser + "'");
        if (rs.next()) {
%>

<table class="data-table" width="50%">
    <tr><th colspan="2" style="text-align: left;">基本信息</th></tr>
    <tr><td width="30%">用户名</td><td><%=rs.getString("username")%></td></tr>
    <tr><td>姓名</td><td><%=rs.getString("real_name")%></td></tr>
    <tr><td>角色</td><td><%="admin".equals(rs.getString("role")) ? "管理员" : "teacher".equals(rs.getString("role")) ? "教师" : "学生"%></td></tr>
    <% if ("low".equals(difficulty)) { %>
        <!-- LOW: Password visible on profile page! -->
        <tr><td>密码</td><td><%=rs.getString("password")%></td></tr>
    <% } %>
    <tr><td>注册时间</td><td><%=rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at") : "未知"%></td></tr>
</table>

<%
        }
        rs.close();

        // Show student-specific info
        if ("student".equals(role)) {
            rs = stmt.executeQuery("SELECT * FROM students WHERE user_id=(SELECT id FROM users WHERE username='" + loggedUser + "')");
            if (rs.next()) {
%>
<br>
<table class="data-table" width="50%">
    <tr><th colspan="2" style="text-align: left;">学生信息</th></tr>
    <tr><td width="30%">学号</td><td><%=rs.getString("student_id")%></td></tr>
    <tr><td>班级</td><td><%=rs.getString("class")%></td></tr>
    <tr><td>性别</td><td><%=rs.getString("gender")%></td></tr>
    <tr><td>联系电话</td><td><%=rs.getString("phone") != null ? rs.getString("phone") : "未填写"%></td></tr>
</table>
<%
            }
            rs.close();
        }

        // Show teacher-specific info
        if ("teacher".equals(role)) {
            rs = stmt.executeQuery("SELECT * FROM teachers WHERE user_id=(SELECT id FROM users WHERE username='" + loggedUser + "')");
            if (rs.next()) {
%>
<br>
<table class="data-table" width="50%">
    <tr><th colspan="2" style="text-align: left;">教师信息</th></tr>
    <tr><td width="30%">工号</td><td><%=rs.getString("teacher_id")%></td></tr>
    <tr><td>任教科目</td><td><%=rs.getString("subject")%></td></tr>
    <tr><td>职称</td><td><%=rs.getString("title")%></td></tr>
    <tr><td>联系电话</td><td><%=rs.getString("phone") != null ? rs.getString("phone") : "未填写"%></td></tr>
</table>
<%
            }
            rs.close();
        }
        stmt.close();
%>

<br>

<!-- Update profile form -->
<div style="background: #FFFFF0; border: 1px solid #DDD; padding: 10px; margin-bottom: 15px;">
    <h3 style="font-size: 12px; color: #1B5FAA;">修改个人信息</h3>
    <form method="POST" action="index.jsp">
        <input type="hidden" name="action" value="update_profile">
        姓名：<input type="text" name="real_name" value="<%=realName != null ? realName : ""%>" size="20">
        <% if ("student".equals(role)) { %>
            &nbsp; 电话：<input type="text" name="phone" size="15">
        <% } %>
        <input type="submit" value="更新">
    </form>
</div>

<!-- Change password form -->
<div style="background: #FFFFF0; border: 1px solid #DDD; padding: 10px;">
    <h3 style="font-size: 12px; color: #1B5FAA;">修改密码</h3>
    <form method="POST" action="index.jsp">
        <input type="hidden" name="action" value="change_password">
        <% if (!"low".equals(difficulty)) { %>
            旧密码：<input type="password" name="old_password" size="15"> &nbsp;
        <% } %>
        新密码：<input type="password" name="new_password" size="15">
        <input type="submit" value="修改">
    </form>
    <% if ("low".equals(difficulty)) { %>
        <p style="font-size: 11px; color: #999;">提示：Low 难度不验证旧密码</p>
    <% } %>
</div>

<%
    } catch (Exception e) {
        if ("low".equals(difficulty)) {
            out.println("<p class='error'>错误: " + e.getMessage() + "</p>");
        } else {
            out.println("<p class='error'>操作失败，请重试。</p>");
        }
    } finally {
        try { if (conn != null) conn.close(); } catch(Exception e) {}
    }
%>

</div>

<div class="footer">
    Copyright &copy; 2009 Goz High School 信息中心 All Rights Reserved.
</div>

</body>
</html>

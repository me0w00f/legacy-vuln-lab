<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/auth_check.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>用户管理 - 狗子高中教务管理系统</title>
<link rel="stylesheet" href="../css/style.css">
</head>
<body>
<% request.setCharacterEncoding("UTF-8"); %>

<div class="header">
    <h1>狗子高中教务管理系统 v2.0</h1>
    <span class="subtitle">Goz High School Educational Management System — 管理后台</span>
</div>

<div class="navbar">
    <a href="../index.jsp">首页</a>
    <a href="index.jsp">管理首页</a>
    <a href="users.jsp" class="active">用户管理</a>
    <a href="students.jsp">学生管理</a>
    <a href="teachers.jsp">教师管理</a>
    <a href="system.jsp">系统设置</a>
</div>

<div class="content">
<%
    <%@ include file="/WEB-INF/difficulty.jsp" %>
<%
    // difficulty loaded from database via include
%>

    String loggedUser = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");

    if (("high".equals(difficulty) || "impossible".equals(difficulty)) && !"admin".equals(role)) {
        out.println("<p class='error'>权限不足。</p>");
        return;
    }
%>

<div class="difficulty-bar">
    当前安全级别：<b><%= difficulty.toUpperCase() %></b>
    | <a href="../setup.jsp">修改设置</a>
</div>

<h2>用户管理</h2>

<%
    Connection conn = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        String dbUrl = application.getInitParameter("db.url");
        String dbUser = application.getInitParameter("db.user");
        String dbPass = application.getInitParameter("db.password");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String action = request.getParameter("action");

        // Reset password
        if ("reset_password".equals(action)) {
            String userId = request.getParameter("user_id");
            String newPwd = request.getParameter("new_password");
            if (newPwd == null || "".equals(newPwd)) newPwd = "123456";

            if ("low".equals(difficulty)) {
                // LOW: SQL injection + no CSRF protection
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("UPDATE users SET password='" + newPwd + "' WHERE id=" + userId);
                stmt.close();
            } else {
                PreparedStatement pstmt = conn.prepareStatement("UPDATE users SET password=? WHERE id=?");
                pstmt.setString(1, newPwd);
                pstmt.setInt(2, Integer.parseInt(userId));
                pstmt.executeUpdate();
                pstmt.close();
            }
            out.println("<p class='success'>密码已重置！</p>");
        }

        // Delete user
        if ("delete".equals(action)) {
            String userId = request.getParameter("user_id");
            if ("low".equals(difficulty)) {
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("DELETE FROM users WHERE id=" + userId);
                stmt.close();
            } else {
                PreparedStatement pstmt = conn.prepareStatement("DELETE FROM users WHERE id=? AND role != 'admin'");
                pstmt.setInt(1, Integer.parseInt(userId));
                pstmt.executeUpdate();
                pstmt.close();
            }
            out.println("<p class='success'>用户已删除！</p>");
        }

        // Change role
        if ("change_role".equals(action)) {
            String userId = request.getParameter("user_id");
            String newRole = request.getParameter("new_role");
            if ("low".equals(difficulty)) {
                // LOW: Can promote anyone to admin via SQL injection
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("UPDATE users SET role='" + newRole + "' WHERE id=" + userId);
                stmt.close();
            } else {
                PreparedStatement pstmt = conn.prepareStatement("UPDATE users SET role=? WHERE id=?");
                pstmt.setString(1, newRole);
                pstmt.setInt(2, Integer.parseInt(userId));
                pstmt.executeUpdate();
                pstmt.close();
            }
            out.println("<p class='success'>角色已修改！</p>");
        }

        // Add user
        if ("add".equals(action)) {
            String newUsername = request.getParameter("username");
            String newPassword = request.getParameter("password");
            String newRealName = request.getParameter("real_name");
            String newRole2 = request.getParameter("role");

            if ("low".equals(difficulty)) {
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("INSERT INTO users (username, password, role, real_name) VALUES ('" + newUsername + "', '" + newPassword + "', '" + newRole2 + "', '" + newRealName + "')");
                stmt.close();
            } else {
                PreparedStatement pstmt = conn.prepareStatement("INSERT INTO users (username, password, role, real_name) VALUES (?, ?, ?, ?)");
                pstmt.setString(1, newUsername);
                pstmt.setString(2, newPassword);
                pstmt.setString(3, newRole2);
                pstmt.setString(4, newRealName);
                pstmt.executeUpdate();
                pstmt.close();
            }
            out.println("<p class='success'>用户添加成功！</p>");
        }

        // Search
        String searchKey = request.getParameter("search");
%>

<!-- Add user form -->
<div style="background: #FFFFF0; border: 1px solid #DDD; padding: 10px; margin-bottom: 15px;">
    <h3 style="font-size: 12px; color: #1B5FAA;">添加用户</h3>
    <form method="POST" action="users.jsp">
        <input type="hidden" name="action" value="add">
        用户名：<input type="text" name="username" size="12">
        密码：<input type="text" name="password" size="12">
        姓名：<input type="text" name="real_name" size="10">
        角色：<select name="role" style="font-size: 12px;">
            <option value="student">学生</option>
            <option value="teacher">教师</option>
            <% if ("low".equals(difficulty) || "admin".equals(role)) { %>
                <option value="admin">管理员</option>
            <% } %>
        </select>
        <input type="submit" value="添加">
    </form>
</div>

<!-- Search -->
<form method="GET" action="users.jsp" style="margin-bottom: 10px;">
    搜索用户：<input type="text" name="search" value="<%=searchKey != null ? searchKey : ""%>" size="20">
    <input type="submit" value="搜索">
</form>

<!-- User list -->
<%
        String sql;
        if (searchKey != null && !"".equals(searchKey.trim())) {
            if ("low".equals(difficulty)) {
                // LOW: SQL injection in search
                sql = "SELECT * FROM users WHERE username LIKE '%" + searchKey + "%' OR real_name LIKE '%" + searchKey + "%' ORDER BY id";
            } else {
                sql = "SELECT * FROM users ORDER BY id";
            }
        } else {
            sql = "SELECT * FROM users ORDER BY id";
        }
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);
%>

<table class="data-table">
    <tr>
        <th>ID</th>
        <th>用户名</th>
        <% if ("low".equals(difficulty)) { %><th>密码</th><% } %>
        <th>姓名</th>
        <th>角色</th>
        <th>注册时间</th>
        <th>操作</th>
    </tr>
    <%
        while (rs.next()) {
            int uid = rs.getInt("id");
    %>
    <tr>
        <td><%=uid%></td>
        <td><%=rs.getString("username")%></td>
        <% if ("low".equals(difficulty)) { %><td><%=rs.getString("password")%></td><% } %>
        <td><%=rs.getString("real_name")%></td>
        <td>
            <form method="POST" action="users.jsp" style="display:inline; margin:0;">
                <input type="hidden" name="action" value="change_role">
                <input type="hidden" name="user_id" value="<%=uid%>">
                <select name="new_role" style="font-size: 11px;" onchange="this.form.submit();">
                    <option value="student" <%="student".equals(rs.getString("role"))?"selected":""%>>学生</option>
                    <option value="teacher" <%="teacher".equals(rs.getString("role"))?"selected":""%>>教师</option>
                    <option value="admin" <%="admin".equals(rs.getString("role"))?"selected":""%>>管理员</option>
                </select>
            </form>
        </td>
        <td><%=rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at") : "-"%></td>
        <td>
            <form method="POST" action="users.jsp" style="display:inline; margin:0;">
                <input type="hidden" name="action" value="reset_password">
                <input type="hidden" name="user_id" value="<%=uid%>">
                <input type="text" name="new_password" size="8" value="123456" style="font-size: 11px;">
                <input type="submit" value="重置" style="font-size: 11px;">
            </form>
            &nbsp;
            <a href="users.jsp?action=delete&user_id=<%=uid%>" onclick="return confirm('确定删除用户 <%=rs.getString("username")%>？');" style="color: red;">删除</a>
        </td>
    </tr>
    <%
        }
        rs.close();
        stmt.close();
    %>
</table>

<%
    } catch (Exception e) {
        if ("low".equals(difficulty)) {
            out.println("<p class='error'>错误: " + e.getMessage() + "</p>");
        } else {
            out.println("<p class='error'>操作失败。</p>");
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

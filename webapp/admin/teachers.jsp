<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/auth_check.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>教师管理 - 狗子高中教务管理系统</title>
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
    <a href="users.jsp">用户管理</a>
    <a href="students.jsp">学生管理</a>
    <a href="teachers.jsp" class="active">教师管理</a>
    <a href="system.jsp">系统设置</a>
</div>

<div class="content">
<%
    String difficulty = (String) session.getAttribute("difficulty");
    if (difficulty == null) { difficulty = "low"; session.setAttribute("difficulty", difficulty); }

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

<h2>教师管理</h2>

<%
    Connection conn = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        String dbUrl = application.getInitParameter("db.url");
        String dbUser = application.getInitParameter("db.user");
        String dbPass = application.getInitParameter("db.password");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            String tid = request.getParameter("teacher_id");
            String name = request.getParameter("name");
            String subject = request.getParameter("subject");
            String phone = request.getParameter("phone");
            String title = request.getParameter("title");

            if ("low".equals(difficulty)) {
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("INSERT INTO teachers (teacher_id, name, subject, phone, title) VALUES ('" + tid + "', '" + name + "', '" + subject + "', '" + phone + "', '" + title + "')");
                stmt.close();
            } else {
                PreparedStatement pstmt = conn.prepareStatement("INSERT INTO teachers (teacher_id, name, subject, phone, title) VALUES (?, ?, ?, ?, ?)");
                pstmt.setString(1, tid);
                pstmt.setString(2, name);
                pstmt.setString(3, subject);
                pstmt.setString(4, phone);
                pstmt.setString(5, title);
                pstmt.executeUpdate();
                pstmt.close();
            }
            out.println("<p class='success'>教师添加成功！</p>");
        }

        if ("delete".equals(action)) {
            String id = request.getParameter("id");
            if ("low".equals(difficulty)) {
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("DELETE FROM teachers WHERE id=" + id);
                stmt.close();
            } else {
                PreparedStatement pstmt = conn.prepareStatement("DELETE FROM teachers WHERE id=?");
                pstmt.setInt(1, Integer.parseInt(id));
                pstmt.executeUpdate();
                pstmt.close();
            }
            out.println("<p class='success'>教师已删除！</p>");
        }

        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT t.*, u.username FROM teachers t LEFT JOIN users u ON t.user_id = u.id ORDER BY t.teacher_id");
%>

<!-- Add teacher form -->
<div style="background: #FFFFF0; border: 1px solid #DDD; padding: 10px; margin-bottom: 15px;">
    <h3 style="font-size: 12px; color: #1B5FAA;">添加教师</h3>
    <form method="POST" action="teachers.jsp">
        <input type="hidden" name="action" value="add">
        工号：<input type="text" name="teacher_id" size="8">
        姓名：<input type="text" name="name" size="8">
        科目：<input type="text" name="subject" size="8">
        电话：<input type="text" name="phone" size="13">
        职称：<select name="title" style="font-size: 12px;">
            <option>二级教师</option><option>一级教师</option><option>高级教师</option><option>特级教师</option>
        </select>
        <input type="submit" value="添加">
    </form>
</div>

<table class="data-table">
    <tr>
        <th>工号</th>
        <th>姓名</th>
        <th>任教科目</th>
        <th>联系电话</th>
        <th>职称</th>
        <th>账号</th>
        <th>操作</th>
    </tr>
    <%
        while (rs.next()) {
    %>
    <tr>
        <td><%=rs.getString("teacher_id")%></td>
        <td><%=rs.getString("name")%></td>
        <td><%=rs.getString("subject")%></td>
        <td><%=rs.getString("phone") != null ? rs.getString("phone") : "-"%></td>
        <td><%=rs.getString("title")%></td>
        <td><%=rs.getString("username") != null ? rs.getString("username") : "<span style='color:red;'>未绑定</span>"%></td>
        <td><a href="teachers.jsp?action=delete&id=<%=rs.getInt("id")%>" onclick="return confirm('确定删除？');" style="color: red;">删除</a></td>
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

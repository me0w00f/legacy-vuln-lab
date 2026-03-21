<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/auth_check.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>学生管理 - 狗子高中教务管理系统</title>
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
    <a href="students.jsp" class="active">学生管理</a>
    <a href="teachers.jsp">教师管理</a>
    <a href="system.jsp">系统设置</a>
</div>

<div class="content">
<%
    <%@ include file="/WEB-INF/difficulty.jsp" %>

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

<h2>学生管理</h2>

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
            String sid = request.getParameter("student_id");
            String name = request.getParameter("name");
            String cls = request.getParameter("class");
            String gender = request.getParameter("gender");
            String phone = request.getParameter("phone");

            if ("low".equals(difficulty)) {
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("INSERT INTO students (student_id, name, class, gender, phone) VALUES ('" + sid + "', '" + name + "', '" + cls + "', '" + gender + "', '" + phone + "')");
                stmt.close();
            } else {
                PreparedStatement pstmt = conn.prepareStatement("INSERT INTO students (student_id, name, class, gender, phone) VALUES (?, ?, ?, ?, ?)");
                pstmt.setString(1, sid);
                pstmt.setString(2, name);
                pstmt.setString(3, cls);
                pstmt.setString(4, gender);
                pstmt.setString(5, phone);
                pstmt.executeUpdate();
                pstmt.close();
            }
            out.println("<p class='success'>学生添加成功！</p>");
        }

        if ("delete".equals(action)) {
            String id = request.getParameter("id");
            if ("low".equals(difficulty)) {
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("DELETE FROM students WHERE id=" + id);
                stmt.close();
            } else {
                PreparedStatement pstmt = conn.prepareStatement("DELETE FROM students WHERE id=?");
                pstmt.setInt(1, Integer.parseInt(id));
                pstmt.executeUpdate();
                pstmt.close();
            }
            out.println("<p class='success'>学生已删除！</p>");
        }

        // Filter by class
        String filterClass = request.getParameter("filter_class");
%>

<!-- Add student form -->
<div style="background: #FFFFF0; border: 1px solid #DDD; padding: 10px; margin-bottom: 15px;">
    <h3 style="font-size: 12px; color: #1B5FAA;">添加学生</h3>
    <form method="POST" action="students.jsp">
        <input type="hidden" name="action" value="add">
        学号：<input type="text" name="student_id" size="10">
        姓名：<input type="text" name="name" size="8">
        班级：<select name="class" style="font-family: 宋体; font-size: 12px;">
            <option>高三(1)班</option><option>高三(2)班</option><option>高三(3)班</option><option>高三(4)班</option>
        </select>
        性别：<select name="gender" style="font-size: 12px;"><option>男</option><option>女</option></select>
        电话：<input type="text" name="phone" size="13">
        <input type="submit" value="添加">
    </form>
</div>

<form method="GET" action="students.jsp" style="margin-bottom: 10px;">
    筛选班级：
    <select name="filter_class" style="font-family: 宋体; font-size: 12px;">
        <option value="">全部</option>
        <option <%="高三(1)班".equals(filterClass)?"selected":""%>>高三(1)班</option>
        <option <%="高三(2)班".equals(filterClass)?"selected":""%>>高三(2)班</option>
        <option <%="高三(3)班".equals(filterClass)?"selected":""%>>高三(3)班</option>
        <option <%="高三(4)班".equals(filterClass)?"selected":""%>>高三(4)班</option>
    </select>
    <input type="submit" value="筛选">
</form>

<%
        String sql = "SELECT s.*, u.username FROM students s LEFT JOIN users u ON s.user_id = u.id";
        if (filterClass != null && !"".equals(filterClass)) {
            if ("low".equals(difficulty)) {
                sql += " WHERE s.class='" + filterClass + "'";
            } else {
                sql += " WHERE s.class='" + filterClass.replace("'","''") + "'";
            }
        }
        sql += " ORDER BY s.student_id";

        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);
%>

<table class="data-table">
    <tr>
        <th>学号</th>
        <th>姓名</th>
        <th>班级</th>
        <th>性别</th>
        <th>电话</th>
        <th>账号</th>
        <th>操作</th>
    </tr>
    <%
        while (rs.next()) {
    %>
    <tr>
        <td><%=rs.getString("student_id")%></td>
        <td><%=rs.getString("name")%></td>
        <td><%=rs.getString("class")%></td>
        <td><%=rs.getString("gender")%></td>
        <td><%=rs.getString("phone") != null ? rs.getString("phone") : "-"%></td>
        <td><%=rs.getString("username") != null ? rs.getString("username") : "<span style='color:red;'>未绑定</span>"%></td>
        <td><a href="students.jsp?action=delete&id=<%=rs.getInt("id")%><%=filterClass != null ? "&filter_class=" + java.net.URLEncoder.encode(filterClass,"UTF-8") : ""%>" onclick="return confirm('确定删除？');" style="color: red;">删除</a></td>
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

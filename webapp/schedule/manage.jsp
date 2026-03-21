<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/auth_check.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>排课管理 - 狗子高中教务管理系统</title>
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
    <a href="index.jsp">课表查询</a>
    <a href="manage.jsp" class="active">排课管理</a>
    <a href="../grades/index.jsp">成绩查询</a>
    <a href="../notice/index.jsp">通知公告</a>
    <a href="../admin/index.jsp">后台管理</a>
</div>

<div class="content">
<%
    String difficulty = (String) session.getAttribute("difficulty");
    if (difficulty == null) { difficulty = "low"; session.setAttribute("difficulty", difficulty); }

    String role = (String) session.getAttribute("role");

    // Medium and High require teacher/admin role
    if (!"low".equals(difficulty)) {
        if (!"teacher".equals(role) && !"admin".equals(role)) {
            out.println("<p class='error'>权限不足，仅教师和管理员可管理排课。</p>");
            return;
        }
    }
    // Low: any logged-in user can manage schedules (privilege escalation vuln)
%>

<div class="difficulty-bar">
    当前安全级别：<b><%= difficulty.toUpperCase() %></b>
    | <a href="../setup.jsp">修改设置</a>
</div>

<h2>排课管理</h2>

<%
    Connection conn = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        String dbUrl = application.getInitParameter("db.url");
        String dbUser = application.getInitParameter("db.user");
        String dbPass = application.getInitParameter("db.password");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        // Handle add/delete operations
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            String cls = request.getParameter("class");
            String weekday = request.getParameter("weekday");
            String period = request.getParameter("period");
            String subject = request.getParameter("subject");
            String teacher = request.getParameter("teacher");

            if ("low".equals(difficulty)) {
                // LOW: SQL injection in INSERT
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("INSERT INTO schedules (class, weekday, period, subject, teacher) VALUES ('" + cls + "', '" + weekday + "', " + period + ", '" + subject + "', '" + teacher + "')");
                stmt.close();
            } else {
                PreparedStatement pstmt = conn.prepareStatement("INSERT INTO schedules (class, weekday, period, subject, teacher) VALUES (?, ?, ?, ?, ?)");
                pstmt.setString(1, cls);
                pstmt.setString(2, weekday);
                pstmt.setInt(3, Integer.parseInt(period));
                pstmt.setString(4, subject);
                pstmt.setString(5, teacher);
                pstmt.executeUpdate();
                pstmt.close();
            }
            out.println("<p class='success'>课程添加成功！</p>");
        }

        if ("delete".equals(action)) {
            String id = request.getParameter("id");
            if ("low".equals(difficulty)) {
                // LOW: SQL injection in DELETE
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("DELETE FROM schedules WHERE id=" + id);
                stmt.close();
            } else {
                PreparedStatement pstmt = conn.prepareStatement("DELETE FROM schedules WHERE id=?");
                pstmt.setInt(1, Integer.parseInt(id));
                pstmt.executeUpdate();
                pstmt.close();
            }
            out.println("<p class='success'>课程已删除！</p>");
        }
%>

<!-- Add schedule form -->
<div style="background: #FFFFF0; border: 1px solid #DDD; padding: 10px; margin-bottom: 15px;">
    <h3 style="font-size: 12px; color: #1B5FAA;">添加课程</h3>
    <form method="POST" action="manage.jsp">
        <input type="hidden" name="action" value="add">
        <table style="border: none;">
            <tr>
                <td style="border: none;">班级：</td>
                <td style="border: none;">
                    <select name="class" style="font-family: 宋体; font-size: 12px;">
                        <option>高三(1)班</option>
                        <option>高三(2)班</option>
                        <option>高三(3)班</option>
                        <option>高三(4)班</option>
                    </select>
                </td>
                <td style="border: none;">星期：</td>
                <td style="border: none;">
                    <select name="weekday" style="font-family: 宋体; font-size: 12px;">
                        <option>星期一</option>
                        <option>星期二</option>
                        <option>星期三</option>
                        <option>星期四</option>
                        <option>星期五</option>
                    </select>
                </td>
                <td style="border: none;">节次：</td>
                <td style="border: none;">
                    <select name="period" style="font-size: 12px;">
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                        <option value="5">5</option>
                        <option value="6">6</option>
                        <option value="7">7</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td style="border: none;">科目：</td>
                <td style="border: none;"><input type="text" name="subject" size="10"></td>
                <td style="border: none;">教师：</td>
                <td style="border: none;"><input type="text" name="teacher" size="10"></td>
                <td style="border: none;" colspan="2"><input type="submit" value="添加"></td>
            </tr>
        </table>
    </form>
</div>

<!-- Current schedules -->
<%
        String filterClass = request.getParameter("filter_class");
        if (filterClass == null) filterClass = "高三(1)班";

        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM schedules WHERE class='" + filterClass + "' ORDER BY FIELD(weekday,'星期一','星期二','星期三','星期四','星期五'), period");
%>

<form method="GET" action="manage.jsp" style="margin-bottom: 10px;">
    查看班级：
    <select name="filter_class" style="font-family: 宋体; font-size: 12px;">
        <option <%="高三(1)班".equals(filterClass)?"selected":""%>>高三(1)班</option>
        <option <%="高三(2)班".equals(filterClass)?"selected":""%>>高三(2)班</option>
        <option <%="高三(3)班".equals(filterClass)?"selected":""%>>高三(3)班</option>
        <option <%="高三(4)班".equals(filterClass)?"selected":""%>>高三(4)班</option>
    </select>
    <input type="submit" value="查看">
</form>

<table class="data-table">
    <tr>
        <th>ID</th>
        <th>星期</th>
        <th>节次</th>
        <th>科目</th>
        <th>教师</th>
        <th>操作</th>
    </tr>
    <%
        while (rs.next()) {
    %>
    <tr>
        <td><%=rs.getInt("id")%></td>
        <td><%=rs.getString("weekday")%></td>
        <td>第<%=rs.getInt("period")%>节</td>
        <td><%=rs.getString("subject")%></td>
        <td><%=rs.getString("teacher") != null ? rs.getString("teacher") : "-"%></td>
        <td><a href="manage.jsp?action=delete&id=<%=rs.getInt("id")%>&filter_class=<%=java.net.URLEncoder.encode(filterClass,"UTF-8")%>" onclick="return confirm('确定删除？');">删除</a></td>
    </tr>
    <%
        }
        rs.close();
        stmt.close();
    %>
</table>

<%
    } catch (Exception e) {
        out.println("<p class='error'>操作失败: " + e.getMessage() + "</p>");
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

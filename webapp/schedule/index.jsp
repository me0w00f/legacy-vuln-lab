<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>课表查询 - 狗子高中教务管理系统</title>
<link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="header">
    <h1>狗子高中教务管理系统 v2.0</h1>
    <span class="subtitle">Goz High School Educational Management System</span>
</div>

<div class="navbar">
    <a href="../index.jsp">首页</a>
    <a href="index.jsp" class="active">课表查询</a>
    <a href="../grades/index.jsp">成绩查询</a>
    <a href="../notice/index.jsp">通知公告</a>
    <a href="../upload/index.jsp">文件上传</a>
    <a href="../admin/index.jsp">后台管理</a>
</div>

<%@ include file="/WEB-INF/auth_check.jsp" %>
<div class="content">
<%@ include file="/WEB-INF/difficulty.jsp" %>

<div class="difficulty-bar">
    当前安全级别：<b><%= difficulty.toUpperCase() %></b>
    | <a href="../setup.jsp">修改设置</a>
</div>

<h2>课表查询</h2>

<% request.setCharacterEncoding("UTF-8"); %>
<form method="POST" action="index.jsp">
    班级：<input type="text" name="class" value="<%=request.getParameter("class") != null ? request.getParameter("class") : ""%>" size="20">
    <input type="submit" value="查询">
</form>

<br>

<%
    String className = request.getParameter("class");
    if (className != null && !"".equals(className.trim())) {
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
                // LOW: SQL injection + reflected XSS (class name echoed without encoding)
                String sql = "SELECT * FROM schedules WHERE class='" + className + "' ORDER BY weekday, period";
                stmt = conn.createStatement();
                rs = stmt.executeQuery(sql);

            } else if ("medium".equals(difficulty)) {
                // MEDIUM: Basic filtering
                className = className.replace("'", "\\'");
                className = className.replace("<", "&lt;");
                // Note: still vulnerable to double-encoding and other bypasses
                String sql = "SELECT * FROM schedules WHERE class='" + className + "' ORDER BY weekday, period";
                stmt = conn.createStatement();
                rs = stmt.executeQuery(sql);

            } else { // HIGH + IMPOSSIBLE
                // HIGH: Parameterized query + output encoding
                String sql = "SELECT * FROM schedules WHERE class=? ORDER BY weekday, period";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, className);
                rs = pstmt.executeQuery();
            }
%>
            <% if ("low".equals(difficulty)) { %>
                <p>查询结果：<b><%=className%></b> 的课程表</p>
            <% } else { // HIGH + IMPOSSIBLE %>
                <p>查询结果：<b><%=className.replace("<","&lt;").replace(">","&gt;")%></b> 的课程表</p>
            <% } %>

            <table class="data-table">
                <tr>
                    <th>星期</th>
                    <th>节次</th>
                    <th>科目</th>
                    <th>教师</th>
                </tr>
                <%
                    boolean hasData = false;
                    while (rs.next()) {
                        hasData = true;
                %>
                <tr>
                    <td><%=rs.getString("weekday")%></td>
                    <td>第<%=rs.getInt("period")%>节</td>
                    <td><%=rs.getString("subject")%></td>
                    <td><%=rs.getString("teacher")%></td>
                </tr>
                <%
                    }
                    if (!hasData) {
                %>
                <tr><td colspan="4">未找到该班级的课表数据</td></tr>
                <%
                    }
                %>
            </table>
<%
        } catch (Exception e) {
            if ("low".equals(difficulty)) {
                out.println("<p class='error'>查询错误: " + e.getMessage() + "</p>");
            } else { // HIGH + IMPOSSIBLE
                out.println("<p class='error'>查询失败，请检查输入。</p>");
            }
        } finally {
            try { if (rs != null) rs.close(); } catch(Exception e) {}
            try { if (stmt != null) stmt.close(); } catch(Exception e) {}
            try { if (conn != null) conn.close(); } catch(Exception e) {}
        }
    }
%>

<p style="font-size: 11px; color: #999;">提示：请输入完整班级名称，如"高三(1)班"</p>

</div>

<div class="footer">
    Copyright &copy; 2009 Goz High School 信息中心 All Rights Reserved.
</div>

</body>
</html>

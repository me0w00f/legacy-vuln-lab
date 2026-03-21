<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>成绩查询 - 狗子高中教务管理系统</title>
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
    <a href="index.jsp" class="active">成绩查询</a>
    <a href="../notice/index.jsp">通知公告</a>
    <a href="../upload/index.jsp">文件上传</a>
    <a href="../admin/index.jsp">后台管理</a>
</div>

<%@ include file="/WEB-INF/auth_check.jsp" %>
<div class="content">
<%
    <%@ include file="/WEB-INF/difficulty.jsp" %>
<%
    // difficulty loaded from database via include
%>
%>

<div class="difficulty-bar">
    当前安全级别：<b><%= difficulty.toUpperCase() %></b>
    | <a href="../setup.jsp">修改设置</a>
</div>

<h2>成绩查询</h2>

<% request.setCharacterEncoding("UTF-8"); %>
<form method="POST" action="index.jsp">
    学号：<input type="text" name="student_id" value="<%=request.getParameter("student_id") != null ? request.getParameter("student_id") : ""%>" size="20">
    <input type="submit" value="查询">
</form>

<br>

<%
    String studentId = request.getParameter("student_id");
    if (studentId != null && !"".equals(studentId.trim())) {
        Connection conn = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            String dbUrl = application.getInitParameter("db.url");
            String dbUser = application.getInitParameter("db.user");
            String dbPass = application.getInitParameter("db.password");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            if ("low".equals(difficulty)) {
                // LOW: No authentication check - anyone can query any student's grades
                // Also SQL injection via student_id
                String sql = "SELECT g.*, s.name, s.class FROM grades g JOIN students s ON g.student_id = s.student_id WHERE g.student_id='" + studentId + "'";
                Statement stmt = conn.createStatement();
                rs = stmt.executeQuery(sql);

            } else if ("medium".equals(difficulty)) {
                // MEDIUM: Requires login but no role/ownership check (IDOR)
                String loggedUser = (String) session.getAttribute("username");
                if (loggedUser == null) {
                    out.println("<p class='error'>请先登录后再查询成绩。</p>");
                    return;
                }
                // Still uses parameterized query but allows viewing OTHER students' grades
                String sql = "SELECT g.*, s.name, s.class FROM grades g JOIN students s ON g.student_id = s.student_id WHERE g.student_id=?";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, studentId);
                rs = pstmt.executeQuery();

            } else { // HIGH + IMPOSSIBLE
                // HIGH: Requires login + ownership check (students can only see their own grades)
                String loggedUser = (String) session.getAttribute("username");
                String role = (String) session.getAttribute("role");
                if (loggedUser == null) {
                    out.println("<p class='error'>请先登录后再查询成绩。</p>");
                    return;
                }

                // Students can only query their own grades
                if ("student".equals(role)) {
                    // Check if the student_id belongs to the logged-in user
                    PreparedStatement checkStmt = conn.prepareStatement(
                        "SELECT student_id FROM students WHERE user_id = (SELECT id FROM users WHERE username = ?)");
                    checkStmt.setString(1, loggedUser);
                    ResultSet checkRs = checkStmt.executeQuery();
                    if (checkRs.next()) {
                        String ownStudentId = checkRs.getString("student_id");
                        if (!ownStudentId.equals(studentId)) {
                            out.println("<p class='error'>您只能查询自己的成绩。</p>");
                            return;
                        }
                    }
                    checkRs.close();
                    checkStmt.close();
                }

                String sql = "SELECT g.*, s.name, s.class FROM grades g JOIN students s ON g.student_id = s.student_id WHERE g.student_id=?";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, studentId);
                rs = pstmt.executeQuery();
            }
%>
            <table class="data-table">
                <tr>
                    <th>姓名</th>
                    <th>班级</th>
                    <th>科目</th>
                    <th>成绩</th>
                    <th>学期</th>
                    <th>考试类型</th>
                </tr>
                <%
                    boolean hasData = false;
                    while (rs.next()) {
                        hasData = true;
                %>
                <tr>
                    <td><%=rs.getString("name")%></td>
                    <td><%=rs.getString("class")%></td>
                    <td><%=rs.getString("subject")%></td>
                    <td><%=rs.getBigDecimal("score")%></td>
                    <td><%=rs.getString("semester")%></td>
                    <td><%=rs.getString("exam_type")%></td>
                </tr>
                <%
                    }
                    if (!hasData) {
                %>
                <tr><td colspan="6">未找到该学号的成绩数据</td></tr>
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
            try { if (conn != null) conn.close(); } catch(Exception e) {}
        }
    }
%>

<p style="font-size: 11px; color: #999;">提示：请输入学号，如"2009001"</p>

</div>

<div class="footer">
    Copyright &copy; 2009 Goz High School 信息中心 All Rights Reserved.
</div>

</body>
</html>

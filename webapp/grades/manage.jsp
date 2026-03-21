<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/auth_check.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>成绩录入 - 狗子高中教务管理系统</title>
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
    <a href="index.jsp">成绩查询</a>
    <a href="manage.jsp" class="active">成绩录入</a>
    <a href="../notice/index.jsp">通知公告</a>
    <a href="../admin/index.jsp">后台管理</a>
</div>

<div class="content">
<%
    <%@ include file="/WEB-INF/difficulty.jsp" %>

    String role = (String) session.getAttribute("role");

    if (!"low".equals(difficulty)) {
        if (!"teacher".equals(role) && !"admin".equals(role)) {
            out.println("<p class='error'>权限不足，仅教师和管理员可录入成绩。</p>");
            return;
        }
    }
%>

<div class="difficulty-bar">
    当前安全级别：<b><%= difficulty.toUpperCase() %></b>
    | <a href="../setup.jsp">修改设置</a>
</div>

<h2>成绩录入</h2>

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
            String studentId = request.getParameter("student_id");
            String subject = request.getParameter("subject");
            String score = request.getParameter("score");
            String semester = request.getParameter("semester");
            String examType = request.getParameter("exam_type");

            if ("low".equals(difficulty)) {
                // LOW: SQL injection + no score validation (can enter negative or >100)
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("INSERT INTO grades (student_id, subject, score, semester, exam_type) VALUES ('" + studentId + "', '" + subject + "', " + score + ", '" + semester + "', '" + examType + "')");
                stmt.close();
            } else if ("medium".equals(difficulty)) {
                // MEDIUM: Parameterized but no score range validation
                PreparedStatement pstmt = conn.prepareStatement("INSERT INTO grades (student_id, subject, score, semester, exam_type) VALUES (?, ?, ?, ?, ?)");
                pstmt.setString(1, studentId);
                pstmt.setString(2, subject);
                pstmt.setBigDecimal(3, new java.math.BigDecimal(score));
                pstmt.setString(4, semester);
                pstmt.setString(5, examType);
                pstmt.executeUpdate();
                pstmt.close();
            } else {
                // HIGH: Parameterized + score validation (0-100)
                double scoreVal = Double.parseDouble(score);
                if (scoreVal < 0 || scoreVal > 100) {
                    out.println("<p class='error'>成绩必须在0-100之间！</p>");
                } else {
                    // Also verify student exists
                    PreparedStatement checkStmt = conn.prepareStatement("SELECT student_id FROM students WHERE student_id = ?");
                    checkStmt.setString(1, studentId);
                    ResultSet checkRs = checkStmt.executeQuery();
                    if (!checkRs.next()) {
                        out.println("<p class='error'>学号不存在！</p>");
                    } else {
                        PreparedStatement pstmt = conn.prepareStatement("INSERT INTO grades (student_id, subject, score, semester, exam_type) VALUES (?, ?, ?, ?, ?)");
                        pstmt.setString(1, studentId);
                        pstmt.setString(2, subject);
                        pstmt.setBigDecimal(3, new java.math.BigDecimal(score));
                        pstmt.setString(4, semester);
                        pstmt.setString(5, examType);
                        pstmt.executeUpdate();
                        pstmt.close();
                        out.println("<p class='success'>成绩录入成功！</p>");
                    }
                    checkRs.close();
                    checkStmt.close();
                }
            }

            if (!"high".equals(difficulty)) {
                out.println("<p class='success'>成绩录入成功！</p>");
            }
        }

        if ("delete".equals(action)) {
            String id = request.getParameter("id");
            if ("low".equals(difficulty)) {
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("DELETE FROM grades WHERE id=" + id);
                stmt.close();
            } else {
                PreparedStatement pstmt = conn.prepareStatement("DELETE FROM grades WHERE id=?");
                pstmt.setInt(1, Integer.parseInt(id));
                pstmt.executeUpdate();
                pstmt.close();
            }
            out.println("<p class='success'>成绩已删除！</p>");
        }
%>

<!-- Grade entry form -->
<div style="background: #FFFFF0; border: 1px solid #DDD; padding: 10px; margin-bottom: 15px;">
    <h3 style="font-size: 12px; color: #1B5FAA;">录入成绩</h3>
    <form method="POST" action="manage.jsp">
        <input type="hidden" name="action" value="add">
        <table style="border: none;">
            <tr>
                <td style="border: none;">学号：</td>
                <td style="border: none;"><input type="text" name="student_id" size="12"></td>
                <td style="border: none;">科目：</td>
                <td style="border: none;">
                    <select name="subject" style="font-family: 宋体; font-size: 12px;">
                        <option>语文</option>
                        <option>数学</option>
                        <option>英语</option>
                        <option>物理</option>
                        <option>化学</option>
                        <option>生物</option>
                        <option>政治</option>
                    </select>
                </td>
                <td style="border: none;">成绩：</td>
                <td style="border: none;"><input type="text" name="score" size="5"></td>
            </tr>
            <tr>
                <td style="border: none;">学期：</td>
                <td style="border: none;">
                    <select name="semester" style="font-family: 宋体; font-size: 12px;">
                        <option>2009-2010上</option>
                        <option>2009-2010下</option>
                    </select>
                </td>
                <td style="border: none;">考试：</td>
                <td style="border: none;">
                    <select name="exam_type" style="font-family: 宋体; font-size: 12px;">
                        <option>期中</option>
                        <option>期末</option>
                        <option>月考</option>
                        <option>模拟考</option>
                    </select>
                </td>
                <td style="border: none;" colspan="2"><input type="submit" value="录入"></td>
            </tr>
        </table>
    </form>
</div>

<!-- Recent grades -->
<h3 style="font-size: 12px; color: #1B5FAA;">最近录入的成绩</h3>
<%
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT g.*, s.name, s.class FROM grades g LEFT JOIN students s ON g.student_id = s.student_id ORDER BY g.id DESC LIMIT 30");
%>
<table class="data-table">
    <tr>
        <th>ID</th>
        <th>学号</th>
        <th>姓名</th>
        <th>班级</th>
        <th>科目</th>
        <th>成绩</th>
        <th>学期</th>
        <th>考试</th>
        <th>操作</th>
    </tr>
    <%
        while (rs.next()) {
    %>
    <tr>
        <td><%=rs.getInt("id")%></td>
        <td><%=rs.getString("student_id")%></td>
        <td><%=rs.getString("name") != null ? rs.getString("name") : "-"%></td>
        <td><%=rs.getString("class") != null ? rs.getString("class") : "-"%></td>
        <td><%=rs.getString("subject")%></td>
        <td><%=rs.getBigDecimal("score")%></td>
        <td><%=rs.getString("semester")%></td>
        <td><%=rs.getString("exam_type")%></td>
        <td><a href="manage.jsp?action=delete&id=<%=rs.getInt("id")%>" onclick="return confirm('确定删除？');">删除</a></td>
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

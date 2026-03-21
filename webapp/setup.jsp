<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>安全级别设置 - 狗子高中教务管理系统</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>

<div class="header">
    <h1>狗子高中教务管理系统 v2.0</h1>
    <span class="subtitle">Goz High School Educational Management System</span>
</div>

<div class="navbar">
    <a href="index.jsp">首页</a>
    <a href="schedule/index.jsp">课表查询</a>
    <a href="grades/index.jsp">成绩查询</a>
    <a href="notice/index.jsp">通知公告</a>
    <a href="upload/index.jsp">文件上传</a>
    <a href="admin/index.jsp">后台管理</a>
    <a href="setup.jsp" class="active" style="float:right;">安全设置</a>
</div>

<%@ include file="/WEB-INF/auth_check.jsp" %>
<div class="content">

<%
    // Read current difficulty from database
    String currentDifficulty = "low";
    Connection setupConn = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        String dbUrl = application.getInitParameter("db.url");
        String dbUser = application.getInitParameter("db.user");
        String dbPass = application.getInitParameter("db.password");
        setupConn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        Statement readStmt = setupConn.createStatement();
        ResultSet readRs = readStmt.executeQuery("SELECT setting_value FROM settings WHERE setting_key='difficulty'");
        if (readRs.next()) {
            currentDifficulty = readRs.getString("setting_value");
        }
        readRs.close();
        readStmt.close();

        String role = (String) session.getAttribute("role");
        boolean isAdmin = "admin".equals(role);

        // Handle update
        String newDifficulty = request.getParameter("difficulty");
        if (newDifficulty != null) {
            if (isAdmin) {
                PreparedStatement updateStmt = setupConn.prepareStatement(
                    "UPDATE settings SET setting_value=? WHERE setting_key='difficulty'");
                updateStmt.setString(1, newDifficulty);
                updateStmt.executeUpdate();
                updateStmt.close();
                currentDifficulty = newDifficulty;
                out.println("<div class='form-box' style='width: 450px;'><p class='success'>安全级别已设置为：<b>" + currentDifficulty.toUpperCase() + "</b></p></div><br>");
            } else {
                out.println("<div class='form-box' style='width: 450px;'><p class='error'>权限不足，仅管理员可修改安全级别。</p></div><br>");
            }
        }

        // Update session
        session.setAttribute("difficulty", currentDifficulty);
%>

<div class="form-box" style="width: 450px;">
    <h3>安全级别设置</h3>

    <% if (isAdmin) { %>
    <form method="POST" action="setup.jsp">
        <table width="100%" style="border: none;">
            <tr>
                <td style="border: none; padding: 8px;">
                    <input type="radio" name="difficulty" value="low" <%="low".equals(currentDifficulty) ? "checked" : ""%>>
                    <b>Low</b> — 无任何防御
                </td>
            </tr>
            <tr>
                <td style="border: none; padding: 8px;">
                    <input type="radio" name="difficulty" value="medium" <%="medium".equals(currentDifficulty) ? "checked" : ""%>>
                    <b>Medium</b> — 基本防御（可绕过）
                </td>
            </tr>
            <tr>
                <td style="border: none; padding: 8px;">
                    <input type="radio" name="difficulty" value="high" <%="high".equals(currentDifficulty) ? "checked" : ""%>>
                    <b>High</b> — 完整防御
                </td>
            </tr>
            <tr>
                <td style="border: none; padding: 8px;">
                    <input type="radio" name="difficulty" value="impossible" <%="impossible".equals(currentDifficulty) ? "checked" : ""%>>
                    <b style="color: #8B0000;">Impossible</b> — 你试试看
                </td>
            </tr>
        </table>
        <br>
        <input type="submit" value="保存设置">
    </form>
    <% } else { %>
    <p style="color: #999;">仅管理员可修改安全级别。请联系管理员。</p>
    <% } %>

    <br>
    <p style="font-size: 11px; color: #999;">
        当前安全级别：<b style="color: <%="low".equals(currentDifficulty) ? "red" : "medium".equals(currentDifficulty) ? "orange" : "impossible".equals(currentDifficulty) ? "#8B0000" : "green"%>;">
        <%=currentDifficulty.toUpperCase()%></b><br><br>
        Low = 漏洞完全暴露，适合初学者<br>
        Medium = 有基本过滤，需要绕过技巧<br>
        High = 接近真实防御，需要组合攻击<br>
        <span style="color: #8B0000;">Impossible = 安全编码范例，无法攻破</span>
    </p>
</div>

<%
    } catch (Exception e) {
        out.println("<p class='error'>数据库连接失败: " + e.getMessage() + "</p>");
    } finally {
        try { if (setupConn != null) setupConn.close(); } catch(Exception e) {}
    }
%>

</div>

<div class="footer">
    Copyright &copy; 2009 Goz High School 信息中心 All Rights Reserved.
</div>

</body>
</html>

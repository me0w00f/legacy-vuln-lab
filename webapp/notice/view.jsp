<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>查看通知 - 狗子高中教务管理系统</title>
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
    <a href="../grades/index.jsp">成绩查询</a>
    <a href="index.jsp" class="active">通知公告</a>
    <a href="../upload/index.jsp">文件上传</a>
    <a href="../admin/index.jsp">后台管理</a>
</div>

<%@ include file="/WEB-INF/auth_check.jsp" %>
<div class="content">
<%@ include file="/WEB-INF/difficulty.jsp" %>
<%
    String id = request.getParameter("id");
    if (id != null) {
        Connection conn = null;
        try {
            Class.forName("com.mysql.jdbc.Driver");
            String dbUrl = application.getInitParameter("db.url");
            String dbUser = application.getInitParameter("db.user");
            String dbPass = application.getInitParameter("db.password");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            ResultSet rs;
            if ("low".equals(difficulty)) {
                // LOW: SQL injection in id parameter
                Statement stmt = conn.createStatement();
                rs = stmt.executeQuery("SELECT * FROM notices WHERE id=" + id);
            } else { // HIGH + IMPOSSIBLE
                PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM notices WHERE id=?");
                pstmt.setInt(1, Integer.parseInt(id));
                rs = pstmt.executeQuery();
            }

            if (rs.next()) {
%>
                <h2><%=rs.getString("title")%></h2>
                <p style="color: #999; font-size: 11px;">
                    发布者：<%=rs.getString("author")%> &nbsp;|&nbsp;
                    发布时间：<%=rs.getTimestamp("created_at")%>
                </p>
                <hr style="border: none; border-top: 1px dashed #CCC;">
                <div style="padding: 10px; line-height: 1.8; font-size: 12px;">
                    <% if ("low".equals(difficulty)) { %>
                        <%=rs.getString("content").replace("\\n","<br>")%>
                    <% } else if ("medium".equals(difficulty)) { %>
                        <%=rs.getString("content").replace("\\n","<br>").replaceAll("<script>","").replaceAll("</script>","")%>
                    <% } else { // HIGH + IMPOSSIBLE %>
                        <%=rs.getString("content").replace("<","&lt;").replace(">","&gt;").replace("\\n","<br>")%>
                    <% } %>
                </div>
<%
            } else { // HIGH + IMPOSSIBLE
                out.println("<p class='error'>通知不存在。</p>");
            }
            rs.close();
        } catch (Exception e) {
            if ("low".equals(difficulty)) {
                out.println("<p class='error'>错误: " + e.getMessage() + "</p>");
            } else { // HIGH + IMPOSSIBLE
                out.println("<p class='error'>加载通知失败。</p>");
            }
        } finally {
            try { if (conn != null) conn.close(); } catch(Exception e) {}
        }
    }
%>

<br>
<a href="index.jsp">&laquo; 返回公告列表</a>

</div>

<div class="footer">
    Copyright &copy; 2009 Goz High School 信息中心 All Rights Reserved.
</div>

</body>
</html>

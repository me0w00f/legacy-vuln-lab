<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>通知公告 - 狗子高中教务管理系统</title>
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
<% request.setCharacterEncoding("UTF-8"); %>
<%
    <%@ include file="/WEB-INF/difficulty.jsp" %>

<div class="difficulty-bar">
    当前安全级别：<b><%= difficulty.toUpperCase() %></b>
    | <a href="../setup.jsp">修改设置</a>
</div>

<h2>通知公告</h2>

<%
    // Handle new notice submission (stored XSS)
    String title = request.getParameter("title");
    String content = request.getParameter("content");

    if (title != null && content != null && !"".equals(title.trim())) {
        Connection conn = null;
        try {
            Class.forName("com.mysql.jdbc.Driver");
            String dbUrl = application.getInitParameter("db.url");
            String dbUser = application.getInitParameter("db.user");
            String dbPass = application.getInitParameter("db.password");
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            String author = (String) session.getAttribute("real_name");
            if (author == null) author = "匿名用户";

            if ("low".equals(difficulty)) {
                // LOW: No input sanitization - stored XSS
                Statement stmt = conn.createStatement();
                stmt.executeUpdate("INSERT INTO notices (title, content, author) VALUES ('" + title + "', '" + content + "', '" + author + "')");
                stmt.close();

            } else if ("medium".equals(difficulty)) {
                // MEDIUM: Basic tag stripping (bypassable)
                title = title.replaceAll("<script>", "").replaceAll("</script>", "");
                content = content.replaceAll("<script>", "").replaceAll("</script>", "");
                // Still vulnerable to: <Script>, <img onerror=...>, etc.

                PreparedStatement pstmt = conn.prepareStatement("INSERT INTO notices (title, content, author) VALUES (?, ?, ?)");
                pstmt.setString(1, title);
                pstmt.setString(2, content);
                pstmt.setString(3, author);
                pstmt.executeUpdate();
                pstmt.close();

            } else { // HIGH + IMPOSSIBLE
                // HIGH: Proper HTML encoding + parameterized query
                title = title.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
                content = content.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");

                PreparedStatement pstmt = conn.prepareStatement("INSERT INTO notices (title, content, author) VALUES (?, ?, ?)");
                pstmt.setString(1, title);
                pstmt.setString(2, content);
                pstmt.setString(3, author);
                pstmt.executeUpdate();
                pstmt.close();
            }

            out.println("<p class='success'>通知发布成功！</p>");
        } catch (Exception e) {
            out.println("<p class='error'>发布失败: " + e.getMessage() + "</p>");
        } finally {
            try { if (conn != null) conn.close(); } catch(Exception e) {}
        }
    }
%>

<!-- Post new notice form -->
<div style="background: #FFFFF0; border: 1px solid #DDD; padding: 10px; margin-bottom: 15px;">
    <h3 style="font-size: 12px; color: #1B5FAA;">发布新通知</h3>
    <form method="POST" action="index.jsp">
        标题：<input type="text" name="title" size="50"><br><br>
        内容：<br>
        <textarea name="content" rows="5" cols="60" style="font-family: 宋体; font-size: 12px;"></textarea><br><br>
        <input type="submit" value="发布通知">
    </form>
</div>

<!-- Display notices -->
<h3 style="font-size: 12px; color: #1B5FAA;">公告列表</h3>
<%
    Connection conn2 = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        String dbUrl = application.getInitParameter("db.url");
        String dbUser = application.getInitParameter("db.user");
        String dbPass = application.getInitParameter("db.password");
        conn2 = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        Statement stmt = conn2.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM notices ORDER BY created_at DESC");
%>
        <table class="data-table">
            <tr>
                <th width="50">序号</th>
                <th>标题</th>
                <th width="80">发布者</th>
                <th width="120">发布时间</th>
            </tr>
            <%
                int idx = 0;
                while (rs.next()) {
                    idx++;
            %>
            <tr>
                <td><%=idx%></td>
                <td align="left">
                    <a href="view.jsp?id=<%=rs.getInt("id")%>">
                    <% if ("low".equals(difficulty)) { %>
                        <%=rs.getString("title")%>
                    <% } else { // HIGH + IMPOSSIBLE %>
                        <%=rs.getString("title").replace("<","&lt;").replace(">","&gt;")%>
                    <% } %>
                    </a>
                </td>
                <td><%=rs.getString("author")%></td>
                <td><%=rs.getTimestamp("created_at")%></td>
            </tr>
            <%
                }
            %>
        </table>
<%
        rs.close();
        stmt.close();
    } catch (Exception e) {
        out.println("<p class='error'>加载通知列表失败: " + e.getMessage() + "</p>");
    } finally {
        try { if (conn2 != null) conn2.close(); } catch(Exception e) {}
    }
%>

</div>

<div class="footer">
    Copyright &copy; 2009 Goz High School 信息中心 All Rights Reserved.
</div>

</body>
</html>

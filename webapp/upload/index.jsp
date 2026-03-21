<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>文件上传 - 狗子高中教务管理系统</title>
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
    <a href="../notice/index.jsp">通知公告</a>
    <a href="index.jsp" class="active">文件上传</a>
    <a href="../admin/index.jsp">后台管理</a>
</div>

<%@ include file="/WEB-INF/auth_check.jsp" %>
<div class="content">
<%
    String difficulty = (String) session.getAttribute("difficulty");
    if (difficulty == null) { difficulty = "low"; session.setAttribute("difficulty", difficulty); }
%>

<div class="difficulty-bar">
    当前安全级别：<b><%= difficulty.toUpperCase() %></b>
    | <a href="../setup.jsp">修改设置</a>
</div>

<h2>文件上传</h2>

<p style="font-size: 12px; color: #666;">请上传学生资料、作业文件等（建议 doc、xls、pdf 格式）</p>

<%
    // Note: This is a simplified upload handler for demonstration.
    // In a real Tomcat 5.5 environment, you would use commons-fileupload.
    // For the vuln lab, we simulate the vulnerability patterns.

    String uploadMsg = request.getParameter("upload_msg");
    if (uploadMsg != null) {
        if ("success".equals(uploadMsg)) {
            out.println("<p class='success'>文件上传成功！</p>");
        } else { // HIGH + IMPOSSIBLE
            out.println("<p class='error'>上传失败: " + uploadMsg + "</p>");
        }
    }
%>

<div style="background: #FFFFF0; border: 1px solid #DDD; padding: 15px;">

    <% if ("low".equals(difficulty)) { %>
        <!-- LOW: No file type check, no size limit, uploaded to web-accessible directory -->
        <form method="POST" action="upload_handler.jsp?difficulty=low" enctype="multipart/form-data">
            选择文件：<input type="file" name="file"><br><br>
            <input type="submit" value="上传文件">
        </form>
        <p style="font-size: 11px; color: #999;">
            提示：支持所有文件类型<br>
            上传目录：/upload/files/ (可直接访问)
        </p>

    <% } else if ("medium".equals(difficulty)) { %>
        <!-- MEDIUM: Client-side JS check only (bypassable) -->
        <form method="POST" action="upload_handler.jsp?difficulty=medium" enctype="multipart/form-data"
              onsubmit="return checkFile();">
            选择文件：<input type="file" name="file" id="fileInput"><br><br>
            <input type="submit" value="上传文件">
        </form>
        <script>
        function checkFile() {
            var file = document.getElementById('fileInput').value;
            var ext = file.substring(file.lastIndexOf('.') + 1).toLowerCase();
            var allowed = ['doc', 'docx', 'xls', 'xlsx', 'pdf', 'txt', 'jpg', 'png'];
            if (allowed.indexOf(ext) == -1) {
                alert('不允许上传该类型的文件！\n允许的文件类型：' + allowed.join(', '));
                return false;
            }
            return true;
        }
        </script>
        <p style="font-size: 11px; color: #999;">
            提示：仅允许 doc/xls/pdf/txt/jpg/png 格式<br>
            (客户端验证)
        </p>

    <% } else { // HIGH + IMPOSSIBLE %>
        <!-- HIGH: Server-side whitelist + random filename + non-web directory -->
        <form method="POST" action="upload_handler.jsp?difficulty=high" enctype="multipart/form-data">
            选择文件：<input type="file" name="file"><br><br>
            <input type="submit" value="上传文件">
        </form>
        <p style="font-size: 11px; color: #999;">
            提示：仅允许 doc/xls/pdf/txt 格式<br>
            服务端验证 + 文件重命名 + 存储在非 Web 目录
        </p>
    <% } %>

</div>

<br>

<!-- List uploaded files -->
<h3 style="font-size: 12px; color: #1B5FAA;">已上传文件</h3>
<%
    Connection conn = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        String dbUrl = application.getInitParameter("db.url");
        String dbUser = application.getInitParameter("db.user");
        String dbPass = application.getInitParameter("db.password");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM uploads ORDER BY upload_time DESC LIMIT 20");
%>
        <table class="data-table">
            <tr>
                <th>文件名</th>
                <th>上传者</th>
                <th>上传时间</th>
                <th>操作</th>
            </tr>
            <%
                while (rs.next()) {
            %>
            <tr>
                <td align="left"><%=rs.getString("filename")%></td>
                <td><%=rs.getString("uploader")%></td>
                <td><%=rs.getTimestamp("upload_time")%></td>
                <td>
                    <% if ("low".equals(difficulty)) { %>
                        <a href="files/<%=rs.getString("filename")%>">下载</a>
                    <% } else { // HIGH + IMPOSSIBLE %>
                        <a href="download.jsp?id=<%=rs.getInt("id")%>">下载</a>
                    <% } %>
                </td>
            </tr>
            <%
                }
            %>
        </table>
<%
        rs.close();
        stmt.close();
    } catch (Exception e) {
        out.println("<p class='error'>加载文件列表失败</p>");
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

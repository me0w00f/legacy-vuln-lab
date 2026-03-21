<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>狗子高中教务管理系统</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>

<div class="header">
    <h1>狗子高中教务管理系统 v2.0</h1>
    <span class="subtitle">Goz High School Educational Management System</span>
</div>

<div class="navbar">
    <a href="index.jsp" class="active">首页</a>
    <a href="schedule/index.jsp">课表查询</a>
    <a href="grades/index.jsp">成绩查询</a>
    <a href="notice/index.jsp">通知公告</a>
    <a href="schedule/manage.jsp">排课管理</a>
    <a href="grades/manage.jsp">成绩录入</a>
    <a href="upload/index.jsp">文件上传</a>
    <a href="admin/index.jsp">后台管理</a>
    <a href="setup.jsp" style="color: #FFD700;">⚙ 安全设置</a>
    <%
        String user = (String) session.getAttribute("username");
        if (user != null) {
    %>
        <a href="login/logout.jsp" style="float:right;">退出登录</a>
        <a href="profile/index.jsp" style="float:right;"><%=user%> 的信息</a>
    <%
        } else {
    %>
        <a href="login/index.jsp" style="float:right;">登录</a>
    <%
        }
    %>
</div>

<div class="content">
    <h2>欢迎使用教务管理系统</h2>

    <table class="data-table" width="100%">
        <tr>
            <td width="50%" valign="top" style="padding: 10px;">
                <h3 style="color: #1B5FAA; font-size: 13px;">📢 最新通知</h3>
                <ul class="notice-list">
                <%
                    Connection homeConn = null;
                    try {
                        Class.forName("com.mysql.jdbc.Driver");
                        String dbUrl = application.getInitParameter("db.url");
                        String dbUser = application.getInitParameter("db.user");
                        String dbPass = application.getInitParameter("db.password");
                        homeConn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                        Statement homeStmt = homeConn.createStatement();
                        ResultSet homeRs = homeStmt.executeQuery("SELECT id, title, created_at FROM notices ORDER BY created_at DESC LIMIT 5");
                        while (homeRs.next()) {
                            String title = homeRs.getString("title").replace("<","&lt;").replace(">","&gt;");
                            java.sql.Timestamp ts = homeRs.getTimestamp("created_at");
                            String dateStr = ts != null ? ts.toString().substring(0, 10) : "";
                %>
                    <li><a href="notice/view.jsp?id=<%=homeRs.getInt("id")%>"><%=title%></a> <span class="date">[<%=dateStr%>]</span></li>
                <%
                        }
                        homeRs.close();
                        homeStmt.close();
                    } catch (Exception e) {
                        out.println("<li>通知加载失败</li>");
                    } finally {
                        try { if (homeConn != null) homeConn.close(); } catch(Exception e) {}
                    }
                %>
                </ul>
            </td>
            <td width="50%" valign="top" style="padding: 10px;">
                <h3 style="color: #1B5FAA; font-size: 13px;">🔗 快捷入口</h3>
                <p><a href="schedule/index.jsp">» 查询课表</a></p>
                <p><a href="grades/index.jsp">» 查询成绩</a></p>
                <p><a href="notice/index.jsp">» 查看通知</a></p>
                <p><a href="login/index.jsp">» 登录系统</a></p>
            </td>
        </tr>
    </table>

    <br>
    <p style="color: #999; font-size: 11px;">
        技术支持：信息中心 &nbsp;|&nbsp; 联系电话：0123-4567890 &nbsp;|&nbsp; 建议使用 IE6.0 浏览器，分辨率 1024x768
    </p>
</div>

<div class="footer">
    Copyright &copy; 2009 Goz High School 信息中心 All Rights Reserved.<br>
    本系统由信息中心开发维护 | 技术支持: admin@gozhighschool.edu.cn
</div>

</body>
</html>

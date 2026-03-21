<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
        <a href="login/logout.jsp" style="float:right;">退出登录 (<%=user%>)</a>
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
                    <li><a href="notice/view.jsp?id=3">系统维护通知</a> <span class="date">[2009-11-05]</span></li>
                    <li><a href="notice/view.jsp?id=2">期中考试安排</a> <span class="date">[2009-10-28]</span></li>
                    <li><a href="notice/view.jsp?id=1">关于2009年秋季运动会的通知</a> <span class="date">[2009-09-20]</span></li>
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

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*" %>
<%@ include file="/WEB-INF/auth_check.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>系统设置 - 狗子高中教务管理系统</title>
<link rel="stylesheet" href="../css/style.css">
</head>
<body>
<% request.setCharacterEncoding("UTF-8"); %>

<div class="header">
    <h1>狗子高中教务管理系统 v2.0</h1>
    <span class="subtitle">Goz High School Educational Management System — 管理后台</span>
</div>

<div class="navbar">
    <a href="../index.jsp">首页</a>
    <a href="index.jsp">管理首页</a>
    <a href="users.jsp">用户管理</a>
    <a href="students.jsp">学生管理</a>
    <a href="teachers.jsp">教师管理</a>
    <a href="system.jsp" class="active">系统设置</a>
</div>

<div class="content">
<%@ include file="/WEB-INF/difficulty.jsp" %>

    String role = (String) session.getAttribute("role");
    if (("high".equals(difficulty) || "impossible".equals(difficulty)) && !"admin".equals(role)) {
        out.println("<p class='error'>权限不足。</p>");
        return;
    }
%>

<div class="difficulty-bar">
    当前安全级别：<b><%= difficulty.toUpperCase() %></b>
    | <a href="../setup.jsp">修改设置</a>
</div>

<h2>系统设置</h2>

<table width="100%">
<tr valign="top">
<td width="50%">

<!-- System info -->
<h3 style="font-size: 12px; color: #1B5FAA;">⚙️ 系统信息</h3>
<table class="data-table">
    <tr><td>Java 版本</td><td><%=System.getProperty("java.version")%></td></tr>
    <tr><td>操作系统</td><td><%=System.getProperty("os.name")%> <%=System.getProperty("os.version")%></td></tr>
    <tr><td>服务器</td><td><%=application.getServerInfo()%></td></tr>
    <tr><td>JVM 内存</td><td><%=Runtime.getRuntime().freeMemory()/1024/1024%>MB / <%=Runtime.getRuntime().totalMemory()/1024/1024%>MB</td></tr>
    <% if ("low".equals(difficulty)) { %>
        <!-- LOW: Excessive information disclosure -->
        <tr><td>Java Home</td><td><%=System.getProperty("java.home")%></td></tr>
        <tr><td>工作目录</td><td><%=System.getProperty("user.dir")%></td></tr>
        <tr><td>类路径</td><td style="word-break: break-all; font-size: 10px;"><%=System.getProperty("java.class.path")%></td></tr>
        <tr><td>系统用户</td><td><%=System.getProperty("user.name")%></td></tr>
        <tr><td>临时目录</td><td><%=System.getProperty("java.io.tmpdir")%></td></tr>
    <% } %>
</table>

<br>

<!-- Database stats -->
<h3 style="font-size: 12px; color: #1B5FAA;">📊 数据统计</h3>
<%
    Connection conn = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        String dbUrl = application.getInitParameter("db.url");
        String dbUser = application.getInitParameter("db.user");
        String dbPass = application.getInitParameter("db.password");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        Statement stmt = conn.createStatement();
%>
<table class="data-table">
    <tr><th>项目</th><th>数量</th></tr>
    <% ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as cnt FROM users"); rs.next(); %>
    <tr><td>注册用户</td><td><%=rs.getInt("cnt")%></td></tr>
    <% rs = stmt.executeQuery("SELECT COUNT(*) as cnt FROM students"); rs.next(); %>
    <tr><td>学生档案</td><td><%=rs.getInt("cnt")%></td></tr>
    <% rs = stmt.executeQuery("SELECT COUNT(*) as cnt FROM teachers"); rs.next(); %>
    <tr><td>教师档案</td><td><%=rs.getInt("cnt")%></td></tr>
    <% rs = stmt.executeQuery("SELECT COUNT(*) as cnt FROM schedules"); rs.next(); %>
    <tr><td>课程安排</td><td><%=rs.getInt("cnt")%></td></tr>
    <% rs = stmt.executeQuery("SELECT COUNT(*) as cnt FROM grades"); rs.next(); %>
    <tr><td>成绩记录</td><td><%=rs.getInt("cnt")%></td></tr>
    <% rs = stmt.executeQuery("SELECT COUNT(*) as cnt FROM notices"); rs.next(); %>
    <tr><td>通知公告</td><td><%=rs.getInt("cnt")%></td></tr>
    <% rs = stmt.executeQuery("SELECT COUNT(*) as cnt FROM uploads"); rs.next(); %>
    <tr><td>上传文件</td><td><%=rs.getInt("cnt")%></td></tr>
</table>
<%
        rs.close();
        stmt.close();
    } catch (Exception e) {
        out.println("<p class='error'>数据库连接失败</p>");
    } finally {
        try { if (conn != null) conn.close(); } catch(Exception e) {}
    }
%>

</td>
<td width="50%">

<% if ("low".equals(difficulty)) { %>
<!-- LOW: Command execution via "system diagnostic" -->
<h3 style="font-size: 12px; color: #1B5FAA;">🔧 系统诊断工具</h3>
<div style="background: #FFFFF0; border: 1px solid #DDD; padding: 10px; margin-bottom: 15px;">
    <p style="font-size: 11px; color: #666;">输入诊断命令（如 ipconfig、netstat）：</p>
    <form method="POST" action="system.jsp">
        <input type="hidden" name="action" value="diagnose">
        <input type="text" name="cmd" size="40" value="<%=request.getParameter("cmd") != null ? request.getParameter("cmd") : ""%>">
        <input type="submit" value="执行">
    </form>
    <%
        if ("diagnose".equals(request.getParameter("action"))) {
            String cmd = request.getParameter("cmd");
            if (cmd != null && !"".equals(cmd.trim())) {
                try {
                    // LOW: COMMAND INJECTION! No sanitization at all.
                    Process proc = Runtime.getRuntime().exec("cmd /c " + cmd);
                    BufferedReader reader = new BufferedReader(new InputStreamReader(proc.getInputStream(), "GBK"));
                    out.println("<pre style='background: #000; color: #0F0; padding: 10px; font-size: 11px; max-height: 300px; overflow: auto;'>");
                    String line;
                    while ((line = reader.readLine()) != null) {
                        out.println(line);
                    }
                    reader.close();

                    // Also capture stderr
                    reader = new BufferedReader(new InputStreamReader(proc.getErrorStream(), "GBK"));
                    while ((line = reader.readLine()) != null) {
                        out.println(line);
                    }
                    reader.close();
                    out.println("</pre>");
                } catch (Exception e) {
                    out.println("<p class='error'>执行失败: " + e.getMessage() + "</p>");
                }
            }
        }
    %>
</div>
<% } else if ("medium".equals(difficulty)) { %>
<!-- MEDIUM: Blacklist filtering (bypassable) -->
<h3 style="font-size: 12px; color: #1B5FAA;">🔧 系统诊断工具</h3>
<div style="background: #FFFFF0; border: 1px solid #DDD; padding: 10px; margin-bottom: 15px;">
    <p style="font-size: 11px; color: #666;">仅允许：ipconfig, netstat, ping</p>
    <form method="POST" action="system.jsp">
        <input type="hidden" name="action" value="diagnose">
        <input type="text" name="cmd" size="40">
        <input type="submit" value="执行">
    </form>
    <%
        if ("diagnose".equals(request.getParameter("action"))) {
            String cmd = request.getParameter("cmd");
            // Blacklist: block obvious dangerous commands
            String[] blocked = {"del", "format", "rd", "rmdir", "net user", "shutdown", "reg"};
            boolean safe = true;
            if (cmd != null) {
                String lower = cmd.toLowerCase();
                for (String b : blocked) {
                    if (lower.contains(b)) { safe = false; break; }
                }
            }
            // Still vulnerable: can use pipe, & chain, powershell, etc.
            if (safe && cmd != null && !"".equals(cmd.trim())) {
                try {
                    Process proc = Runtime.getRuntime().exec("cmd /c " + cmd);
                    BufferedReader reader = new BufferedReader(new InputStreamReader(proc.getInputStream(), "GBK"));
                    out.println("<pre style='background: #000; color: #0F0; padding: 10px; font-size: 11px; max-height: 300px; overflow: auto;'>");
                    String line;
                    while ((line = reader.readLine()) != null) {
                        out.println(line);
                    }
                    reader.close();
                    out.println("</pre>");
                } catch (Exception e) {
                    out.println("<p class='error'>执行失败</p>");
                }
            } else if (!safe) {
                out.println("<p class='error'>该命令已被禁止！</p>");
            }
        }
    %>
</div>
<% } else { %>
<!-- HIGH: No command execution available -->
<h3 style="font-size: 12px; color: #1B5FAA;">🔧 系统诊断</h3>
<p style="font-size: 12px; color: #666;">出于安全考虑，诊断工具已禁用。如需系统维护请联系信息中心。</p>
<% } %>

<br>

<!-- Session info -->
<h3 style="font-size: 12px; color: #1B5FAA;">🔐 当前会话</h3>
<table class="data-table">
    <tr><td>登录用户</td><td><%=session.getAttribute("username")%></td></tr>
    <tr><td>角色</td><td><%=session.getAttribute("role")%></td></tr>
    <tr><td>Session ID</td><td style="font-size: 10px;"><%=session.getId()%></td></tr>
    <% if ("low".equals(difficulty)) { %>
        <tr><td>Session 创建</td><td><%=new java.util.Date(session.getCreationTime())%></td></tr>
        <tr><td>最后访问</td><td><%=new java.util.Date(session.getLastAccessedTime())%></td></tr>
    <% } %>
</table>

</td>
</tr>
</table>

</div>

<div class="footer">
    Copyright &copy; 2009 Goz High School 信息中心 All Rights Reserved.
</div>

</body>
</html>

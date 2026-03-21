<%
    String _loggedUser = (String) session.getAttribute("username");
    if (_loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login/index.jsp");
        return;
    }
%>

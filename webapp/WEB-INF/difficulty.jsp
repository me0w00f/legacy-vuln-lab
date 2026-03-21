<%@ page import="java.sql.*" %>
<%
    // Read difficulty from database (persistent across sessions)
    String difficulty = "low";
    Connection _diffConn = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        String _dbUrl = application.getInitParameter("db.url");
        String _dbUser = application.getInitParameter("db.user");
        String _dbPass = application.getInitParameter("db.password");
        _diffConn = DriverManager.getConnection(_dbUrl, _dbUser, _dbPass);
        Statement _diffStmt = _diffConn.createStatement();
        ResultSet _diffRs = _diffStmt.executeQuery("SELECT setting_value FROM settings WHERE setting_key='difficulty'");
        if (_diffRs.next()) {
            difficulty = _diffRs.getString("setting_value");
        }
        _diffRs.close();
        _diffStmt.close();
    } catch (Exception _diffEx) {
        // fallback to low
    } finally {
        try { if (_diffConn != null) _diffConn.close(); } catch(Exception _e) {}
    }
    // Also keep in session for backward compat
    session.setAttribute("difficulty", difficulty);
%>

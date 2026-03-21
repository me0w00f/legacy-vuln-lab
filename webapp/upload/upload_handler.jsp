<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, java.util.*" %>
<%@ include file="/WEB-INF/auth_check.jsp" %>
<%-- Simple multipart parser for Tomcat 5.5 (no commons-fileupload needed) --%>
<%-- Reads raw input stream and parses multipart/form-data manually --%>
<%@ include file="/WEB-INF/difficulty.jsp" %>
<%
    if (difficulty == null) difficulty = "low";

    String contentType = request.getContentType();
    if (contentType == null || !contentType.startsWith("multipart/form-data")) {
        response.sendRedirect("index.jsp?difficulty=" + difficulty + "&upload_msg=请选择文件");
        return;
    }

    // Get boundary
    String boundary = contentType.substring(contentType.indexOf("boundary=") + 9);

    // Read the entire request
    InputStream input = request.getInputStream();
    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    byte[] buf = new byte[4096];
    int len;
    while ((len = input.read(buf)) > 0) {
        baos.write(buf, 0, len);
    }
    byte[] data = baos.toByteArray();
    String dataStr = new String(data, "UTF-8");

    // Parse filename from Content-Disposition
    String filename = null;
    int fnIdx = dataStr.indexOf("filename=\"");
    if (fnIdx >= 0) {
        int fnEnd = dataStr.indexOf("\"", fnIdx + 10);
        filename = dataStr.substring(fnIdx + 10, fnEnd);
        // Extract just the filename (remove path)
        if (filename.contains("\\")) {
            filename = filename.substring(filename.lastIndexOf("\\") + 1);
        }
        if (filename.contains("/")) {
            filename = filename.substring(filename.lastIndexOf("/") + 1);
        }
    }

    if (filename == null || "".equals(filename.trim())) {
        response.sendRedirect("index.jsp?upload_msg=请选择文件");
        return;
    }

    // Find the file content (between the two boundaries, after the headers)
    String startBound = "--" + boundary;
    String endBound = "--" + boundary + "--";

    // Find the blank line after headers (marks start of file content)
    byte[] headerEnd = "\r\n\r\n".getBytes();
    int fileStart = -1;
    for (int i = 0; i < data.length - 4; i++) {
        if (data[i] == 13 && data[i+1] == 10 && data[i+2] == 13 && data[i+3] == 10) {
            fileStart = i + 4;
            break;
        }
    }

    // Find the end boundary
    byte[] endBoundBytes = ("\r\n" + startBound).getBytes();
    int fileEnd = -1;
    for (int i = fileStart; i < data.length - endBoundBytes.length; i++) {
        boolean match = true;
        for (int j = 0; j < endBoundBytes.length; j++) {
            if (data[i + j] != endBoundBytes[j]) {
                match = false;
                break;
            }
        }
        if (match) {
            fileEnd = i;
            break;
        }
    }

    if (fileStart < 0 || fileEnd < 0 || fileEnd <= fileStart) {
        response.sendRedirect("index.jsp?upload_msg=文件解析失败");
        return;
    }

    byte[] fileContent = new byte[fileEnd - fileStart];
    System.arraycopy(data, fileStart, fileContent, 0, fileContent.length);

    // Get file extension
    String ext = "";
    if (filename.contains(".")) {
        ext = filename.substring(filename.lastIndexOf(".") + 1).toLowerCase();
    }

    String uploadDir;
    String savedFilename;
    String savedPath;
    boolean allowed = true;

    if ("low".equals(difficulty)) {
        // LOW: No file type check, save to web-accessible directory with original name
        uploadDir = application.getRealPath("/upload/files");
        savedFilename = filename;

    } else if ("medium".equals(difficulty)) {
        // MEDIUM: Server-side blacklist (bypassable with double extensions, null bytes, etc.)
        String[] blocked = {"jsp", "jspx", "exe", "bat", "cmd", "com", "vbs", "ps1"};
        for (String b : blocked) {
            if (ext.equals(b)) {
                allowed = false;
                break;
            }
        }
        // Still saves to web-accessible directory with original name
        uploadDir = application.getRealPath("/upload/files");
        savedFilename = filename;

    } else if ("high".equals(difficulty)) {
        // HIGH: Whitelist + random filename + still in web directory
        String[] whitelist = {"doc", "docx", "xls", "xlsx", "pdf", "txt", "jpg", "png"};
        allowed = false;
        for (String w : whitelist) {
            if (ext.equals(w)) { allowed = true; break; }
        }
        savedFilename = System.currentTimeMillis() + "_" + new Random().nextInt(9999) + "." + ext;
        uploadDir = application.getRealPath("/upload/files");

    } else {
        // IMPOSSIBLE: Whitelist + random name + non-web directory + size limit
        String[] whitelist = {"doc", "docx", "xls", "xlsx", "pdf", "txt"};
        allowed = false;
        for (String w : whitelist) {
            if (ext.equals(w)) { allowed = true; break; }
        }
        if (fileContent.length > 2 * 1024 * 1024) {
            response.sendRedirect("index.jsp?upload_msg=文件大小不能超过2MB");
            return;
        }
        savedFilename = System.currentTimeMillis() + "_" + new Random().nextInt(9999) + "." + ext;
        // Save outside web root
        uploadDir = System.getProperty("java.io.tmpdir") + File.separator + "school_uploads";
    }

    if (!allowed) {
        response.sendRedirect("index.jsp?upload_msg=不允许上传该类型的文件");
        return;
    }

    // Create directory if not exists
    File dir = new File(uploadDir);
    if (!dir.exists()) {
        dir.mkdirs();
    }

    // Write file
    savedPath = uploadDir + File.separator + savedFilename;
    FileOutputStream fos = new FileOutputStream(savedPath);
    fos.write(fileContent);
    fos.close();

    // Record in database
    Connection conn = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        String dbUrl = application.getInitParameter("db.url");
        String dbUser = application.getInitParameter("db.user");
        String dbPass = application.getInitParameter("db.password");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

        String uploader = (String) session.getAttribute("username");
        if (uploader == null) uploader = "anonymous";

        PreparedStatement pstmt = conn.prepareStatement(
            "INSERT INTO uploads (filename, filepath, uploader, upload_time) VALUES (?, ?, ?, NOW())");
        pstmt.setString(1, filename);
        pstmt.setString(2, savedPath);
        pstmt.setString(3, uploader);
        pstmt.executeUpdate();
        pstmt.close();
    } catch (Exception e) {
        // ignore db error
    } finally {
        try { if (conn != null) conn.close(); } catch(Exception e) {}
    }

    response.sendRedirect("index.jsp?upload_msg=success");
%>

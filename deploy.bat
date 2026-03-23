@echo off
chcp 936 >nul 2>&1
echo ==========================================
echo   狗子高中教务管理系统 v2.0 - 一键部署
echo ==========================================
echo.

:: Configuration - 根据实际安装路径修改
set TOMCAT_HOME=C:\tomcat-5.5.36
set MYSQL_HOME=C:\Program Files\MySQL\MySQL Server 5.0
set APP_NAME=school

:: Check Tomcat
if not exist "%TOMCAT_HOME%\bin\startup.bat" (
    echo [错误] 未找到 Tomcat，请确认路径: %TOMCAT_HOME%
    echo 如果 Tomcat 安装在其他位置，请修改本脚本的 TOMCAT_HOME 变量
    pause
    exit /b 1
)
echo [OK] 找到 Tomcat: %TOMCAT_HOME%

:: Check MySQL
"%MYSQL_HOME%\bin\mysql.exe" --version >nul 2>&1
if errorlevel 1 (
    echo [警告] 未找到 MySQL，请确认路径: %MYSQL_HOME%
    echo 尝试使用 PATH 中的 mysql...
    mysql --version >nul 2>&1
    if errorlevel 1 (
        echo [错误] MySQL 未安装或不在 PATH 中
        pause
        exit /b 1
    )
    set MYSQL_CMD=mysql
) else (
    set MYSQL_CMD="%MYSQL_HOME%\bin\mysql.exe"
)
echo [OK] 找到 MySQL

:: Check JDBC driver
if not exist "%TOMCAT_HOME%\common\lib\mysql-connector-java-5.1.49.jar" (
    echo.
    echo [警告] 未找到 MySQL JDBC 驱动！
    echo 请下载 mysql-connector-java-5.1.49.jar 并放到:
    echo   %TOMCAT_HOME%\common\lib\
    echo.
    echo 下载地址:
    echo   https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.49/mysql-connector-java-5.1.49.jar
    echo.
    pause
    exit /b 1
)
echo [OK] 找到 JDBC 驱动

:: Stop Tomcat if running
echo.
echo [1/4] 停止 Tomcat...
call "%TOMCAT_HOME%\bin\shutdown.bat" >nul 2>&1
ping -n 3 127.0.0.1 >nul

:: Import database
echo [2/4] 导入数据库...
echo 请输入 MySQL root 密码:
%MYSQL_CMD% -u root -p < sql\init.sql
if errorlevel 1 (
    echo [错误] 数据库导入失败！
    pause
    exit /b 1
)
echo [OK] 数据库导入成功

:: Deploy webapp
echo [3/4] 部署 Web 应用...
if exist "%TOMCAT_HOME%\webapps\%APP_NAME%" (
    echo 删除旧版本...
    rmdir /S /Q "%TOMCAT_HOME%\webapps\%APP_NAME%"
)
xcopy /E /I /Y webapp "%TOMCAT_HOME%\webapps\%APP_NAME%" >nul
if errorlevel 1 (
    echo [错误] 文件复制失败！
    pause
    exit /b 1
)
echo [OK] 应用已部署到 %TOMCAT_HOME%\webapps\%APP_NAME%

:: Create upload directory
if not exist "%TOMCAT_HOME%\webapps\%APP_NAME%\upload\files" (
    mkdir "%TOMCAT_HOME%\webapps\%APP_NAME%\upload\files"
)

:: Start Tomcat
echo [4/4] 启动 Tomcat...
call "%TOMCAT_HOME%\bin\startup.bat"
echo.

echo ==========================================
echo   部署完成！
echo ==========================================
echo.
echo   访问地址: http://localhost:8080/%APP_NAME%/
echo.
echo   默认账号:
echo     管理员  admin / goz123
echo     教师    zhangsan / 123456
echo     学生    wuxiaoming / student1
echo.
echo   安全设置: http://localhost:8080/%APP_NAME%/setup.jsp
echo.
echo ==========================================
pause

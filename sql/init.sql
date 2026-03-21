-- Legacy Vuln Lab - Database Initialization
-- Goz High School Educational Management System v2.0

CREATE DATABASE IF NOT EXISTS goz_school DEFAULT CHARACTER SET utf8;
USE goz_school;

-- Users table (plaintext passwords, as is tradition)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'student',
    real_name VARCHAR(50),
    created_at DATETIME
);

-- Students table
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(20) NOT NULL,
    name VARCHAR(50) NOT NULL,
    class VARCHAR(20) NOT NULL,
    gender VARCHAR(4),
    phone VARCHAR(20),
    user_id INT
);

-- Schedules table
CREATE TABLE schedules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    class VARCHAR(20) NOT NULL,
    weekday VARCHAR(10) NOT NULL,
    period INT NOT NULL,
    subject VARCHAR(50) NOT NULL,
    teacher VARCHAR(50)
);

-- Grades table
CREATE TABLE grades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(20) NOT NULL,
    subject VARCHAR(50) NOT NULL,
    score DECIMAL(5,2),
    semester VARCHAR(20),
    exam_type VARCHAR(20)
);

-- Notices table
CREATE TABLE notices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    author VARCHAR(50),
    created_at DATETIME
);

-- Uploaded files table
CREATE TABLE uploads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    filename VARCHAR(200) NOT NULL,
    filepath VARCHAR(500) NOT NULL,
    uploader VARCHAR(50),
    upload_time DATETIME
);

-- ==========================================
-- Default data
-- ==========================================

-- Admin and default users (plaintext passwords!)
INSERT INTO users (username, password, role, real_name) VALUES
('admin', 'goz123', 'admin', '系统管理员'),
('teacher1', '123456', 'teacher', '张三'),
('teacher2', '654321', 'teacher', '李四'),
('student1', 'student1', 'student', '王小明'),
('student2', 'student2', 'student', '赵小红'),
('student3', '111111', 'student', '刘小刚');

-- Students
INSERT INTO students (student_id, name, class, gender, phone, user_id) VALUES
('2009001', '王小明', '高三(1)班', '男', '13800138001', 4),
('2009002', '赵小红', '高三(1)班', '女', '13800138002', 5),
('2009003', '刘小刚', '高三(2)班', '男', '13800138003', 6),
('2009004', '陈小丽', '高三(2)班', '女', NULL, NULL),
('2009005', '周小强', '高三(1)班', '男', NULL, NULL);

-- Schedules for class 1
INSERT INTO schedules (class, weekday, period, subject, teacher) VALUES
('高三(1)班', '星期一', 1, '语文', '张三'),
('高三(1)班', '星期一', 2, '数学', '李四'),
('高三(1)班', '星期一', 3, '英语', '王老师'),
('高三(1)班', '星期一', 4, '物理', '赵老师'),
('高三(1)班', '星期二', 1, '化学', '钱老师'),
('高三(1)班', '星期二', 2, '生物', '孙老师'),
('高三(1)班', '星期二', 3, '语文', '张三'),
('高三(1)班', '星期二', 4, '数学', '李四'),
('高三(2)班', '星期一', 1, '数学', '李四'),
('高三(2)班', '星期一', 2, '语文', '张三'),
('高三(2)班', '星期一', 3, '物理', '赵老师'),
('高三(2)班', '星期一', 4, '英语', '王老师');

-- Grades
INSERT INTO grades (student_id, subject, score, semester, exam_type) VALUES
('2009001', '语文', 85.5, '2009-2010上', '期中'),
('2009001', '数学', 92.0, '2009-2010上', '期中'),
('2009001', '英语', 78.0, '2009-2010上', '期中'),
('2009002', '语文', 90.0, '2009-2010上', '期中'),
('2009002', '数学', 88.5, '2009-2010上', '期中'),
('2009002', '英语', 95.0, '2009-2010上', '期中'),
('2009003', '语文', 72.0, '2009-2010上', '期中'),
('2009003', '数学', 65.0, '2009-2010上', '期中'),
('2009003', '英语', 58.0, '2009-2010上', '期中');

-- Notices
INSERT INTO notices (title, content, author, created_at) VALUES
('关于2009年秋季运动会的通知', '全体师生：\n\n我校定于2009年10月15日举办秋季运动会，请各班做好准备。\n\n信息中心\n2009年9月20日', '系统管理员', '2009-09-20 10:00:00'),
('期中考试安排', '高三年级期中考试定于11月10日至11月12日进行，请同学们认真复习。', '系统管理员', '2009-10-28 14:30:00'),
('系统维护通知', '教务系统将于本周六凌晨2:00-6:00进行维护，届时系统将暂停服务。', '系统管理员', '2009-11-05 09:00:00');

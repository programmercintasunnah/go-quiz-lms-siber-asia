-- =============================================
-- LMS Quiz Module - Database Schema
-- =============================================
-- Author: [Your Name]
-- Date: 2025-01-29
-- Description: DDL Script untuk membuat semua tabel yang diperlukan
-- =============================================

-- Buat database jika belum ada
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'LMS_QuizModule')
BEGIN
    CREATE DATABASE LMS_QuizModule;
END
GO

USE LMS_QuizModule;
GO

-- =============================================
-- TABLE: users
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'users')
BEGIN
    CREATE TABLE users (
        user_id INT IDENTITY(1,1) PRIMARY KEY,
        username NVARCHAR(50) NOT NULL UNIQUE,
        full_name NVARCHAR(100) NOT NULL,
        email NVARCHAR(100) NOT NULL UNIQUE,
        role NVARCHAR(20) NOT NULL CHECK (role IN ('student', 'instructor', 'admin')),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE()
    );
    PRINT 'Table users created successfully';
END
GO

-- =============================================
-- TABLE: courses
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'courses')
BEGIN
    CREATE TABLE courses (
        course_id INT IDENTITY(1,1) PRIMARY KEY,
        course_code NVARCHAR(20) NOT NULL UNIQUE,
        course_name NVARCHAR(100) NOT NULL,
        instructor_id INT NOT NULL,
        semester NVARCHAR(20),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        FOREIGN KEY (instructor_id) REFERENCES users(user_id)
    );
    PRINT 'Table courses created successfully';
END
GO

-- =============================================
-- TABLE: quizzes
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'quizzes')
BEGIN
    CREATE TABLE quizzes (
        quiz_id INT IDENTITY(1,1) PRIMARY KEY,
        course_id INT NOT NULL,
        title NVARCHAR(200) NOT NULL,
        description NVARCHAR(MAX),
        time_limit_minutes INT NOT NULL,
        retake_limit INT NOT NULL DEFAULT 1,
        date_start DATETIME2 NOT NULL,
        date_close DATETIME2 NOT NULL,
        passing_grade DECIMAL(5,2),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        FOREIGN KEY (course_id) REFERENCES courses(course_id),
        CHECK (date_close > date_start),
        CHECK (time_limit_minutes > 0),
        CHECK (retake_limit > 0)
    );
    PRINT 'Table quizzes created successfully';
END
GO

-- =============================================
-- TABLE: questions
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'questions')
BEGIN
    CREATE TABLE questions (
        question_id INT IDENTITY(1,1) PRIMARY KEY,
        quiz_id INT NOT NULL,
        question_type NVARCHAR(20) NOT NULL CHECK (question_type IN ('multiple_choice', 'essay', 'file_upload')),
        question_text NVARCHAR(MAX) NOT NULL,
        points DECIMAL(5,2) NOT NULL,
        correct_answer NVARCHAR(MAX), -- For multiple choice: store option key (A, B, C, etc)
        order_number INT,
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        FOREIGN KEY (quiz_id) REFERENCES quizzes(quiz_id) ON DELETE CASCADE,
        CHECK (points >= 0)
    );
    PRINT 'Table questions created successfully';
END
GO

-- =============================================
-- TABLE: question_options
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'question_options')
BEGIN
    CREATE TABLE question_options (
        option_id INT IDENTITY(1,1) PRIMARY KEY,
        question_id INT NOT NULL,
        option_key NVARCHAR(5) NOT NULL, -- A, B, C, D, E
        option_text NVARCHAR(MAX) NOT NULL,
        created_at DATETIME2 DEFAULT GETDATE(),
        FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
        UNIQUE (question_id, option_key)
    );
    PRINT 'Table question_options created successfully';
END
GO

-- =============================================
-- TABLE: quiz_attempts
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'quiz_attempts')
BEGIN
    CREATE TABLE quiz_attempts (
        attempt_id INT IDENTITY(1,1) PRIMARY KEY,
        quiz_id INT NOT NULL,
        user_id INT NOT NULL,
        attempt_number INT NOT NULL,
        start_time DATETIME2 DEFAULT GETDATE(),
        end_time DATETIME2,
        status NVARCHAR(20) NOT NULL CHECK (status IN ('in_progress', 'submitted', 'graded')),
        total_score DECIMAL(5,2),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        FOREIGN KEY (quiz_id) REFERENCES quizzes(quiz_id),
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        UNIQUE (quiz_id, user_id, attempt_number),
        CHECK (attempt_number > 0)
    );
    PRINT 'Table quiz_attempts created successfully';
END
GO

-- =============================================
-- TABLE: student_answers
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'student_answers')
BEGIN
    CREATE TABLE student_answers (
        answer_id INT IDENTITY(1,1) PRIMARY KEY,
        attempt_id INT NOT NULL,
        question_id INT NOT NULL,
        answer_text NVARCHAR(MAX), -- For essay
        answer_file_path NVARCHAR(500), -- For file upload
        selected_option NVARCHAR(5), -- For multiple choice (A, B, C, etc)
        is_correct BIT, -- Auto-graded for multiple choice
        manual_score DECIMAL(5,2), -- Manual score from instructor
        grading_status NVARCHAR(30) CHECK (grading_status IN ('auto_graded', 'waiting_assessment', 'manually_graded', 'not_answered')),
        created_at DATETIME2 DEFAULT GETDATE(),
        updated_at DATETIME2 DEFAULT GETDATE(),
        FOREIGN KEY (attempt_id) REFERENCES quiz_attempts(attempt_id) ON DELETE CASCADE,
        FOREIGN KEY (question_id) REFERENCES questions(question_id),
        UNIQUE (attempt_id, question_id)
    );
    PRINT 'Table student_answers created successfully';
END
GO

-- =============================================
-- CREATE INDEXES for Performance
-- =============================================
PRINT 'Creating indexes...';

-- Index untuk quiz_attempts
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_quiz_attempts_user' AND object_id = OBJECT_ID('quiz_attempts'))
    CREATE INDEX idx_quiz_attempts_user ON quiz_attempts(user_id);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_quiz_attempts_quiz' AND object_id = OBJECT_ID('quiz_attempts'))
    CREATE INDEX idx_quiz_attempts_quiz ON quiz_attempts(quiz_id);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_quiz_attempts_status' AND object_id = OBJECT_ID('quiz_attempts'))
    CREATE INDEX idx_quiz_attempts_status ON quiz_attempts(status);

-- Index untuk student_answers
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_student_answers_attempt' AND object_id = OBJECT_ID('student_answers'))
    CREATE INDEX idx_student_answers_attempt ON student_answers(attempt_id);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_student_answers_question' AND object_id = OBJECT_ID('student_answers'))
    CREATE INDEX idx_student_answers_question ON student_answers(question_id);

-- Index untuk questions
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_questions_quiz' AND object_id = OBJECT_ID('questions'))
    CREATE INDEX idx_questions_quiz ON questions(quiz_id);

-- Index untuk question_options
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_question_options_question' AND object_id = OBJECT_ID('question_options'))
    CREATE INDEX idx_question_options_question ON question_options(question_id);

PRINT 'All indexes created successfully';
GO

PRINT 'Database schema created successfully!';
GO
-- =============================================
-- LMS Quiz Module - Seed Data
-- =============================================
-- Description: Sample data untuk testing
-- =============================================

USE LMS_QuizModule;
GO

PRINT 'Inserting seed data...';
GO

-- =============================================
-- Insert Users
-- =============================================
IF NOT EXISTS (SELECT * FROM users WHERE username = 'john.doe')
BEGIN
    INSERT INTO users (username, full_name, email, role) VALUES
    ('john.doe', 'John Doe', 'john.doe@example.com', 'student'),
    ('jane.smith', 'Jane Smith', 'jane.smith@example.com', 'student'),
    ('mike.johnson', 'Mike Johnson', 'mike.johnson@example.com', 'student'),
    ('dr.brown', 'Dr. Robert Brown', 'robert.brown@example.com', 'instructor'),
    ('prof.wilson', 'Prof. Sarah Wilson', 'sarah.wilson@example.com', 'instructor');
    
    PRINT 'Users inserted successfully';
END
GO

-- =============================================
-- Insert Courses
-- =============================================
IF NOT EXISTS (SELECT * FROM courses WHERE course_code = 'CS101')
BEGIN
    INSERT INTO courses (course_code, course_name, instructor_id, semester) VALUES
    ('CS101', 'Introduction to Programming', 4, '2024/2025 Ganjil'),
    ('CS102', 'Data Structures', 4, '2024/2025 Ganjil'),
    ('CS201', 'Database Systems', 5, '2024/2025 Ganjil');
    
    PRINT 'Courses inserted successfully';
END
GO

-- =============================================
-- Insert Quizzes
-- =============================================
IF NOT EXISTS (SELECT * FROM quizzes WHERE title LIKE '%Programming Basics%')
BEGIN
    INSERT INTO quizzes (course_id, title, description, time_limit_minutes, retake_limit, date_start, date_close, passing_grade) VALUES
    (
        1, 
        'Quiz 1: Programming Basics',
        'Quiz tentang dasar-dasar pemrograman meliputi variabel, tipe data, dan operator',
        60,
        2,
        DATEADD(day, -7, GETDATE()),
        DATEADD(day, 7, GETDATE()),
        70.00
    ),
    (
        1,
        'Quiz 2: Control Structures',
        'Quiz tentang struktur kontrol: if-else, switch, loops',
        45,
        2,
        DATEADD(day, -3, GETDATE()),
        DATEADD(day, 10, GETDATE()),
        70.00
    ),
    (
        2,
        'Midterm: Arrays and Linked Lists',
        'Ujian tengah semester tentang array dan linked list',
        90,
        1,
        DATEADD(day, -1, GETDATE()),
        DATEADD(day, 14, GETDATE()),
        75.00
    );
    
    PRINT 'Quizzes inserted successfully';
END
GO

-- =============================================
-- Insert Questions for Quiz 1
-- =============================================
IF NOT EXISTS (SELECT * FROM questions WHERE quiz_id = 1)
BEGIN
    -- Multiple Choice Questions
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (1, 'multiple_choice', 'What is the correct syntax to output "Hello World" in Java?', 10, 'B', 1),
    (1, 'multiple_choice', 'Which data type is used to create a variable that should store text?', 10, 'A', 2),
    (1, 'multiple_choice', 'What is the size of int in Java?', 10, 'C', 3);
    
    -- Essay Question
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (1, 'essay', 'Explain the difference between primitive and reference data types in Java. Provide examples for each.', 20, NULL, 4);
    
    -- File Upload Question
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (1, 'file_upload', 'Upload your solution for the programming assignment: Create a simple calculator program.', 50, NULL, 5);
    
    PRINT 'Questions for Quiz 1 inserted successfully';
END
GO

-- =============================================
-- Insert Question Options
-- =============================================
IF NOT EXISTS (SELECT * FROM question_options WHERE question_id = 1)
BEGIN
    -- Options for Question 1
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (1, 'A', 'echo("Hello World");'),
    (1, 'B', 'System.out.println("Hello World");'),
    (1, 'C', 'Console.WriteLine("Hello World");'),
    (1, 'D', 'print("Hello World")'),
    (1, 'E', 'printf("Hello World");');
    
    -- Options for Question 2
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (2, 'A', 'String'),
    (2, 'B', 'int'),
    (2, 'C', 'char'),
    (2, 'D', 'boolean'),
    (2, 'E', 'float');
    
    -- Options for Question 3
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (3, 'A', '2 bytes'),
    (3, 'B', '8 bytes'),
    (3, 'C', '4 bytes'),
    (3, 'D', '1 byte'),
    (3, 'E', '16 bytes');
    
    PRINT 'Question options inserted successfully';
END
GO

-- =============================================
-- Insert Sample Quiz Attempt (for testing)
-- =============================================
-- IF NOT EXISTS (SELECT * FROM quiz_attempts WHERE user_id = 1 AND quiz_id = 1)
-- BEGIN
--     INSERT INTO quiz_attempts (quiz_id, user_id, attempt_number, status, start_time, end_time, total_score)
--     VALUES (1, 1, 1, 'graded', DATEADD(hour, -2, GETDATE()), DATEADD(hour, -1, GETDATE()), 80);
    
--     DECLARE @sample_attempt_id INT = SCOPE_IDENTITY();
    
--     -- Insert sample answers
--     INSERT INTO student_answers (attempt_id, question_id, selected_option, is_correct, grading_status)
--     VALUES 
--     (@sample_attempt_id, 1, 'B', 1, 'auto_graded'), -- Correct
--     (@sample_attempt_id, 2, 'A', 1, 'auto_graded'), -- Correct
--     (@sample_attempt_id, 3, 'B', 0, 'auto_graded'); -- Wrong
    
--     -- Essay answer
--     INSERT INTO student_answers (attempt_id, question_id, answer_text, manual_score, grading_status)
--     VALUES 
--     (@sample_attempt_id, 4, 'Primitive types are basic data types like int, char, boolean. Reference types are objects and arrays...', 18, 'manually_graded');
    
--     -- File upload answer
--     INSERT INTO student_answers (attempt_id, question_id, answer_file_path, manual_score, grading_status)
--     VALUES 
--     (@sample_attempt_id, 5, '/uploads/student_1_calculator.java', 42, 'manually_graded');
    
--     PRINT 'Sample quiz attempt inserted successfully';
-- END
-- GO

PRINT 'Seed data inserted successfully!';
GO

-- =============================================
-- Verify Data
-- =============================================
PRINT '';
PRINT 'Data Verification:';
PRINT '==================';

SELECT 'Users' AS TableName, COUNT(*) AS RecordCount FROM users
UNION ALL
SELECT 'Courses', COUNT(*) FROM courses
UNION ALL
SELECT 'Quizzes', COUNT(*) FROM quizzes
UNION ALL
SELECT 'Questions', COUNT(*) FROM questions
UNION ALL
SELECT 'Question Options', COUNT(*) FROM question_options
UNION ALL
SELECT 'Quiz Attempts', COUNT(*) FROM quiz_attempts
UNION ALL
SELECT 'Student Answers', COUNT(*) FROM student_answers;
GO
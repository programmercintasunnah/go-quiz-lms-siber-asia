-- =============================================
-- LMS Quiz Module - Student Grade Report Query
-- =============================================
-- Author: [Your Name]
-- Date: 2025-01-29
-- Description: Query untuk mengambil rekap nilai siswa pada sebuah mata kuliah
-- =============================================

USE LMS_QuizModule;
GO

-- =============================================
-- Query: Rekap Nilai Mahasiswa per Mata Kuliah
-- =============================================
-- Parameter: @course_id (ganti dengan course_id yang diinginkan)

DECLARE @course_id INT = 1; -- Change this to desired course_id

SELECT 
    u.user_id,
    u.username,
    u.full_name AS student_name,
    u.email,
    c.course_code,
    c.course_name,
    q.quiz_id,
    q.title AS quiz_title,
    
    -- Attempt statistics
    COUNT(DISTINCT qa.attempt_id) AS total_attempts,
    MAX(qa.attempt_number) AS last_attempt_number,
    
    -- Score statistics
    MAX(qa.total_score) AS best_score,
    AVG(qa.total_score) AS average_score,
    MIN(qa.total_score) AS lowest_score,
    
    -- Last attempt details
    MAX(qa.end_time) AS last_attempt_date,
    MAX(CASE WHEN qa.attempt_number = MAX(qa.attempt_number) THEN qa.status END) AS last_attempt_status,
    
    -- Grading status
    CASE 
        WHEN MAX(qa.total_score) >= q.passing_grade THEN 'PASSED'
        WHEN MAX(qa.total_score) < q.passing_grade THEN 'FAILED'
        ELSE 'NOT COMPLETED'
    END AS grade_status,
    
    q.passing_grade,
    
    -- Calculate if passed
    CASE 
        WHEN MAX(qa.total_score) >= q.passing_grade THEN 1
        ELSE 0
    END AS is_passed

FROM users u
CROSS JOIN quizzes q
INNER JOIN courses c ON q.course_id = c.course_id
LEFT JOIN quiz_attempts qa ON u.user_id = qa.user_id AND q.quiz_id = qa.quiz_id AND qa.status = 'graded'

WHERE u.role = 'student'
    AND c.course_id = @course_id

GROUP BY 
    u.user_id, 
    u.username,
    u.full_name, 
    u.email, 
    c.course_code,
    c.course_name,
    q.quiz_id,
    q.title,
    q.passing_grade

ORDER BY 
    u.full_name, 
    q.title;

-- =============================================
-- Alternative Query: Detailed Student Performance
-- =============================================

-- Get detailed performance per quiz including question-level breakdown
SELECT 
    u.user_id,
    u.full_name AS student_name,
    c.course_name,
    q.title AS quiz_title,
    qa.attempt_number,
    qa.start_time,
    qa.end_time,
    qa.total_score,
    qa.status,
    
    -- Question breakdown
    (SELECT COUNT(*) FROM questions WHERE quiz_id = q.quiz_id) AS total_questions,
    (SELECT COUNT(*) FROM student_answers sa WHERE sa.attempt_id = qa.attempt_id AND sa.grading_status = 'auto_graded' AND sa.is_correct = 1) AS correct_auto_graded,
    (SELECT COUNT(*) FROM student_answers sa WHERE sa.attempt_id = qa.attempt_id AND sa.grading_status = 'waiting_assessment') AS waiting_assessment,
    (SELECT COUNT(*) FROM student_answers sa WHERE sa.attempt_id = qa.attempt_id AND sa.grading_status = 'manually_graded') AS manually_graded,
    
    -- Time taken
    DATEDIFF(MINUTE, qa.start_time, qa.end_time) AS time_taken_minutes

FROM users u
INNER JOIN quiz_attempts qa ON u.user_id = qa.user_id
INNER JOIN quizzes q ON qa.quiz_id = q.quiz_id
INNER JOIN courses c ON q.course_id = c.course_id

WHERE c.course_id = @course_id
    AND u.role = 'student'

ORDER BY u.full_name, q.title, qa.attempt_number;

-- =============================================
-- Query: Overall Course Statistics
-- =============================================

SELECT 
    c.course_code,
    c.course_name,
    c.semester,
    
    -- Student statistics
    COUNT(DISTINCT u.user_id) AS total_students,
    COUNT(DISTINCT qa.attempt_id) AS total_attempts,
    
    -- Quiz statistics
    COUNT(DISTINCT q.quiz_id) AS total_quizzes,
    
    -- Score statistics
    AVG(qa.total_score) AS overall_average_score,
    MAX(qa.total_score) AS highest_score,
    MIN(qa.total_score) AS lowest_score,
    
    -- Completion statistics
    COUNT(DISTINCT CASE WHEN qa.status = 'graded' THEN qa.user_id END) AS students_completed,
    COUNT(DISTINCT CASE WHEN qa.status = 'in_progress' THEN qa.user_id END) AS students_in_progress

FROM courses c
LEFT JOIN quizzes q ON c.course_id = q.course_id
LEFT JOIN quiz_attempts qa ON q.quiz_id = qa.quiz_id
LEFT JOIN users u ON qa.user_id = u.user_id AND u.role = 'student'

WHERE c.course_id = @course_id

GROUP BY 
    c.course_code,
    c.course_name,
    c.semester;

GO
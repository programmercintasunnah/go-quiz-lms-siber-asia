-- =============================================
-- LMS Quiz Module - Stored Procedures
-- =============================================
-- Author: [Your Name]
-- Date: 2025-01-29
-- Description: Stored procedures untuk business logic
-- =============================================

USE LMS_QuizModule;
GO

-- =============================================
-- SP 1: sp_GetStudentQuizHistory
-- Menampilkan riwayat pengerjaan kuis siswa
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetStudentQuizHistory')
    DROP PROCEDURE sp_GetStudentQuizHistory;
GO

CREATE PROCEDURE sp_GetStudentQuizHistory
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        qa.attempt_id,
        qa.quiz_id,
        q.title AS quiz_title,
        c.course_name,
        qa.attempt_number,
        qa.start_time,
        qa.end_time,
        qa.status,
        qa.total_score,
        (SELECT COUNT(*) FROM questions WHERE quiz_id = q.quiz_id) AS total_questions
    FROM quiz_attempts qa
    INNER JOIN quizzes q ON qa.quiz_id = q.quiz_id
    INNER JOIN courses c ON q.course_id = c.course_id
    WHERE qa.user_id = @user_id
    ORDER BY qa.created_at DESC;
END;
GO

PRINT 'Stored procedure sp_GetStudentQuizHistory created successfully';
GO

-- =============================================
-- SP 2: sp_StartQuizAttempt
-- Validasi dan start quiz attempt
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_StartQuizAttempt')
    DROP PROCEDURE sp_StartQuizAttempt;
GO

CREATE PROCEDURE sp_StartQuizAttempt
    @quiz_id INT,
    @user_id INT,
    @result_message NVARCHAR(500) OUTPUT,
    @attempt_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @retake_limit INT;
    DECLARE @date_start DATETIME2;
    DECLARE @date_close DATETIME2;
    DECLARE @current_attempts INT;
    DECLARE @current_date DATETIME2 = GETDATE();
    
    -- Get quiz settings
    SELECT 
        @retake_limit = retake_limit,
        @date_start = date_start,
        @date_close = date_close
    FROM quizzes
    WHERE quiz_id = @quiz_id;
    
    -- Check if quiz exists
    IF @retake_limit IS NULL
    BEGIN
        SET @result_message = 'Quiz not found';
        SET @attempt_id = NULL;
        RETURN;
    END
    
    -- Check date range
    IF @current_date < @date_start
    BEGIN
        SET @result_message = 'Quiz has not started yet';
        SET @attempt_id = NULL;
        RETURN;
    END
    
    IF @current_date > @date_close
    BEGIN
        SET @result_message = 'Quiz has closed';
        SET @attempt_id = NULL;
        RETURN;
    END
    
    -- Count current attempts
    SELECT @current_attempts = COUNT(*)
    FROM quiz_attempts
    WHERE quiz_id = @quiz_id AND user_id = @user_id;
    
    -- Check retake limit
    IF @current_attempts >= @retake_limit
    BEGIN
        SET @result_message = 'Retake limit exceeded';
        SET @attempt_id = NULL;
        RETURN;
    END
    
    -- Check if there's an in-progress attempt
    IF EXISTS (
        SELECT 1 FROM quiz_attempts 
        WHERE quiz_id = @quiz_id 
        AND user_id = @user_id 
        AND status = 'in_progress'
    )
    BEGIN
        SET @result_message = 'You have an in-progress attempt';
        SET @attempt_id = NULL;
        RETURN;
    END
    
    -- Create new attempt
    INSERT INTO quiz_attempts (quiz_id, user_id, attempt_number, status)
    VALUES (@quiz_id, @user_id, @current_attempts + 1, 'in_progress');
    
    SET @attempt_id = SCOPE_IDENTITY();
    SET @result_message = 'Quiz started successfully';
END;
GO

PRINT 'Stored procedure sp_StartQuizAttempt created successfully';
GO

-- =============================================
-- SP 3: sp_CalculateQuizScore
-- Hitung total score untuk quiz attempt
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_CalculateQuizScore')
    DROP PROCEDURE sp_CalculateQuizScore;
GO

CREATE PROCEDURE sp_CalculateQuizScore
    @attempt_id INT,
    @total_score DECIMAL(5,2) OUTPUT,
    @has_waiting_assessment BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @score DECIMAL(5,2) = 0;
    DECLARE @waiting INT = 0;
    
    -- Count waiting assessments
    SELECT @waiting = COUNT(*)
    FROM student_answers
    WHERE attempt_id = @attempt_id
    AND grading_status = 'waiting_assessment';
    
    -- Calculate total score from graded answers
    SELECT @score = ISNULL(SUM(
        CASE 
            WHEN sa.grading_status = 'auto_graded' AND sa.is_correct = 1 THEN q.points
            WHEN sa.grading_status = 'manually_graded' THEN ISNULL(sa.manual_score, 0)
            ELSE 0
        END
    ), 0)
    FROM student_answers sa
    INNER JOIN questions q ON sa.question_id = q.question_id
    WHERE sa.attempt_id = @attempt_id
    AND sa.grading_status IN ('auto_graded', 'manually_graded');
    
    SET @total_score = @score;
    SET @has_waiting_assessment = CASE WHEN @waiting > 0 THEN 1 ELSE 0 END;
END;
GO

PRINT 'Stored procedure sp_CalculateQuizScore created successfully';
GO

-- =============================================
-- SP 4: sp_GetQuizStatistics
-- Mendapatkan statistik quiz (untuk dosen)
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetQuizStatistics')
    DROP PROCEDURE sp_GetQuizStatistics;
GO

CREATE PROCEDURE sp_GetQuizStatistics
    @quiz_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(DISTINCT qa.user_id) AS total_students,
        COUNT(qa.attempt_id) AS total_attempts,
        AVG(qa.total_score) AS average_score,
        MAX(qa.total_score) AS highest_score,
        MIN(qa.total_score) AS lowest_score,
        COUNT(CASE WHEN qa.status = 'graded' THEN 1 END) AS completed_attempts,
        COUNT(CASE WHEN qa.status = 'in_progress' THEN 1 END) AS in_progress_attempts
    FROM quiz_attempts qa
    WHERE qa.quiz_id = @quiz_id;
END;
GO

PRINT 'Stored procedure sp_GetQuizStatistics created successfully';
GO

PRINT 'All stored procedures created successfully!';
GO
-- =============================================
-- Seed Data: Quiz with Full Essay & File Upload
-- =============================================

USE LMS_QuizModule;
GO

PRINT 'Inserting Full Essay & File Upload Quiz...';
GO

-- Insert Quiz: Project Assessment
IF NOT EXISTS (SELECT * FROM quizzes WHERE title LIKE '%Project Assessment%')
BEGIN
    INSERT INTO quizzes (course_id, title, description, time_limit_minutes, retake_limit, date_start, date_close, passing_grade) VALUES
    (
        3, 
        'Final Project Assessment - Database Systems',
        'Penilaian project akhir dengan essay dan upload file. Semua jawaban memerlukan penilaian manual dari dosen.',
        120,
        1,
        DATEADD(day, -1, GETDATE()),
        DATEADD(day, 21, GETDATE()),
        80.00
    );
    
    DECLARE @quiz_id INT = SCOPE_IDENTITY();
    PRINT 'Quiz created with ID: ' + CAST(@quiz_id AS VARCHAR(10));
    
    -- === ESSAY SECTION (50 points) ===
    
    -- Question 1 - Essay
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'essay', 
     'Explain the concept of database normalization. Describe First Normal Form (1NF), Second Normal Form (2NF), and Third Normal Form (3NF) with examples.', 
     10, NULL, 1);
    
    -- Question 2 - Essay
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'essay', 
     'What is ACID in database transactions? Explain each property (Atomicity, Consistency, Isolation, Durability) and why they are important.', 
     10, NULL, 2);
    
    -- Question 3 - Essay
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'essay', 
     'Compare and contrast SQL and NoSQL databases. When would you choose one over the other? Provide real-world use cases.', 
     10, NULL, 3);
    
    -- Question 4 - Essay
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'essay', 
     'Explain the different types of database indexes (B-Tree, Hash, Bitmap). What are the advantages and disadvantages of each?', 
     10, NULL, 4);
    
    -- Question 5 - Essay
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'essay', 
     'Describe the CAP theorem in distributed databases. Explain the trade-offs between Consistency, Availability, and Partition tolerance.', 
     10, NULL, 5);
    
    -- === FILE UPLOAD SECTION (50 points) ===
    
    -- Question 6 - File Upload (ERD)
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'file_upload', 
     'Design a complete Entity Relationship Diagram (ERD) for an E-Commerce system including: Users, Products, Orders, Payments, and Reviews. Upload your ERD file (PDF, PNG, or draw.io format). Include all entities, attributes, relationships, and cardinalities.', 
     15, NULL, 6);
    
    -- Question 7 - File Upload (SQL Script)
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'file_upload', 
     'Create DDL scripts based on your ERD from Question 6. Upload SQL file (.sql) containing: CREATE TABLE statements, appropriate constraints (PRIMARY KEY, FOREIGN KEY, CHECK, UNIQUE), and CREATE INDEX statements for optimization.', 
     15, NULL, 7);
    
    -- Question 8 - File Upload (Stored Procedure)
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'file_upload', 
     'Write stored procedures for your E-Commerce system: 1) sp_CreateOrder - Create new order with validation, 2) sp_ProcessPayment - Process payment and update order status, 3) sp_GetOrderHistory - Get customer order history. Upload SQL file with all procedures and test cases.', 
     10, NULL, 8);
    
    -- Question 9 - File Upload (Query Optimization)
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'file_upload', 
     'Analyze and optimize a slow query. Given: A query that retrieves all orders with customer details and product information for last 6 months. Write an optimized version with proper indexes, explain your optimization strategy, and compare execution plans. Upload document (PDF/DOCX) with analysis and SQL scripts.', 
     10, NULL, 9);
    
    PRINT 'Full Essay & File Upload Quiz created successfully!';
    PRINT 'Total questions: 9';
    PRINT '  - Essay: 5 questions (50 points)';
    PRINT '  - File Upload: 4 questions (50 points)';
    PRINT '  - Total: 100 points';
    PRINT '';
    PRINT 'NOTE: All questions require manual grading by instructor';
END
ELSE
BEGIN
    PRINT 'Full Essay & File Upload Quiz already exists';
END
GO
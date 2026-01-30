-- =============================================
-- Seed Data: Quiz with Full Multiple Choice Questions
-- =============================================

USE LMS_QuizModule;
GO

PRINT 'Inserting Full Multiple Choice Quiz...';
GO

-- Insert Quiz: Full Multiple Choice
IF NOT EXISTS (SELECT * FROM quizzes WHERE title LIKE '%Full Multiple Choice%')
BEGIN
    INSERT INTO quizzes (course_id, title, description, time_limit_minutes, retake_limit, date_start, date_close, passing_grade) VALUES
    (
        1, 
        'Quiz 2: Full Multiple Choice - Data Structures',
        'Quiz dengan semua soal pilihan ganda tentang struktur data',
        45,
        3,
        DATEADD(day, -5, GETDATE()),
        DATEADD(day, 10, GETDATE()),
        70.00
    );
    
    DECLARE @quiz_id INT = SCOPE_IDENTITY();
    PRINT 'Quiz created with ID: ' + CAST(@quiz_id AS VARCHAR(10));
    
    -- Question 1
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'What is the time complexity of binary search?', 10, 'B', 1);
    
    DECLARE @q1_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q1_id, 'A', 'O(n)'),
    (@q1_id, 'B', 'O(log n)'),
    (@q1_id, 'C', 'O(n^2)'),
    (@q1_id, 'D', 'O(1)'),
    (@q1_id, 'E', 'O(n log n)');
    
    -- Question 2
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'Which data structure uses LIFO principle?', 10, 'C', 2);
    
    DECLARE @q2_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q2_id, 'A', 'Queue'),
    (@q2_id, 'B', 'Array'),
    (@q2_id, 'C', 'Stack'),
    (@q2_id, 'D', 'Linked List'),
    (@q2_id, 'E', 'Tree');
    
    -- Question 3
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'What is the worst-case time complexity of QuickSort?', 10, 'C', 3);
    
    DECLARE @q3_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q3_id, 'A', 'O(n log n)'),
    (@q3_id, 'B', 'O(n)'),
    (@q3_id, 'C', 'O(n^2)'),
    (@q3_id, 'D', 'O(log n)'),
    (@q3_id, 'E', 'O(1)');
    
    -- Question 4
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'Which data structure is best for implementing a priority queue?', 10, 'D', 4);
    
    DECLARE @q4_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q4_id, 'A', 'Array'),
    (@q4_id, 'B', 'Linked List'),
    (@q4_id, 'C', 'Stack'),
    (@q4_id, 'D', 'Heap'),
    (@q4_id, 'E', 'Queue');
    
    -- Question 5
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'What is the space complexity of merge sort?', 10, 'B', 5);
    
    DECLARE @q5_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q5_id, 'A', 'O(1)'),
    (@q5_id, 'B', 'O(n)'),
    (@q5_id, 'C', 'O(log n)'),
    (@q5_id, 'D', 'O(n^2)'),
    (@q5_id, 'E', 'O(n log n)');
    
    -- Question 6
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'Which operation is NOT efficient in a singly linked list?', 10, 'E', 6);
    
    DECLARE @q6_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q6_id, 'A', 'Insertion at beginning'),
    (@q6_id, 'B', 'Deletion at beginning'),
    (@q6_id, 'C', 'Traversal'),
    (@q6_id, 'D', 'Finding length'),
    (@q6_id, 'E', 'Accessing middle element');
    
    -- Question 7
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'What is a circular queue?', 10, 'A', 7);
    
    DECLARE @q7_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q7_id, 'A', 'A queue where rear connects to front'),
    (@q7_id, 'B', 'A queue with no size limit'),
    (@q7_id, 'C', 'A queue with priority'),
    (@q7_id, 'D', 'A queue using linked list'),
    (@q7_id, 'E', 'A double-ended queue');
    
    -- Question 8
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'In a binary search tree, which traversal gives sorted order?', 10, 'B', 8);
    
    DECLARE @q8_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q8_id, 'A', 'Preorder'),
    (@q8_id, 'B', 'Inorder'),
    (@q8_id, 'C', 'Postorder'),
    (@q8_id, 'D', 'Level-order'),
    (@q8_id, 'E', 'Reverse-order');
    
    -- Question 9
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'What is the maximum number of nodes in a binary tree of height h?', 10, 'C', 9);
    
    DECLARE @q9_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q9_id, 'A', '2^h'),
    (@q9_id, 'B', '2^h - 1'),
    (@q9_id, 'C', '2^(h+1) - 1'),
    (@q9_id, 'D', '2^(h-1)'),
    (@q9_id, 'E', 'h^2');
    
    -- Question 10
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'Which collision resolution technique uses linked lists?', 10, 'A', 10);
    
    DECLARE @q10_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q10_id, 'A', 'Chaining'),
    (@q10_id, 'B', 'Linear probing'),
    (@q10_id, 'C', 'Quadratic probing'),
    (@q10_id, 'D', 'Double hashing'),
    (@q10_id, 'E', 'Rehashing');
    
    PRINT 'Full Multiple Choice Quiz created successfully!';
    PRINT 'Total questions: 10 (all multiple choice)';
END
ELSE
BEGIN
    PRINT 'Full Multiple Choice Quiz already exists';
END
GO
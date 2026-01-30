-- =============================================
-- Seed Data: Quiz with Mixed Question Types
-- =============================================

USE LMS_QuizModule;
GO

PRINT 'Inserting Mixed Question Types Quiz...';
GO

-- Insert Quiz: Mixed Questions
IF NOT EXISTS (SELECT * FROM quizzes WHERE title LIKE '%Mixed Question Types%')
BEGIN
    INSERT INTO quizzes (course_id, title, description, time_limit_minutes, retake_limit, date_start, date_close, passing_grade) VALUES
    (
        2, 
        'Midterm: Mixed Question Types - Algorithms',
        'Ujian tengah semester dengan campuran pilihan ganda, essay, dan upload file',
        90,
        2,
        DATEADD(day, -2, GETDATE()),
        DATEADD(day, 14, GETDATE()),
        75.00
    );
    
    DECLARE @quiz_id INT = SCOPE_IDENTITY();
    PRINT 'Quiz created with ID: ' + CAST(@quiz_id AS VARCHAR(10));
    
    -- === MULTIPLE CHOICE SECTION (40 points) ===
    
    -- Question 1 - MC
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'What is the time complexity of bubble sort in worst case?', 5, 'C', 1);
    
    DECLARE @q1_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q1_id, 'A', 'O(n)'),
    (@q1_id, 'B', 'O(n log n)'),
    (@q1_id, 'C', 'O(n^2)'),
    (@q1_id, 'D', 'O(log n)'),
    (@q1_id, 'E', 'O(1)');
    
    -- Question 2 - MC
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'Which algorithm uses divide and conquer strategy?', 5, 'B', 2);
    
    DECLARE @q2_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q2_id, 'A', 'Bubble Sort'),
    (@q2_id, 'B', 'Merge Sort'),
    (@q2_id, 'C', 'Insertion Sort'),
    (@q2_id, 'D', 'Selection Sort'),
    (@q2_id, 'E', 'Linear Search');
    
    -- Question 3 - MC
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'What is a greedy algorithm?', 5, 'D', 3);
    
    DECLARE @q3_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q3_id, 'A', 'Algorithm that uses recursion'),
    (@q3_id, 'B', 'Algorithm that divides problem'),
    (@q3_id, 'C', 'Algorithm that uses dynamic programming'),
    (@q3_id, 'D', 'Algorithm that makes locally optimal choice'),
    (@q3_id, 'E', 'Algorithm that uses brute force');
    
    -- Question 4 - MC
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'Which sorting algorithm is stable?', 5, 'A', 4);
    
    DECLARE @q4_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q4_id, 'A', 'Merge Sort'),
    (@q4_id, 'B', 'Quick Sort'),
    (@q4_id, 'C', 'Heap Sort'),
    (@q4_id, 'D', 'Selection Sort'),
    (@q4_id, 'E', 'Shell Sort');
    
    -- Question 5 - MC
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'What is dynamic programming based on?', 5, 'C', 5);
    
    DECLARE @q5_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q5_id, 'A', 'Greedy choice'),
    (@q5_id, 'B', 'Divide and conquer'),
    (@q5_id, 'C', 'Optimal substructure and overlapping subproblems'),
    (@q5_id, 'D', 'Backtracking'),
    (@q5_id, 'E', 'Branch and bound');
    
    -- Question 6 - MC
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'Which graph traversal uses a queue?', 5, 'B', 6);
    
    DECLARE @q6_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q6_id, 'A', 'DFS'),
    (@q6_id, 'B', 'BFS'),
    (@q6_id, 'C', 'Dijkstra'),
    (@q6_id, 'D', 'Prim'),
    (@q6_id, 'E', 'Kruskal');
    
    -- Question 7 - MC
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'What is the time complexity of Dijkstra algorithm with min-heap?', 5, 'D', 7);
    
    DECLARE @q7_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q7_id, 'A', 'O(n)'),
    (@q7_id, 'B', 'O(n log n)'),
    (@q7_id, 'C', 'O(n^2)'),
    (@q7_id, 'D', 'O((V+E) log V)'),
    (@q7_id, 'E', 'O(V^2)');
    
    -- Question 8 - MC
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'multiple_choice', 'Which problem is NP-complete?', 5, 'C', 8);
    
    DECLARE @q8_id INT = SCOPE_IDENTITY();
    INSERT INTO question_options (question_id, option_key, option_text) VALUES
    (@q8_id, 'A', 'Sorting'),
    (@q8_id, 'B', 'Binary search'),
    (@q8_id, 'C', 'Traveling Salesman Problem'),
    (@q8_id, 'D', 'Merge sort'),
    (@q8_id, 'E', 'Finding minimum');
    
    -- === ESSAY SECTION (30 points) ===
    
    -- Question 9 - Essay
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'essay', 'Explain the difference between Divide and Conquer and Dynamic Programming. Provide at least one example for each approach.', 10, NULL, 9);
    
    -- Question 10 - Essay
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'essay', 'Describe how Dijkstra''s algorithm works. What are its limitations? When would you use Bellman-Ford instead?', 10, NULL, 10);
    
    -- Question 11 - Essay
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'essay', 'Compare and contrast BFS and DFS graph traversal algorithms. What are the use cases for each?', 10, NULL, 11);
    
    -- === FILE UPLOAD SECTION (30 points) ===
    
    -- Question 12 - File Upload
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'file_upload', 'Implement Merge Sort algorithm in your preferred programming language. Upload your code file (.java, .py, .cpp, etc.). Include comments explaining each step.', 15, NULL, 12);
    
    -- Question 13 - File Upload
    INSERT INTO questions (quiz_id, question_type, question_text, points, correct_answer, order_number) VALUES
    (@quiz_id, 'file_upload', 'Implement a solution for the Knapsack problem using Dynamic Programming. Upload your complete code with test cases.', 15, NULL, 13);
    
    PRINT 'Mixed Question Types Quiz created successfully!';
    PRINT 'Total questions: 13';
    PRINT '  - Multiple Choice: 8 questions (40 points)';
    PRINT '  - Essay: 3 questions (30 points)';
    PRINT '  - File Upload: 2 questions (30 points)';
    PRINT '  - Total: 100 points';
END
ELSE
BEGIN
    PRINT 'Mixed Question Types Quiz already exists';
END
GO
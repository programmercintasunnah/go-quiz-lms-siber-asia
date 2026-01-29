# Hybrid Grading Logic - LMS Quiz Module

## Overview

Sistem ini menggunakan **Hybrid Grading System** yang menggabungkan penilaian otomatis (auto-grading) dan penilaian manual. Pendekatan ini diperlukan karena ada 3 tipe soal dengan karakteristik berbeda:

1. **Multiple Choice** → Auto-graded ✅
2. **Essay** → Manual-graded ✍️
3. **File Upload** → Manual-graded 📤

---

## Grading Flow

### 1. Student Submits Answer

```
┌─────────────────────────────────────────┐
│ Student submits answer                  │
│ (POST /quiz/attempt/:id/answer)         │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│ System identifies question type         │
└─────────────┬───────────────────────────┘
              │
        ┌─────┴──────┐
        │            │
        ▼            ▼
   Multiple      Essay / File
   Choice          Upload
        │            │
        ▼            ▼
  Auto-Grade    Set status:
  immediately   "waiting_assessment"
```

---

## Detailed Logic

### A. Multiple Choice (Auto-Grading)

#### Step 1: Student submits answer
```json
{
  "question_id": 1,
  "answer_type": "multiple_choice",
  "selected_option": "A"
}
```

#### Step 2: System auto-grades

```go
func AutoGrade(answer *StudentAnswer, questionType string, correctAnswer string) {
    if questionType == "multiple_choice" {
        if answer.SelectedOption == correctAnswer {
            answer.IsCorrect = true
            answer.GradingStatus = "auto_graded"
        } else {
            answer.IsCorrect = false
            answer.GradingStatus = "auto_graded"
        }
    }
}
```

#### Step 3: Score calculated immediately
- If correct: `score = question.Points`
- If wrong: `score = 0`

**Database State:**
```sql
INSERT INTO student_answers (
    attempt_id, question_id, selected_option, 
    is_correct, grading_status
) VALUES (
    123, 1, 'A', 
    1, 'auto_graded'
);
```

---

### B. Essay (Manual Grading)

#### Step 1: Student submits answer
```json
{
  "question_id": 2,
  "answer_type": "essay",
  "answer_text": "Polymorphism is the ability..."
}
```

#### Step 2: System sets status
```go
func AutoGrade(answer *StudentAnswer, questionType string, correctAnswer string) {
    if questionType == "essay" {
        answer.GradingStatus = "waiting_assessment"
        answer.IsCorrect = nil
        answer.ManualScore = nil
    }
}
```

**Database State:**
```sql
INSERT INTO student_answers (
    attempt_id, question_id, answer_text, 
    grading_status
) VALUES (
    123, 2, 'Polymorphism is the ability...', 
    'waiting_assessment'
);
```

#### Step 3: Instructor grades manually (separate flow)
```sql
UPDATE student_answers
SET manual_score = 18,
    grading_status = 'manually_graded'
WHERE answer_id = 456;
```

---

### C. File Upload (Manual Grading)

#### Step 1: Student uploads file
```json
{
  "question_id": 3,
  "answer_type": "file_upload",
  "answer_file_path": "/uploads/student_1_assignment.pdf"
}
```

#### Step 2: System sets status
```go
func AutoGrade(answer *StudentAnswer, questionType string, correctAnswer string) {
    if questionType == "file_upload" {
        answer.GradingStatus = "waiting_assessment"
        answer.IsCorrect = nil
        answer.ManualScore = nil
    }
}
```

**Database State:**
```sql
INSERT INTO student_answers (
    attempt_id, question_id, answer_file_path, 
    grading_status
) VALUES (
    123, 3, '/uploads/student_1_assignment.pdf', 
    'waiting_assessment'
);
```

---

## Submit Quiz Flow

### When student clicks "Submit Quiz"

```
┌──────────────────────────────────────────┐
│ POST /quiz/attempt/:id/submit            │
└────────────────┬─────────────────────────┘
                 │
                 ▼
┌──────────────────────────────────────────┐
│ Calculate total score                    │
│ - Count auto-graded answers              │
│ - Skip waiting_assessment answers        │
└────────────────┬─────────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
  All graded       Has waiting
  (status: graded) (status: submitted)
        │                 │
        ▼                 ▼
  Show final      Wait for instructor
     score           to grade
```

### Code Implementation

```go
func SubmitQuiz(attemptID int) (*SubmitQuizResponse, error) {
    // 1. Calculate score
    totalScore, hasWaiting, err := CalculateTotalScore(attemptID)
    
    // 2. Determine status
    status := "graded"
    if hasWaiting {
        status = "submitted" // Still waiting for manual grading
    }
    
    // 3. Update attempt
    var scorePtr *float64
    if !hasWaiting {
        scorePtr = &totalScore  // Set final score
    } else {
        scorePtr = nil  // Score still pending
    }
    
    UpdateAttemptStatus(attemptID, status, scorePtr)
    
    return &SubmitQuizResponse{
        AttemptID:           attemptID,
        Status:              status,
        AutoGradedScore:     totalScore,
        PendingManualGrading: hasWaiting,
        TotalQuestions:      totalQuestions,
        AutoGradedQuestions: autoGradedCount,
        WaitingAssessment:   waitingCount,
    }
}
```

---

## Calculate Total Score Logic

```go
func CalculateTotalScore(attemptID int) (float64, bool, error) {
    answers := GetAnswersByAttemptID(attemptID)
    
    var totalScore float64 = 0
    hasWaitingAssessment := false
    
    for _, answer := range answers {
        if answer.GradingStatus == "waiting_assessment" {
            hasWaitingAssessment = true
            continue  // Skip this answer
        }
        
        question := GetQuestionByID(answer.QuestionID)
        
        // Auto-graded (multiple choice)
        if answer.GradingStatus == "auto_graded" {
            if answer.IsCorrect {
                totalScore += question.Points
            }
        }
        
        // Manual-graded (essay/file upload)
        if answer.GradingStatus == "manually_graded" {
            totalScore += answer.ManualScore
        }
    }
    
    return totalScore, hasWaitingAssessment, nil
}
```

---

## Status Flow Diagram

### Quiz Attempt Status

```
┌─────────────┐
│ in_progress │ ◄─── Student starts quiz
└──────┬──────┘
       │ Student clicks "Submit"
       ▼
┌─────────────┐
│  submitted  │ ◄─── Has waiting_assessment answers
└──────┬──────┘
       │ Instructor grades all answers
       ▼
┌─────────────┐
│   graded    │ ◄─── All answers graded, final score available
└─────────────┘
```

### Answer Grading Status

```
Multiple Choice:
┌─────────────┐
│ auto_graded │ (Immediately after submit)
└─────────────┘

Essay / File Upload:
┌───────────────────────┐
│ waiting_assessment    │ (After submit)
└──────────┬────────────┘
           │ Instructor grades
           ▼
┌───────────────────────┐
│ manually_graded       │ (After instructor grades)
└───────────────────────┘
```

---

## Example Scenarios

### Scenario 1: Quiz with only Multiple Choice

**Questions:**
1. Question 1 (Multiple Choice) - 10 points
2. Question 2 (Multiple Choice) - 10 points
3. Question 3 (Multiple Choice) - 10 points

**Student submits answers:**
- Q1: A (Correct)
- Q2: B (Wrong)
- Q3: C (Correct)

**When student clicks "Submit Quiz":**
- All answers auto-graded immediately
- Total score: 20 points
- Status: `graded`
- Student sees final score immediately

---

### Scenario 2: Quiz with Mixed Questions

**Questions:**
1. Question 1 (Multiple Choice) - 10 points
2. Question 2 (Multiple Choice) - 10 points
3. Question 3 (Essay) - 20 points
4. Question 4 (File Upload) - 60 points

**Student submits answers:**
- Q1: A (Correct) → **auto_graded**
- Q2: B (Correct) → **auto_graded**
- Q3: Essay text → **waiting_assessment**
- Q4: PDF file → **waiting_assessment**

**When student clicks "Submit Quiz":**
- Partial score: 20 points (from multiple choice)
- Status: `submitted`
- Response:
```json
{
  "status": "submitted",
  "auto_graded_score": 20,
  "pending_manual_grading": true,
  "total_questions": 4,
  "auto_graded_questions": 2,
  "waiting_assessment": 2
}
```

**After instructor grades:**
- Q3 Essay: 15/20 points
- Q4 File: 50/60 points
- Total score: 85 points
- Status updated to: `graded`

---

### Scenario 3: Student Views Result Before Complete Grading

**Request:** `GET /quiz/attempt/123/result`

**Response:**
```json
{
  "attempt_id": 123,
  "quiz_title": "Midterm Exam",
  "total_score": null,  // Still null because not all graded
  "status": "submitted",
  "answers": [
    {
      "question_id": 1,
      "question_type": "multiple_choice",
      "points": 10,
      "score": 10,
      "grading_status": "auto_graded"
    },
    {
      "question_id": 2,
      "question_type": "essay",
      "points": 20,
      "score": null,  // Not graded yet
      "grading_status": "waiting_assessment"
    }
  ]
}
```

---

## Instructor Manual Grading (Future Feature)

### API Endpoint (to be implemented)
```
POST /api/v1/instructor/grade/:answer_id
```

**Request Body:**
```json
{
  "score": 18,
  "feedback": "Good explanation, but missing some details"
}
```

**Process:**
1. Update `student_answers` table:
   - Set `manual_score = 18`
   - Set `grading_status = 'manually_graded'`

2. Check if all answers for attempt are graded

3. If all graded:
   - Recalculate total score
   - Update `quiz_attempts.status = 'graded'`
   - Update `quiz_attempts.total_score`

---

## Database Queries

### Check if attempt is fully graded
```sql
SELECT COUNT(*) as waiting_count
FROM student_answers
WHERE attempt_id = @attempt_id
  AND grading_status = 'waiting_assessment';
  
-- If waiting_count = 0, then fully graded
```

### Get grading progress
```sql
SELECT 
    COUNT(*) as total_answers,
    SUM(CASE WHEN grading_status = 'auto_graded' THEN 1 ELSE 0 END) as auto_graded,
    SUM(CASE WHEN grading_status = 'manually_graded' THEN 1 ELSE 0 END) as manually_graded,
    SUM(CASE WHEN grading_status = 'waiting_assessment' THEN 1 ELSE 0 END) as waiting
FROM student_answers
WHERE attempt_id = @attempt_id;
```

---

## Benefits of Hybrid Grading

### ✅ Advantages

1. **Immediate Feedback**: Multiple choice questions graded instantly
2. **Flexibility**: Supports subjective questions (essay, coding assignments)
3. **Fair Assessment**: Human judgment for complex answers
4. **Scalability**: Auto-grading reduces instructor workload for objective questions
5. **Transparency**: Students know which answers are waiting for grading

### ⚠️ Considerations

1. **Delayed Final Score**: Students must wait for manual grading
2. **Instructor Workload**: Manual grading takes time
3. **Status Tracking**: Clear communication needed about "submitted" vs "graded"

---

## Best Practices

### For Students:
- Check grading status after submission
- Wait for all questions to be graded before interpreting final score
- Return later to see complete results

### For Instructors:
- Grade manually-assessed questions as soon as possible
- Provide feedback along with scores
- Use rubrics for consistent grading

### For System:
- Clear UI indicators for grading status
- Email notifications when manual grading is complete
- Show partial scores transparently

---

## Summary

The Hybrid Grading System provides:
- **Automatic** grading for objective questions (multiple choice)
- **Manual** grading for subjective questions (essay, file upload)
- **Transparent** status tracking throughout the process
- **Flexible** final score calculation based on question types

This approach balances efficiency with fairness, ensuring accurate assessment across different question types.
# API Documentation - LMS Quiz Module

## Base URL

```
http://localhost:8081/api/v1
```

---

## Authentication

> **Note:** Authentication belum diimplementasikan dalam versi ini. Untuk production, tambahkan JWT/OAuth authentication.

---

## Standard Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "error": "Detailed error information"
}
```

---

## Endpoints

### 1. Health Check

**Endpoint:** `GET /health`

**Description:** Check if API is running

**Response:**
```json
{
  "status": "ok",
  "message": "LMS Quiz Module API is running"
}
```

---

### 2. Start Quiz

**Endpoint:** `POST /api/v1/quiz/:quiz_id/start`

**Description:** Memulai quiz attempt baru dengan validasi retake limit dan date range

**URL Parameters:**
- `quiz_id` (integer, required) - ID of the quiz

**Request Body:**
```json
{
  "user_id": 1
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Quiz started successfully",
  "data": {
    "attempt_id": 123,
    "quiz_id": 5,
    "start_time": "2024-01-08T10:00:00Z",
    "time_limit_minutes": 60,
    "questions": [
      {
        "question_id": 1,
        "quiz_id": 5,
        "question_type": "multiple_choice",
        "question_text": "What is the output of the following code?",
        "points": 10,
        "order_number": 1,
        "options": [
          {
            "option_id": 1,
            "question_id": 1,
            "option_key": "A",
            "option_text": "Introduction"
          },
          {
            "option_id": 2,
            "question_id": 1,
            "option_key": "B",
            "option_text": "Objectives"
          }
        ]
      },
      {
        "question_id": 2,
        "quiz_id": 5,
        "question_type": "essay",
        "question_text": "Explain the concept of polymorphism.",
        "points": 20,
        "order_number": 2
      },
      {
        "question_id": 3,
        "quiz_id": 5,
        "question_type": "file_upload",
        "question_text": "Upload your programming assignment.",
        "points": 50,
        "order_number": 3
      }
    ]
  }
}
```

**Error Responses:**

**400 Bad Request** - Quiz not found
```json
{
  "success": false,
  "message": "quiz not found"
}
```

**400 Bad Request** - Quiz has not started
```json
{
  "success": false,
  "message": "quiz has not started yet"
}
```

**400 Bad Request** - Quiz has closed
```json
{
  "success": false,
  "message": "quiz has closed"
}
```

**400 Bad Request** - Retake limit exceeded
```json
{
  "success": false,
  "message": "retake limit exceeded"
}
```

**400 Bad Request** - In-progress attempt exists
```json
{
  "success": false,
  "message": "you have an in-progress attempt"
}
```

---

### 3. Submit Answer

**Endpoint:** `POST /api/v1/quiz/attempt/:attempt_id/answer`

**Description:** Submit jawaban untuk satu soal (autosave pattern - bisa dipanggil berkali-kali)

**URL Parameters:**
- `attempt_id` (integer, required) - ID of the quiz attempt

**Request Body Examples:**

**Multiple Choice:**
```json
{
  "question_id": 1,
  "answer_type": "multiple_choice",
  "selected_option": "A"
}
```

**Essay:**
```json
{
  "question_id": 2,
  "answer_type": "essay",
  "answer_text": "Polymorphism is the ability of an object to take many forms..."
}
```

**File Upload:**
```json
{
  "question_id": 3,
  "answer_type": "file_upload",
  "answer_file_path": "/uploads/answers/student_1_assignment.pdf"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Answer submitted successfully",
  "data": null
}
```

**Error Responses:**

**400 Bad Request** - Attempt not found
```json
{
  "success": false,
  "message": "attempt not found"
}
```

**400 Bad Request** - Attempt not in progress
```json
{
  "success": false,
  "message": "attempt is not in progress"
}
```

**400 Bad Request** - Question not found
```json
{
  "success": false,
  "message": "question not found"
}
```

**400 Bad Request** - Answer type mismatch
```json
{
  "success": false,
  "message": "answer type mismatch"
}
```

---

### 4. Submit Quiz (Finalize)

**Endpoint:** `POST /api/v1/quiz/attempt/:attempt_id/submit`

**Description:** Finalisasi quiz attempt dan trigger auto-grading

**URL Parameters:**
- `attempt_id` (integer, required) - ID of the quiz attempt

**Request Body:** None (empty body)

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Quiz submitted successfully",
  "data": {
    "attempt_id": 123,
    "status": "submitted",
    "auto_graded_score": 70,
    "pending_manual_grading": true,
    "total_questions": 10,
    "auto_graded_questions": 7,
    "waiting_assessment": 3
  }
}
```

**Response when all questions are auto-graded:**
```json
{
  "success": true,
  "message": "Quiz submitted successfully",
  "data": {
    "attempt_id": 123,
    "status": "graded",
    "auto_graded_score": 85,
    "pending_manual_grading": false,
    "total_questions": 10,
    "auto_graded_questions": 10,
    "waiting_assessment": 0
  }
}
```

**Error Responses:**

**400 Bad Request** - Attempt not found
```json
{
  "success": false,
  "message": "attempt not found"
}
```

**400 Bad Request** - Attempt not in progress
```json
{
  "success": false,
  "message": "attempt is not in progress"
}
```

---

### 5. Get Result

**Endpoint:** `GET /api/v1/quiz/attempt/:attempt_id/result`

**Description:** Mendapatkan hasil quiz attempt

**URL Parameters:**
- `attempt_id` (integer, required) - ID of the quiz attempt

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Result retrieved successfully",
  "data": {
    "attempt_id": 123,
    "quiz_title": "Quiz 1: Programming Basics",
    "total_score": 85,
    "status": "graded",
    "start_time": "2024-01-08T10:00:00Z",
    "end_time": "2024-01-08T11:00:00Z",
    "answers": [
      {
        "question_id": 1,
        "question_text": "What is the output?",
        "question_type": "multiple_choice",
        "points": 10,
        "student_answer": "A",
        "correct_answer": "A",
        "is_correct": true,
        "score": 10,
        "grading_status": "auto_graded"
      },
      {
        "question_id": 2,
        "question_text": "What is polymorphism?",
        "question_type": "multiple_choice",
        "points": 10,
        "student_answer": "B",
        "correct_answer": "C",
        "is_correct": false,
        "score": 0,
        "grading_status": "auto_graded"
      },
      {
        "question_id": 3,
        "question_text": "Explain inheritance...",
        "question_type": "essay",
        "points": 15,
        "student_answer": "Inheritance is...",
        "score": 12,
        "grading_status": "manually_graded"
      },
      {
        "question_id": 4,
        "question_text": "Upload your code...",
        "question_type": "file_upload",
        "points": 50,
        "student_answer": "/uploads/student_1_code.java",
        "score": null,
        "grading_status": "waiting_assessment"
      }
    ]
  }
}
```

**Error Responses:**

**404 Not Found** - Attempt not found
```json
{
  "success": false,
  "message": "attempt not found"
}
```

---

### 6. Get Student Quiz History

**Endpoint:** `GET /api/v1/student/:user_id/quiz-history`

**Description:** Mendapatkan riwayat semua quiz attempts dari seorang mahasiswa

**URL Parameters:**
- `user_id` (integer, required) - ID of the student

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Quiz history retrieved successfully",
  "data": [
    {
      "attempt_id": 123,
      "quiz_id": 5,
      "quiz_title": "Quiz 1: Programming Basics",
      "course_name": "Introduction to Programming",
      "attempt_number": 1,
      "start_time": "2024-01-08T10:00:00Z",
      "end_time": "2024-01-08T11:00:00Z",
      "status": "graded",
      "total_score": 85,
      "total_questions": 10
    },
    {
      "attempt_id": 124,
      "quiz_id": 5,
      "quiz_title": "Quiz 1: Programming Basics",
      "course_name": "Introduction to Programming",
      "attempt_number": 2,
      "start_time": "2024-01-09T14:00:00Z",
      "end_time": "2024-01-09T15:00:00Z",
      "status": "graded",
      "total_score": 90,
      "total_questions": 10
    },
    {
      "attempt_id": 125,
      "quiz_id": 6,
      "quiz_title": "Midterm Exam",
      "course_name": "Data Structures",
      "attempt_number": 1,
      "start_time": "2024-01-10T09:00:00Z",
      "end_time": null,
      "status": "in_progress",
      "total_score": null,
      "total_questions": 20
    }
  ]
}
```

**Error Responses:**

**500 Internal Server Error**
```json
{
  "success": false,
  "message": "Failed to get quiz history",
  "error": "Database error details"
}
```

---

## Error Codes

| HTTP Status | Description |
|-------------|-------------|
| 200 | OK - Request successful |
| 400 | Bad Request - Invalid input or business logic error |
| 404 | Not Found - Resource not found |
| 500 | Internal Server Error - Server error |

---

## Rate Limiting

> **Note:** Rate limiting belum diimplementasikan. Untuk production, implementasikan rate limiting untuk mencegah abuse.

Rekomendasi:
- 100 requests per minute per IP
- 1000 requests per hour per user

---

## CORS

API mendukung CORS untuk semua origin (`*`). Untuk production, batasi origin yang diperbolehkan.

---

## Testing with cURL

### Start Quiz
```bash
curl -X POST http://localhost:8081/api/v1/quiz/1/start \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1}'
```

### Submit Answer
```bash
curl -X POST http://localhost:8081/api/v1/quiz/attempt/1/answer \
  -H "Content-Type: application/json" \
  -d '{
    "question_id": 1,
    "answer_type": "multiple_choice",
    "selected_option": "A"
  }'
```

### Submit Quiz
```bash
curl -X POST http://localhost:8081/api/v1/quiz/attempt/1/submit \
  -H "Content-Type: application/json"
```

### Get Result
```bash
curl http://localhost:8081/api/v1/quiz/attempt/1/result
```

### Get Student History
```bash
curl http://localhost:8081/api/v1/student/1/quiz-history
```

---

## Postman Collection

Import Postman collection untuk testing: (create and save this file separately)

```json
{
  "info": {
    "name": "LMS Quiz Module API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Start Quiz",
      "request": {
        "method": "POST",
        "url": "{{base_url}}/quiz/1/start",
        "body": {
          "mode": "raw",
          "raw": "{\"user_id\": 1}"
        }
      }
    }
  ],
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:8081/api/v1"
    }
  ]
}
```

---

## Changelog

### v1.0.0 (2025-01-29)
- Initial release
- Basic quiz CRUD operations
- Auto-grading for multiple choice
- Manual grading support for essay and file upload
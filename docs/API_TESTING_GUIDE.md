# API Testing Guide - cURL Commands

> Panduan lengkap untuk testing semua endpoint API menggunakan cURL

---

## 📋 Prerequisites

- Server running di `http://localhost:8081`
- Database sudah di-setup dengan seed data
- Terminal/Command Prompt

---

## 🚀 Quick Start

```bash
# 1. Jalankan server (di terminal pertama)
cd ~/Project/Me/go-quiz-lms-siber-asia
go run cmd/api/main.go

# 2. Test API (di terminal kedua)
# Copy paste command di bawah
```

---

## 📡 Available Endpoints

| No | Method | Endpoint | Description |
|----|--------|----------|-------------|
| 1 | GET | `/health` | Health check |
| 2 | POST | `/api/v1/quiz/:quiz_id/start` | Start quiz |
| 3 | POST | `/api/v1/quiz/attempt/:attempt_id/answer` | Submit answer |
| 4 | POST | `/api/v1/quiz/attempt/:attempt_id/submit` | Submit quiz |
| 5 | GET | `/api/v1/quiz/attempt/:attempt_id/result` | Get result |
| 6 | GET | `/api/v1/student/:user_id/quiz-history` | Get history |

---

## 🧪 Test Scenarios

### Scenario 1: Complete Quiz Flow (Success)

#### Step 1: Health Check

```bash
curl -X GET http://localhost:8081/health
```

**Expected Response:**
```json
{
  "status": "ok",
  "message": "LMS Quiz Module API is running"
}
```

---

#### Step 2: Start Quiz

```bash
curl -X POST http://localhost:8081/api/v1/quiz/1/start \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Quiz started successfully",
  "data": {
    "attempt_id": 1,
    "quiz_id": 1,
    "start_time": "2025-01-29T10:00:00Z",
    "time_limit_minutes": 60,
    "questions": [
      {
        "question_id": 1,
        "quiz_id": 1,
        "question_type": "multiple_choice",
        "question_text": "What is the correct syntax...",
        "points": 10,
        "order_number": 1,
        "options": [...]
      }
    ]
  }
}
```

**📝 Note:** Simpan `attempt_id` untuk step selanjutnya!

---

#### Step 3a: Submit Answer - Multiple Choice (Question 1)

```bash
curl -X POST http://localhost:8081/api/v1/quiz/attempt/1/answer \
  -H "Content-Type: application/json" \
  -d '{
    "question_id": 1,
    "answer_type": "multiple_choice",
    "selected_option": "B"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Answer submitted successfully",
  "data": null
}
```

---

#### Step 3b: Submit Answer - Multiple Choice (Question 2)

```bash
curl -X POST http://localhost:8081/api/v1/quiz/attempt/1/answer \
  -H "Content-Type: application/json" \
  -d '{
    "question_id": 2,
    "answer_type": "multiple_choice",
    "selected_option": "A"
  }'
```

---

#### Step 3c: Submit Answer - Multiple Choice (Question 3)

```bash
curl -X POST http://localhost:8081/api/v1/quiz/attempt/1/answer \
  -H "Content-Type: application/json" \
  -d '{
    "question_id": 3,
    "answer_type": "multiple_choice",
    "selected_option": "C"
  }'
```

---

#### Step 3d: Submit Answer - Essay (Question 4)

```bash
curl -X POST http://localhost:8081/api/v1/quiz/attempt/1/answer \
  -H "Content-Type: application/json" \
  -d '{
    "question_id": 4,
    "answer_type": "essay",
    "answer_text": "Primitive types are basic data types provided by Java such as int, char, boolean, and float. They store simple values directly in memory. Reference types, on the other hand, are objects and arrays that store references to memory locations. For example, int is primitive while String is a reference type."
  }'
```

---

#### Step 3e: Submit Answer - File Upload (Question 5)

```bash
curl -X POST http://localhost:8081/api/v1/quiz/attempt/1/answer \
  -H "Content-Type: application/json" \
  -d '{
    "question_id": 5,
    "answer_type": "file_upload",
    "answer_file_path": "/uploads/student_1_calculator.java"
  }'
```

---

#### Step 4: Submit Quiz (Finalize)

```bash
curl -X POST http://localhost:8081/api/v1/quiz/attempt/1/submit \
  -H "Content-Type: application/json"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Quiz submitted successfully",
  "data": {
    "attempt_id": 1,
    "status": "submitted",
    "auto_graded_score": 20,
    "pending_manual_grading": true,
    "total_questions": 5,
    "auto_graded_questions": 3,
    "waiting_assessment": 2
  }
}
```

**📝 Note:** 
- `status: "submitted"` karena ada essay & file upload
- `auto_graded_score: 20` dari 3 pilihan ganda (10+10+0)
- Essay & file upload masih `waiting_assessment`

---

#### Step 5: Get Result

```bash
curl -X GET http://localhost:8081/api/v1/quiz/attempt/1/result
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Result retrieved successfully",
  "data": {
    "attempt_id": 1,
    "quiz_title": "Quiz 1: Programming Basics",
    "total_score": null,
    "status": "submitted",
    "start_time": "2025-01-29T10:00:00Z",
    "end_time": "2025-01-29T10:30:00Z",
    "answers": [
      {
        "question_id": 1,
        "question_text": "What is the correct syntax...",
        "question_type": "multiple_choice",
        "points": 10,
        "student_answer": "B",
        "correct_answer": "B",
        "is_correct": true,
        "score": 10,
        "grading_status": "auto_graded"
      },
      {
        "question_id": 2,
        "question_text": "Which data type...",
        "question_type": "multiple_choice",
        "points": 10,
        "student_answer": "A",
        "correct_answer": "A",
        "is_correct": true,
        "score": 10,
        "grading_status": "auto_graded"
      },
      {
        "question_id": 3,
        "question_text": "What is the size of int...",
        "question_type": "multiple_choice",
        "points": 10,
        "student_answer": "C",
        "correct_answer": "C",
        "is_correct": true,
        "score": 10,
        "grading_status": "auto_graded"
      },
      {
        "question_id": 4,
        "question_text": "Explain the difference...",
        "question_type": "essay",
        "points": 20,
        "student_answer": "Primitive types are...",
        "score": null,
        "grading_status": "waiting_assessment"
      },
      {
        "question_id": 5,
        "question_text": "Upload your solution...",
        "question_type": "file_upload",
        "points": 50,
        "student_answer": "/uploads/student_1_calculator.java",
        "score": null,
        "grading_status": "waiting_assessment"
      }
    ]
  }
}
```

---

#### Step 6: Get Student History

```bash
curl -X GET http://localhost:8081/api/v1/student/1/quiz-history
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Quiz history retrieved successfully",
  "data": [
    {
      "attempt_id": 1,
      "quiz_id": 1,
      "quiz_title": "Quiz 1: Programming Basics",
      "course_name": "Introduction to Programming",
      "attempt_number": 1,
      "start_time": "2025-01-29T10:00:00Z",
      "end_time": "2025-01-29T10:30:00Z",
      "status": "submitted",
      "total_score": null,
      "total_questions": 5
    }
  ]
}
```

---

## 🔴 Error Scenarios

### Test 1: Start Quiz - Quiz Not Found

```bash
curl -X POST http://localhost:8081/api/v1/quiz/999/start \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1
  }'
```

**Expected Response:**
```json
{
  "success": false,
  "message": "quiz not found",
  "error": null
}
```

---

### Test 2: Start Quiz - Invalid User ID

```bash
curl -X POST http://localhost:8081/api/v1/quiz/1/start \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 0
  }'
```

**Expected Response:**
```json
{
  "success": false,
  "message": "Invalid request body",
  "error": "..."
}
```

---

### Test 3: Start Quiz - Retake Limit Exceeded

```bash
# Jalankan 3 kali (jika retake_limit = 2)
curl -X POST http://localhost:8081/api/v1/quiz/1/start \
  -H "Content-Type: application/json" \
  -d '{"user_id": 2}'

curl -X POST http://localhost:8081/api/v1/quiz/1/start \
  -H "Content-Type: application/json" \
  -d '{"user_id": 2}'

# Yang ketiga akan error
curl -X POST http://localhost:8081/api/v1/quiz/1/start \
  -H "Content-Type: application/json" \
  -d '{"user_id": 2}'
```

**Expected Response (3rd attempt):**
```json
{
  "success": false,
  "message": "retake limit exceeded",
  "error": null
}
```

---

### Test 4: Submit Answer - Invalid Answer Type

```bash
curl -X POST http://localhost:8081/api/v1/quiz/attempt/1/answer \
  -H "Content-Type: application/json" \
  -d '{
    "question_id": 1,
    "answer_type": "essay",
    "answer_text": "This should be multiple choice"
  }'
```

**Expected Response:**
```json
{
  "success": false,
  "message": "answer type mismatch",
  "error": null
}
```

---

### Test 5: Submit Answer - Attempt Not Found

```bash
curl -X POST http://localhost:8081/api/v1/quiz/attempt/999/answer \
  -H "Content-Type: application/json" \
  -d '{
    "question_id": 1,
    "answer_type": "multiple_choice",
    "selected_option": "A"
  }'
```

**Expected Response:**
```json
{
  "success": false,
  "message": "attempt not found",
  "error": null
}
```

---

### Test 6: Submit Answer - Attempt Not In Progress

```bash
# Setelah quiz sudah di-submit
curl -X POST http://localhost:8081/api/v1/quiz/attempt/1/answer \
  -H "Content-Type: application/json" \
  -d '{
    "question_id": 1,
    "answer_type": "multiple_choice",
    "selected_option": "A"
  }'
```

**Expected Response:**
```json
{
  "success": false,
  "message": "attempt is not in progress",
  "error": null
}
```

---

## 📊 Test with Different Question Types

### Multiple Choice Answer

```bash
curl -X POST http://localhost:8081/api/v1/quiz/attempt/1/answer \
  -H "Content-Type: application/json" \
  -d '{
    "question_id": 1,
    "answer_type": "multiple_choice",
    "selected_option": "B"
  }'
```

---

### Essay Answer

```bash
curl -X POST http://localhost:8081/api/v1/quiz/attempt/1/answer \
  -H "Content-Type: application/json" \
  -d '{
    "question_id": 4,
    "answer_type": "essay",
    "answer_text": "Polymorphism is the ability of an object to take on many forms. The most common use of polymorphism in OOP occurs when a parent class reference is used to refer to a child class object. In Java, we can achieve polymorphism through method overriding and method overloading."
  }'
```

---

### File Upload Answer

```bash
curl -X POST http://localhost:8081/api/v1/quiz/attempt/1/answer \
  -H "Content-Type: application/json" \
  -d '{
    "question_id": 5,
    "answer_type": "file_upload",
    "answer_file_path": "/uploads/student_1_assignment.pdf"
  }'
```

---

## 🔄 Update/Re-submit Answer

Kamu bisa submit jawaban lagi untuk soal yang sama (akan di-update):

```bash
# Submit pertama
curl -X POST http://localhost:8081/api/v1/quiz/attempt/1/answer \
  -H "Content-Type: application/json" \
  -d '{
    "question_id": 1,
    "answer_type": "multiple_choice",
    "selected_option": "A"
  }'

# Submit kedua (update jawaban)
curl -X POST http://localhost:8081/api/v1/quiz/attempt/1/answer \
  -H "Content-Type: application/json" \
  -d '{
    "question_id": 1,
    "answer_type": "multiple_choice",
    "selected_option": "B"
  }'
```

Jawaban akan di-update dari "A" ke "B".

---

# Start quiz
```bash
curl -X POST http://localhost:8081/api/v1/quiz/4/start \
  -H "Content-Type: application/json" \
  -d '{"user_id": 2}' | jq
```

# Bulk submit (assume attempt_id = 2)
```bash
curl -X POST http://localhost:8081/api/v1/quiz/attempt/2/answers/bulk \
  -H "Content-Type: application/json" \
  -d '{
    "answers": [
      {"question_id": 11, "answer_type": "multiple_choice", "selected_option": "B"},
      {"question_id": 12, "answer_type": "multiple_choice", "selected_option": "C"},
      {"question_id": 13, "answer_type": "multiple_choice", "selected_option": "C"},
      {"question_id": 14, "answer_type": "multiple_choice", "selected_option": "D"},
      {"question_id": 15, "answer_type": "multiple_choice", "selected_option": "B"}
    ]
  }' | jq
```
---

## 🎯 Complete Test Script (Bash)

Simpan sebagai `test_api.sh`:

```bash
#!/bin/bash

BASE_URL="http://localhost:8081"

echo "==================================="
echo "LMS Quiz Module - API Testing"
echo "==================================="
echo ""

# 1. Health Check
echo "[1/6] Testing Health Check..."
curl -s -X GET $BASE_URL/health | jq
echo ""

# 2. Start Quiz
echo "[2/6] Testing Start Quiz..."
RESPONSE=$(curl -s -X POST $BASE_URL/api/v1/quiz/1/start \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1}')
echo $RESPONSE | jq

# Extract attempt_id
ATTEMPT_ID=$(echo $RESPONSE | jq -r '.data.attempt_id')
echo "Attempt ID: $ATTEMPT_ID"
echo ""

# 3. Submit Answers
echo "[3/6] Testing Submit Answers..."

# Answer 1 - Multiple Choice
curl -s -X POST $BASE_URL/api/v1/quiz/attempt/$ATTEMPT_ID/answer \
  -H "Content-Type: application/json" \
  -d '{"question_id": 1, "answer_type": "multiple_choice", "selected_option": "B"}' | jq

# Answer 2 - Multiple Choice
curl -s -X POST $BASE_URL/api/v1/quiz/attempt/$ATTEMPT_ID/answer \
  -H "Content-Type: application/json" \
  -d '{"question_id": 2, "answer_type": "multiple_choice", "selected_option": "A"}' | jq

# Answer 3 - Multiple Choice
curl -s -X POST $BASE_URL/api/v1/quiz/attempt/$ATTEMPT_ID/answer \
  -H "Content-Type: application/json" \
  -d '{"question_id": 3, "answer_type": "multiple_choice", "selected_option": "C"}' | jq

# Answer 4 - Essay
curl -s -X POST $BASE_URL/api/v1/quiz/attempt/$ATTEMPT_ID/answer \
  -H "Content-Type: application/json" \
  -d '{"question_id": 4, "answer_type": "essay", "answer_text": "Primitive types are basic data types..."}' | jq

# Answer 5 - File Upload
curl -s -X POST $BASE_URL/api/v1/quiz/attempt/$ATTEMPT_ID/answer \
  -H "Content-Type: application/json" \
  -d '{"question_id": 5, "answer_type": "file_upload", "answer_file_path": "/uploads/file.pdf"}' | jq
echo ""

# 4. Submit Quiz
echo "[4/6] Testing Submit Quiz..."
curl -s -X POST $BASE_URL/api/v1/quiz/attempt/$ATTEMPT_ID/submit \
  -H "Content-Type: application/json" | jq
echo ""

# 5. Get Result
echo "[5/6] Testing Get Result..."
curl -s -X GET $BASE_URL/api/v1/quiz/attempt/$ATTEMPT_ID/result | jq
echo ""

# 6. Get History
echo "[6/6] Testing Get Student History..."
curl -s -X GET $BASE_URL/api/v1/student/1/quiz-history | jq
echo ""

echo "==================================="
echo "All tests completed!"
echo "==================================="
```

**Cara pakai:**

```bash
chmod +x test_api.sh
./test_api.sh
```

**Prerequisites:** Install `jq` untuk format JSON:
```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq
```

---

## 📝 Tips Testing

### 1. Pretty Print JSON

Tambahkan `| jq` di akhir curl:

```bash
curl -X GET http://localhost:8081/health | jq
```

### 2. Save Response to File

```bash
curl -X GET http://localhost:8081/health > response.json
```

### 3. Show HTTP Headers

```bash
curl -i -X GET http://localhost:8081/health
```

### 4. Verbose Mode (Debug)

```bash
curl -v -X GET http://localhost:8081/health
```

### 5. Set Timeout

```bash
curl --max-time 10 -X GET http://localhost:8081/health
```

---

## 🐛 Troubleshooting

### Error: Connection Refused

```
curl: (7) Failed to connect to localhost port 8081: Connection refused
```

**Solution:** Server belum running. Jalankan:
```bash
go run cmd/api/main.go
```

---

### Error: Invalid JSON

```json
{
  "success": false,
  "message": "Invalid request body"
}
```

**Solution:** Check format JSON. Pastikan:
- Pakai double quotes (`"`) bukan single quotes (`'`)
- Tidak ada trailing comma
- Struktur valid

---

### Error: 404 Not Found

```json
{
  "success": false,
  "message": "404 page not found"
}
```

**Solution:** Check endpoint URL. Pastikan:
- Path benar: `/api/v1/quiz/...`
- Method benar: GET/POST
- Parameter benar: `:quiz_id`, `:attempt_id`

---

## 📚 References

- [cURL Documentation](https://curl.se/docs/)
- [HTTP Status Codes](https://httpstatuses.com/)
- [JSON Formatter](https://jsonformatter.org/)

---

**Created for:** LMS Quiz Module - Universitas Siber Asia
**Last Updated:** 2025-01-30
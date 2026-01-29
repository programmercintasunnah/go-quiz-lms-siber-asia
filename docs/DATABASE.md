# Database Documentation - LMS Quiz Module

## Overview

Database ini menggunakan **Microsoft SQL Server** dengan normalisasi **Third Normal Form (3NF)** untuk menghindari redundansi data dan menjaga integritas data.

---

## Database Schema

### **Database Name:** `LMS_QuizModule`

---

## Tables

### 1. `users`
Menyimpan informasi pengguna (mahasiswa dan dosen)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| user_id | INT | PK, IDENTITY(1,1) | Primary key |
| username | NVARCHAR(50) | NOT NULL, UNIQUE | Username untuk login |
| full_name | NVARCHAR(100) | NOT NULL | Nama lengkap |
| email | NVARCHAR(100) | NOT NULL, UNIQUE | Email |
| role | NVARCHAR(20) | NOT NULL, CHECK | Role: student, instructor, admin |
| created_at | DATETIME2 | DEFAULT GETDATE() | Tanggal dibuat |
| updated_at | DATETIME2 | DEFAULT GETDATE() | Tanggal diupdate |

---

### 2. `courses`
Menyimpan informasi mata kuliah

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| course_id | INT | PK, IDENTITY(1,1) | Primary key |
| course_code | NVARCHAR(20) | NOT NULL, UNIQUE | Kode mata kuliah |
| course_name | NVARCHAR(100) | NOT NULL | Nama mata kuliah |
| instructor_id | INT | NOT NULL, FK(users) | ID dosen pengampu |
| semester | NVARCHAR(20) | | Semester |
| created_at | DATETIME2 | DEFAULT GETDATE() | Tanggal dibuat |
| updated_at | DATETIME2 | DEFAULT GETDATE() | Tanggal diupdate |

---

### 3. `quizzes`
Menyimpan informasi kuis

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| quiz_id | INT | PK, IDENTITY(1,1) | Primary key |
| course_id | INT | NOT NULL, FK(courses) | ID mata kuliah |
| title | NVARCHAR(200) | NOT NULL | Judul kuis |
| description | NVARCHAR(MAX) | | Deskripsi kuis |
| time_limit_minutes | INT | NOT NULL | Batas waktu pengerjaan (menit) |
| retake_limit | INT | NOT NULL, DEFAULT 1 | Batas pengulangan |
| date_start | DATETIME2 | NOT NULL | Tanggal mulai |
| date_close | DATETIME2 | NOT NULL | Tanggal selesai |
| passing_grade | DECIMAL(5,2) | | Nilai minimum lulus |
| created_at | DATETIME2 | DEFAULT GETDATE() | Tanggal dibuat |
| updated_at | DATETIME2 | DEFAULT GETDATE() | Tanggal diupdate |

**Check Constraints:**
- `date_close > date_start`
- `time_limit_minutes > 0`
- `retake_limit > 0`

---

### 4. `questions`
Menyimpan soal-soal kuis

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| question_id | INT | PK, IDENTITY(1,1) | Primary key |
| quiz_id | INT | NOT NULL, FK(quizzes) | ID kuis |
| question_type | NVARCHAR(20) | NOT NULL, CHECK | Tipe: multiple_choice, essay, file_upload |
| question_text | NVARCHAR(MAX) | NOT NULL | Teks soal |
| points | DECIMAL(5,2) | NOT NULL | Bobot nilai |
| correct_answer | NVARCHAR(MAX) | | Jawaban benar (untuk multiple choice) |
| order_number | INT | | Urutan soal |
| created_at | DATETIME2 | DEFAULT GETDATE() | Tanggal dibuat |
| updated_at | DATETIME2 | DEFAULT GETDATE() | Tanggal diupdate |

---

### 5. `question_options`
Menyimpan pilihan jawaban untuk soal multiple choice

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| option_id | INT | PK, IDENTITY(1,1) | Primary key |
| question_id | INT | NOT NULL, FK(questions) | ID soal |
| option_key | NVARCHAR(5) | NOT NULL | Kunci opsi (A, B, C, D, E) |
| option_text | NVARCHAR(MAX) | NOT NULL | Teks opsi |
| created_at | DATETIME2 | DEFAULT GETDATE() | Tanggal dibuat |

**Unique Constraint:** `(question_id, option_key)`

---

### 6. `quiz_attempts`
Menyimpan percobaan pengerjaan kuis oleh mahasiswa

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| attempt_id | INT | PK, IDENTITY(1,1) | Primary key |
| quiz_id | INT | NOT NULL, FK(quizzes) | ID kuis |
| user_id | INT | NOT NULL, FK(users) | ID mahasiswa |
| attempt_number | INT | NOT NULL | Nomor percobaan ke-berapa |
| start_time | DATETIME2 | DEFAULT GETDATE() | Waktu mulai |
| end_time | DATETIME2 | | Waktu selesai |
| status | NVARCHAR(20) | NOT NULL, CHECK | Status: in_progress, submitted, graded |
| total_score | DECIMAL(5,2) | | Total nilai |
| created_at | DATETIME2 | DEFAULT GETDATE() | Tanggal dibuat |
| updated_at | DATETIME2 | DEFAULT GETDATE() | Tanggal diupdate |

**Unique Constraint:** `(quiz_id, user_id, attempt_number)`

---

### 7. `student_answers`
Menyimpan jawaban mahasiswa untuk setiap soal

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| answer_id | INT | PK, IDENTITY(1,1) | Primary key |
| attempt_id | INT | NOT NULL, FK(quiz_attempts) | ID attempt |
| question_id | INT | NOT NULL, FK(questions) | ID soal |
| answer_text | NVARCHAR(MAX) | | Jawaban essay |
| answer_file_path | NVARCHAR(500) | | Path file upload |
| selected_option | NVARCHAR(5) | | Pilihan jawaban (A, B, C, D, E) |
| is_correct | BIT | | Benar/salah (auto-graded) |
| manual_score | DECIMAL(5,2) | | Nilai manual dari dosen |
| grading_status | NVARCHAR(30) | CHECK | Status: auto_graded, waiting_assessment, manually_graded |
| created_at | DATETIME2 | DEFAULT GETDATE() | Tanggal dibuat |
| updated_at | DATETIME2 | DEFAULT GETDATE() | Tanggal diupdate |

**Unique Constraint:** `(attempt_id, question_id)`

---

## Entity Relationship Diagram (ERD)

```
users (1) ----< (N) courses
courses (1) ----< (N) quizzes
quizzes (1) ----< (N) questions
questions (1) ----< (N) question_options
quizzes (1) ----< (N) quiz_attempts
users (1) ----< (N) quiz_attempts
quiz_attempts (1) ----< (N) student_answers
questions (1) ----< (N) student_answers
```

Lihat file `database/erd/quiz_module_erd.png` untuk diagram visual.

---

## Indexes

Indexes dibuat untuk meningkatkan performa query:

1. `idx_quiz_attempts_user` - Index pada `quiz_attempts.user_id`
2. `idx_quiz_attempts_quiz` - Index pada `quiz_attempts.quiz_id`
3. `idx_quiz_attempts_status` - Index pada `quiz_attempts.status`
4. `idx_student_answers_attempt` - Index pada `student_answers.attempt_id`
5. `idx_student_answers_question` - Index pada `student_answers.question_id`
6. `idx_questions_quiz` - Index pada `questions.quiz_id`
7. `idx_question_options_question` - Index pada `question_options.question_id`

---

## Stored Procedures

### 1. `sp_GetStudentQuizHistory`
**Purpose:** Mendapatkan riwayat kuis mahasiswa

**Parameters:**
- `@user_id INT` - ID mahasiswa

**Returns:** Daftar kuis yang pernah dikerjakan dengan detail nilai

---

### 2. `sp_StartQuizAttempt`
**Purpose:** Validasi dan memulai quiz attempt

**Parameters:**
- `@quiz_id INT` - ID kuis
- `@user_id INT` - ID mahasiswa
- `@result_message NVARCHAR(500) OUTPUT` - Pesan hasil
- `@attempt_id INT OUTPUT` - ID attempt yang dibuat

**Validations:**
- Quiz exists
- Date range valid
- Retake limit not exceeded
- No in-progress attempt

---

### 3. `sp_CalculateQuizScore`
**Purpose:** Menghitung total score quiz

**Parameters:**
- `@attempt_id INT` - ID attempt
- `@total_score DECIMAL(5,2) OUTPUT` - Total score
- `@has_waiting_assessment BIT OUTPUT` - Ada soal yang menunggu penilaian manual

---

### 4. `sp_GetQuizStatistics`
**Purpose:** Mendapatkan statistik quiz untuk dosen

**Parameters:**
- `@quiz_id INT` - ID quiz

**Returns:** Statistik seperti rata-rata nilai, jumlah siswa, dll

---

## Normalization

Database ini mengikuti **Third Normal Form (3NF)**:

### 1NF (First Normal Form):
✅ Setiap kolom memiliki nilai atomic (tidak ada multi-value)
✅ Setiap baris unique dengan primary key

### 2NF (Second Normal Form):
✅ Memenuhi 1NF
✅ Tidak ada partial dependency (semua non-key attributes fully dependent on primary key)

### 3NF (Third Normal Form):
✅ Memenuhi 2NF
✅ Tidak ada transitive dependency
✅ Contoh: `instructor_id` di table `courses` mereferensi ke table `users`, bukan menyimpan nama dosen secara langsung

---

## Data Integrity

### Foreign Key Constraints
- Memastikan referential integrity
- Cascade delete pada beberapa relasi (questions, student_answers)

### Check Constraints
- Validasi nilai pada level database
- Contoh: `question_type IN ('multiple_choice', 'essay', 'file_upload')`

### Unique Constraints
- Mencegah duplikasi data
- Contoh: `(quiz_id, user_id, attempt_number)` di `quiz_attempts`

---

## Security Considerations

1. **Sensitive Data:**
   - Field `correct_answer` di table `questions` tidak di-expose ke mahasiswa melalui API

2. **Access Control:**
   - Role-based access (student, instructor, admin)
   - Mahasiswa hanya bisa akses data mereka sendiri
   - Dosen bisa akses data semua mahasiswa di course mereka

3. **SQL Injection Prevention:**
   - Menggunakan parameterized queries di aplikasi
   - Stored procedures untuk operasi kompleks

---

## Migration Guide

Lihat file `scripts/setup_db.sh` untuk cara menjalankan migration.

Urutan eksekusi:
1. `001_create_tables.sql` - Buat schema
2. `002_create_stored_procedures.sql` - Buat stored procedures
3. `003_seed_data.sql` - Insert sample data (optional)

---

## Maintenance

### Backup Strategy
- Daily full backup
- Transaction log backup setiap 1 jam

### Index Maintenance
- Rebuild indexes weekly
- Update statistics daily

---

## Contact

For questions about database schema, contact: [your-email@example.com]
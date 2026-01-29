package domain

import "time"

// QuizAttempt - Domain model for quiz attempt
type QuizAttempt struct {
	AttemptID     int        `db:"attempt_id" json:"attempt_id"`
	QuizID        int        `db:"quiz_id" json:"quiz_id"`
	UserID        int        `db:"user_id" json:"user_id"`
	AttemptNumber int        `db:"attempt_number" json:"attempt_number"`
	StartTime     time.Time  `db:"start_time" json:"start_time"`
	EndTime       *time.Time `db:"end_time" json:"end_time,omitempty"`
	Status        string     `db:"status" json:"status"` // in_progress, submitted, graded
	TotalScore    *float64   `db:"total_score" json:"total_score,omitempty"`
	CreatedAt     time.Time  `db:"created_at" json:"created_at"`
	UpdatedAt     time.Time  `db:"updated_at" json:"updated_at"`
}

// StartQuizRequest - Request model untuk start quiz
type StartQuizRequest struct {
	UserID int `json:"user_id" binding:"required" validate:"required,min=1"`
}

// StartQuizResponse - Response model untuk start quiz
type StartQuizResponse struct {
	AttemptID        int        `json:"attempt_id"`
	QuizID           int        `json:"quiz_id"`
	StartTime        time.Time  `json:"start_time"`
	TimeLimitMinutes int        `json:"time_limit_minutes"`
	Questions        []Question `json:"questions"`
}

// QuizHistory - Model untuk riwayat quiz mahasiswa
type QuizHistory struct {
	AttemptID      int        `db:"attempt_id" json:"attempt_id"`
	QuizID         int        `db:"quiz_id" json:"quiz_id"`
	QuizTitle      string     `db:"quiz_title" json:"quiz_title"`
	CourseName     string     `db:"course_name" json:"course_name"`
	AttemptNumber  int        `db:"attempt_number" json:"attempt_number"`
	StartTime      time.Time  `db:"start_time" json:"start_time"`
	EndTime        *time.Time `db:"end_time" json:"end_time,omitempty"`
	Status         string     `db:"status" json:"status"`
	TotalScore     *float64   `db:"total_score" json:"total_score,omitempty"`
	TotalQuestions int        `db:"total_questions" json:"total_questions"`
}

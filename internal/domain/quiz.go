package domain

import "time"

// Quiz - Domain model for quiz
type Quiz struct {
	QuizID           int       `db:"quiz_id" json:"quiz_id"`
	CourseID         int       `db:"course_id" json:"course_id"`
	Title            string    `db:"title" json:"title"`
	Description      string    `db:"description" json:"description"`
	TimeLimitMinutes int       `db:"time_limit_minutes" json:"time_limit_minutes"`
	RetakeLimit      int       `db:"retake_limit" json:"retake_limit"`
	DateStart        time.Time `db:"date_start" json:"date_start"`
	DateClose        time.Time `db:"date_close" json:"date_close"`
	PassingGrade     float64   `db:"passing_grade" json:"passing_grade"`
	CreatedAt        time.Time `db:"created_at" json:"created_at"`
}

// QuizDetail - Quiz with questions
type QuizDetail struct {
	Quiz
	Questions []Question `json:"questions"`
}

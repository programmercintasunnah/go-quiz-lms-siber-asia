package domain

import "time"

// StudentAnswer - Domain model for student answer
type StudentAnswer struct {
	AnswerID       int       `db:"answer_id" json:"answer_id"`
	AttemptID      int       `db:"attempt_id" json:"attempt_id"`
	QuestionID     int       `db:"question_id" json:"question_id"`
	AnswerText     *string   `db:"answer_text" json:"answer_text,omitempty"`
	AnswerFilePath *string   `db:"answer_file_path" json:"answer_file_path,omitempty"`
	SelectedOption *string   `db:"selected_option" json:"selected_option,omitempty"`
	IsCorrect      *bool     `db:"is_correct" json:"is_correct,omitempty"`
	ManualScore    *float64  `db:"manual_score" json:"manual_score,omitempty"`
	GradingStatus  string    `db:"grading_status" json:"grading_status"`
	CreatedAt      time.Time `db:"created_at" json:"created_at"`
	UpdatedAt      time.Time `db:"updated_at" json:"updated_at"`
}

// SubmitAnswerRequest - Request model untuk submit answer
type SubmitAnswerRequest struct {
	QuestionID     int     `json:"question_id" binding:"required" validate:"required,min=1"`
	AnswerType     string  `json:"answer_type" binding:"required" validate:"required,oneof=multiple_choice essay file_upload"`
	SelectedOption *string `json:"selected_option" validate:"required_if=AnswerType multiple_choice"`
	AnswerText     *string `json:"answer_text" validate:"required_if=AnswerType essay"`
	AnswerFilePath *string `json:"answer_file_path" validate:"required_if=AnswerType file_upload"`
}

// BulkSubmitAnswerRequest - Request model untuk bulk submit answers
type BulkSubmitAnswerRequest struct {
	Answers []SubmitAnswerRequest `json:"answers" binding:"required" validate:"required,dive"`
}

// QuizResult - Response model untuk hasil quiz
type QuizResult struct {
	AttemptID  int                  `json:"attempt_id"`
	QuizTitle  string               `json:"quiz_title"`
	TotalScore *float64             `json:"total_score"`
	Status     string               `json:"status"`
	StartTime  time.Time            `json:"start_time"`
	EndTime    *time.Time           `json:"end_time,omitempty"`
	Answers    []AnswerWithQuestion `json:"answers"`
}

// AnswerWithQuestion - Model untuk answer dengan detail question
type AnswerWithQuestion struct {
	QuestionID    int      `json:"question_id"`
	QuestionText  string   `json:"question_text"`
	QuestionType  string   `json:"question_type"`
	Points        float64  `json:"points"`
	StudentAnswer *string  `json:"student_answer,omitempty"`
	CorrectAnswer *string  `json:"correct_answer,omitempty"`
	IsCorrect     *bool    `json:"is_correct,omitempty"`
	Score         *float64 `json:"score,omitempty"`
	GradingStatus string   `json:"grading_status"`
}

// SubmitQuizResponse - Response model untuk submit quiz
type SubmitQuizResponse struct {
	AttemptID            int     `json:"attempt_id"`
	Status               string  `json:"status"`
	AutoGradedScore      float64 `json:"auto_graded_score"`
	PendingManualGrading bool    `json:"pending_manual_grading"`
	TotalQuestions       int     `json:"total_questions"`
	AutoGradedQuestions  int     `json:"auto_graded_questions"`
	WaitingAssessment    int     `json:"waiting_assessment"`
}

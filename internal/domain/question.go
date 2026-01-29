package domain

// Question - Domain model for question
type Question struct {
	QuestionID    int              `db:"question_id" json:"question_id"`
	QuizID        int              `db:"quiz_id" json:"quiz_id"`
	QuestionType  string           `db:"question_type" json:"question_type"` // multiple_choice, essay, file_upload
	QuestionText  string           `db:"question_text" json:"question_text"`
	Points        float64          `db:"points" json:"points"`
	CorrectAnswer string           `db:"correct_answer" json:"-"` // Hidden from student
	OrderNumber   int              `db:"order_number" json:"order_number"`
	Options       []QuestionOption `json:"options,omitempty"`
}

// QuestionOption - Domain model for question option (multiple choice)
type QuestionOption struct {
	OptionID   int    `db:"option_id" json:"option_id"`
	QuestionID int    `db:"question_id" json:"question_id"`
	OptionKey  string `db:"option_key" json:"option_key"` // A, B, C, D, E
	OptionText string `db:"option_text" json:"option_text"`
}

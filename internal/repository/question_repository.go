package repository

import (
	"database/sql"
	"go-quiz-lms-siber-asia/internal/domain"

	"github.com/jmoiron/sqlx"
)

type QuestionRepository struct {
	db *sqlx.DB
}

func NewQuestionRepository(db *sqlx.DB) *QuestionRepository {
	return &QuestionRepository{db: db}
}

// GetByQuizID - Get all questions for a quiz
func (r *QuestionRepository) GetByQuizID(quizID int) ([]domain.Question, error) {
	var questions []domain.Question
	query := `SELECT question_id, quiz_id, question_type, question_text, 
              points, order_number 
              FROM questions 
              WHERE quiz_id = @p1 
              ORDER BY order_number`

	err := r.db.Select(&questions, query, quizID)
	if err != nil {
		return nil, err
	}

	// Get options for multiple choice questions
	for i, q := range questions {
		if q.QuestionType == "multiple_choice" {
			options, err := r.GetOptionsByQuestionID(q.QuestionID)
			if err != nil {
				return nil, err
			}
			questions[i].Options = options
		}
	}

	return questions, nil
}

// GetByID - Get question by ID (including correct answer for grading)
func (r *QuestionRepository) GetByID(questionID int) (*domain.Question, error) {
	var question domain.Question
	query := `SELECT question_id, quiz_id, question_type, question_text, 
              points, correct_answer, order_number 
              FROM questions 
              WHERE question_id = @p1`

	err := r.db.Get(&question, query, questionID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	return &question, nil
}

// GetOptionsByQuestionID - Get all options for a question
func (r *QuestionRepository) GetOptionsByQuestionID(questionID int) ([]domain.QuestionOption, error) {
	var options []domain.QuestionOption
	query := `SELECT option_id, question_id, option_key, option_text 
              FROM question_options 
              WHERE question_id = @p1 
              ORDER BY option_key`

	err := r.db.Select(&options, query, questionID)
	return options, err
}

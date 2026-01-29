package repository

import (
	"database/sql"
	"go-quiz-lms-siber-asia/internal/domain"

	"github.com/jmoiron/sqlx"
)

type AttemptRepository struct {
	db *sqlx.DB
}

func NewAttemptRepository(db *sqlx.DB) *AttemptRepository {
	return &AttemptRepository{db: db}
}

// SaveAnswer - Save or update student answer
func (r *AttemptRepository) SaveAnswer(answer *domain.StudentAnswer) error {
	// Check if answer already exists
	var exists bool
	checkQuery := `SELECT CASE WHEN EXISTS (
        SELECT 1 FROM student_answers 
        WHERE attempt_id = @p1 AND question_id = @p2
    ) THEN 1 ELSE 0 END`

	err := r.db.Get(&exists, checkQuery, answer.AttemptID, answer.QuestionID)
	if err != nil {
		return err
	}

	if exists {
		// Update existing answer
		updateQuery := `UPDATE student_answers 
                       SET answer_text = @p1, answer_file_path = @p2, 
                           selected_option = @p3, is_correct = @p4, 
                           manual_score = @p5, grading_status = @p6, 
                           updated_at = GETDATE()
                       WHERE attempt_id = @p7 AND question_id = @p8`

		_, err = r.db.Exec(updateQuery,
			answer.AnswerText,
			answer.AnswerFilePath,
			answer.SelectedOption,
			answer.IsCorrect,
			answer.ManualScore,
			answer.GradingStatus,
			answer.AttemptID,
			answer.QuestionID,
		)
	} else {
		// Insert new answer
		insertQuery := `INSERT INTO student_answers 
                       (attempt_id, question_id, answer_text, answer_file_path, 
                        selected_option, is_correct, manual_score, grading_status)
                       OUTPUT INSERTED.answer_id, INSERTED.created_at, INSERTED.updated_at
                       VALUES (@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)`

		err = r.db.QueryRow(insertQuery,
			answer.AttemptID,
			answer.QuestionID,
			answer.AnswerText,
			answer.AnswerFilePath,
			answer.SelectedOption,
			answer.IsCorrect,
			answer.ManualScore,
			answer.GradingStatus,
		).Scan(&answer.AnswerID, &answer.CreatedAt, &answer.UpdatedAt)
	}

	return err
}

// GetAnswersByAttemptID - Get all answers for an attempt
func (r *AttemptRepository) GetAnswersByAttemptID(attemptID int) ([]domain.StudentAnswer, error) {
	var answers []domain.StudentAnswer
	query := `SELECT answer_id, attempt_id, question_id, answer_text, 
              answer_file_path, selected_option, is_correct, manual_score, 
              grading_status, created_at, updated_at 
              FROM student_answers 
              WHERE attempt_id = @p1`

	err := r.db.Select(&answers, query, attemptID)
	return answers, err
}

// GetAnswersWithQuestions - Get answers with question details for result display
func (r *AttemptRepository) GetAnswersWithQuestions(attemptID int) ([]domain.AnswerWithQuestion, error) {
	var answers []domain.AnswerWithQuestion
	query := `SELECT 
                q.question_id,
                q.question_text,
                q.question_type,
                q.points,
                sa.selected_option,
                sa.answer_text,
                q.correct_answer,
                sa.is_correct,
                sa.manual_score as score,
                sa.grading_status
              FROM questions q
              LEFT JOIN student_answers sa ON q.question_id = sa.question_id 
                AND sa.attempt_id = @p1
              INNER JOIN quiz_attempts qa ON q.quiz_id = qa.quiz_id
              WHERE qa.attempt_id = @p1
              ORDER BY q.order_number`

	rows, err := r.db.Query(query, attemptID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var answer domain.AnswerWithQuestion
		var selectedOption, answerText, correctAnswer sql.NullString
		var isCorrect sql.NullBool
		var score sql.NullFloat64
		var gradingStatus sql.NullString

		err := rows.Scan(
			&answer.QuestionID,
			&answer.QuestionText,
			&answer.QuestionType,
			&answer.Points,
			&selectedOption,
			&answerText,
			&correctAnswer,
			&isCorrect,
			&score,
			&gradingStatus,
		)
		if err != nil {
			return nil, err
		}

		// Handle NULL values
		if selectedOption.Valid {
			answer.StudentAnswer = &selectedOption.String
		} else if answerText.Valid {
			answer.StudentAnswer = &answerText.String
		}

		if correctAnswer.Valid {
			answer.CorrectAnswer = &correctAnswer.String
		}

		if isCorrect.Valid {
			answer.IsCorrect = &isCorrect.Bool
		}

		if score.Valid {
			answer.Score = &score.Float64
		}

		if gradingStatus.Valid {
			answer.GradingStatus = gradingStatus.String
		} else {
			answer.GradingStatus = "not_answered"
		}

		answers = append(answers, answer)
	}

	return answers, nil
}

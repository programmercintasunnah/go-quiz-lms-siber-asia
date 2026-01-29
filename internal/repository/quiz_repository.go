package repository

import (
	"database/sql"
	"go-quiz-lms-siber-asia/internal/domain"

	"github.com/jmoiron/sqlx"
)

type QuizRepository struct {
	db *sqlx.DB
}

func NewQuizRepository(db *sqlx.DB) *QuizRepository {
	return &QuizRepository{db: db}
}

// GetByID - Get quiz by ID
func (r *QuizRepository) GetByID(quizID int) (*domain.Quiz, error) {
	var quiz domain.Quiz
	query := `SELECT quiz_id, course_id, title, description, time_limit_minutes, 
              retake_limit, date_start, date_close, passing_grade, created_at 
              FROM quizzes WHERE quiz_id = @p1`

	err := r.db.Get(&quiz, query, quizID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	return &quiz, nil
}

// GetAttemptCount - Get total attempts for a quiz by a user
func (r *QuizRepository) GetAttemptCount(quizID, userID int) (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM quiz_attempts 
              WHERE quiz_id = @p1 AND user_id = @p2`

	err := r.db.Get(&count, query, quizID, userID)
	return count, err
}

// HasInProgressAttempt - Check if user has in-progress attempt
func (r *QuizRepository) HasInProgressAttempt(quizID, userID int) (bool, error) {
	var count int
	query := `SELECT COUNT(*) FROM quiz_attempts 
              WHERE quiz_id = @p1 AND user_id = @p2 AND status = 'in_progress'`

	err := r.db.Get(&count, query, quizID, userID)
	return count > 0, err
}

// CreateAttempt - Create new quiz attempt
func (r *QuizRepository) CreateAttempt(attempt *domain.QuizAttempt) error {
	query := `INSERT INTO quiz_attempts (quiz_id, user_id, attempt_number, status)
              OUTPUT INSERTED.attempt_id, INSERTED.start_time, INSERTED.created_at, INSERTED.updated_at
              VALUES (@p1, @p2, @p3, @p4)`

	err := r.db.QueryRow(query,
		attempt.QuizID,
		attempt.UserID,
		attempt.AttemptNumber,
		attempt.Status,
	).Scan(&attempt.AttemptID, &attempt.StartTime, &attempt.CreatedAt, &attempt.UpdatedAt)

	return err
}

// GetAttemptByID - Get attempt by ID
func (r *QuizRepository) GetAttemptByID(attemptID int) (*domain.QuizAttempt, error) {
	var attempt domain.QuizAttempt
	query := `SELECT attempt_id, quiz_id, user_id, attempt_number, start_time, 
              end_time, status, total_score, created_at, updated_at 
              FROM quiz_attempts WHERE attempt_id = @p1`

	err := r.db.Get(&attempt, query, attemptID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	return &attempt, nil
}

// UpdateAttemptStatus - Update attempt status and total score
func (r *QuizRepository) UpdateAttemptStatus(attemptID int, status string, totalScore *float64) error {
	query := `UPDATE quiz_attempts 
              SET status = @p1, total_score = @p2, end_time = GETDATE(), updated_at = GETDATE()
              WHERE attempt_id = @p3`

	_, err := r.db.Exec(query, status, totalScore, attemptID)
	return err
}

// GetStudentHistory - Get student quiz history using stored procedure
func (r *QuizRepository) GetStudentHistory(userID int) ([]domain.QuizHistory, error) {
	var history []domain.QuizHistory
	query := `EXEC sp_GetStudentQuizHistory @p1`

	err := r.db.Select(&history, query, userID)
	if err != nil {
		return nil, err
	}

	return history, nil
}

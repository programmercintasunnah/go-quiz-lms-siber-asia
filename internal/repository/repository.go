package repository

import "go-quiz-lms-siber-asia/internal/domain"

// QuizRepositoryInterface - Interface untuk quiz repository
type QuizRepositoryInterface interface {
	GetByID(quizID int) (*domain.Quiz, error)
	GetAttemptCount(quizID, userID int) (int, error)
	HasInProgressAttempt(quizID, userID int) (bool, error)
	CreateAttempt(attempt *domain.QuizAttempt) error
	GetAttemptByID(attemptID int) (*domain.QuizAttempt, error)
	UpdateAttemptStatus(attemptID int, status string, totalScore *float64) error
	GetStudentHistory(userID int) ([]domain.QuizHistory, error)
}

// QuestionRepositoryInterface - Interface untuk question repository
type QuestionRepositoryInterface interface {
	GetByQuizID(quizID int) ([]domain.Question, error)
	GetByID(questionID int) (*domain.Question, error)
	GetOptionsByQuestionID(questionID int) ([]domain.QuestionOption, error)
}

// AttemptRepositoryInterface - Interface untuk attempt repository
type AttemptRepositoryInterface interface {
	SaveAnswer(answer *domain.StudentAnswer) error
	GetAnswersByAttemptID(attemptID int) ([]domain.StudentAnswer, error)
	GetAnswersWithQuestions(attemptID int) ([]domain.AnswerWithQuestion, error)
}

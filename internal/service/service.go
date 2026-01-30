package service

import "go-quiz-lms-siber-asia/internal/domain"

// QuizServiceInterface - Interface untuk quiz service
type QuizServiceInterface interface {
	StartQuiz(quizID, userID int) (*domain.StartQuizResponse, error)
	SubmitAnswer(attemptID int, req *domain.SubmitAnswerRequest) error
	SubmitQuiz(attemptID int) (*domain.SubmitQuizResponse, error)
	GetResult(attemptID int) (*domain.QuizResult, error)
	GetStudentHistory(userID int) ([]domain.QuizHistory, error)
}

// GradingServiceInterface - Interface untuk grading service
type GradingServiceInterface interface {
	AutoGrade(answer *domain.StudentAnswer, questionType string, correctAnswer *string)
	CalculateTotalScore(attemptID int) (float64, bool, error)
}

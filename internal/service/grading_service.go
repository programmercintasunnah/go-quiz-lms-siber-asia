package service

import (
	"go-quiz-lms-siber-asia/internal/domain"
	"go-quiz-lms-siber-asia/internal/repository"
)

type GradingService struct {
	questionRepo repository.QuestionRepositoryInterface
	attemptRepo  repository.AttemptRepositoryInterface
}

func NewGradingService(
	questionRepo repository.QuestionRepositoryInterface,
	attemptRepo repository.AttemptRepositoryInterface,
) *GradingService {
	return &GradingService{
		questionRepo: questionRepo,
		attemptRepo:  attemptRepo,
	}
}

// AutoGrade - Grade jawaban berdasarkan tipe soal
func (s *GradingService) AutoGrade(answer *domain.StudentAnswer, questionType string, correctAnswer *string) {
	switch questionType {
	case "multiple_choice":
		// Auto grade untuk pilihan ganda
		if correctAnswer != nil && answer.SelectedOption != nil && *answer.SelectedOption == *correctAnswer {
			isCorrect := true
			answer.IsCorrect = &isCorrect
			answer.GradingStatus = "auto_graded"
		} else {
			isCorrect := false
			answer.IsCorrect = &isCorrect
			answer.GradingStatus = "auto_graded"
		}

	case "essay", "file_upload":
		// Menunggu penilaian manual dari dosen
		answer.GradingStatus = "waiting_assessment"
		answer.IsCorrect = nil
		answer.ManualScore = nil
	}
}

// CalculateTotalScore - Hitung total score untuk attempt
func (s *GradingService) CalculateTotalScore(attemptID int) (float64, bool, error) {
	answers, err := s.attemptRepo.GetAnswersByAttemptID(attemptID)
	if err != nil {
		return 0, false, err
	}

	var totalScore float64
	hasWaitingAssessment := false

	for _, answer := range answers {
		if answer.GradingStatus == "waiting_assessment" {
			hasWaitingAssessment = true
			continue
		}

		// Get question untuk ambil points
		question, err := s.questionRepo.GetByID(answer.QuestionID)
		if err != nil {
			continue
		}

		// Hitung score
		if answer.GradingStatus == "auto_graded" {
			if answer.IsCorrect != nil && *answer.IsCorrect {
				totalScore += question.Points
			}
		} else if answer.GradingStatus == "manually_graded" && answer.ManualScore != nil {
			totalScore += *answer.ManualScore
		}
	}

	return totalScore, hasWaitingAssessment, nil
}

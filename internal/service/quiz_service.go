package service

import (
	"errors"
	"go-quiz-lms-siber-asia/internal/domain"
	"go-quiz-lms-siber-asia/internal/repository"
	"time"
)

type QuizService struct {
	quizRepo       repository.QuizRepositoryInterface
	questionRepo   repository.QuestionRepositoryInterface
	attemptRepo    repository.AttemptRepositoryInterface
	gradingService GradingServiceInterface
}

func NewQuizService(
	quizRepo repository.QuizRepositoryInterface,
	questionRepo repository.QuestionRepositoryInterface,
	attemptRepo repository.AttemptRepositoryInterface,
	gradingService GradingServiceInterface,
) *QuizService {
	return &QuizService{
		quizRepo:       quizRepo,
		questionRepo:   questionRepo,
		attemptRepo:    attemptRepo,
		gradingService: gradingService,
	}
}

// StartQuiz - Memulai quiz dengan validasi
func (s *QuizService) StartQuiz(quizID, userID int) (*domain.StartQuizResponse, error) {
	// 1. Get quiz details
	quiz, err := s.quizRepo.GetByID(quizID)
	if err != nil {
		return nil, err
	}
	if quiz == nil {
		return nil, errors.New("quiz not found")
	}

	// 2. Validasi tanggal
	now := time.Now()
	if now.Before(quiz.DateStart) {
		return nil, errors.New("quiz has not started yet")
	}
	if now.After(quiz.DateClose) {
		return nil, errors.New("quiz has closed")
	}

	// 3. Cek apakah ada attempt yang sedang in_progress
	hasInProgress, err := s.quizRepo.HasInProgressAttempt(quizID, userID)
	if err != nil {
		return nil, err
	}
	if hasInProgress {
		return nil, errors.New("you have an in-progress attempt")
	}

	// 4. Cek retake limit
	attemptCount, err := s.quizRepo.GetAttemptCount(quizID, userID)
	if err != nil {
		return nil, err
	}
	if attemptCount >= quiz.RetakeLimit {
		return nil, errors.New("retake limit exceeded")
	}

	// 5. Create new attempt
	attempt := &domain.QuizAttempt{
		QuizID:        quizID,
		UserID:        userID,
		AttemptNumber: attemptCount + 1,
		Status:        "in_progress",
	}

	err = s.quizRepo.CreateAttempt(attempt)
	if err != nil {
		return nil, errors.New("failed to create attempt")
	}

	// 6. Get questions
	questions, err := s.questionRepo.GetByQuizID(quizID)
	if err != nil {
		return nil, errors.New("failed to fetch questions")
	}

	// 7. Build response
	response := &domain.StartQuizResponse{
		AttemptID:        attempt.AttemptID,
		QuizID:           quizID,
		StartTime:        attempt.StartTime,
		TimeLimitMinutes: quiz.TimeLimitMinutes,
		Questions:        questions,
	}

	return response, nil
}

// SubmitAnswer - Menyimpan jawaban dan auto-grade
func (s *QuizService) SubmitAnswer(attemptID int, req *domain.SubmitAnswerRequest) error {
	// 1. Validasi attempt masih in_progress
	attempt, err := s.quizRepo.GetAttemptByID(attemptID)
	if err != nil {
		return err
	}
	if attempt == nil {
		return errors.New("attempt not found")
	}
	if attempt.Status != "in_progress" {
		return errors.New("attempt is not in progress")
	}

	// 2. Get question untuk validasi
	question, err := s.questionRepo.GetByID(req.QuestionID)
	if err != nil {
		return err
	}
	if question == nil {
		return errors.New("question not found")
	}

	// 3. Validasi tipe jawaban sesuai dengan tipe soal
	if question.QuestionType != req.AnswerType {
		return errors.New("answer type mismatch")
	}

	// 4. Build student answer
	answer := &domain.StudentAnswer{
		AttemptID:      attemptID,
		QuestionID:     req.QuestionID,
		AnswerText:     req.AnswerText,
		AnswerFilePath: req.AnswerFilePath,
		SelectedOption: req.SelectedOption,
	}

	// 5. Auto-grade
	s.gradingService.AutoGrade(answer, question.QuestionType, question.CorrectAnswer)

	// 6. Save answer
	err = s.attemptRepo.SaveAnswer(answer)
	if err != nil {
		return errors.New("failed to save answer")
	}

	return nil
}

// SubmitQuiz - Finalisasi quiz
func (s *QuizService) SubmitQuiz(attemptID int) (*domain.SubmitQuizResponse, error) {
	// 1. Validasi attempt exists
	attempt, err := s.quizRepo.GetAttemptByID(attemptID)
	if err != nil {
		return nil, err
	}
	if attempt == nil {
		return nil, errors.New("attempt not found")
	}
	if attempt.Status != "in_progress" {
		return nil, errors.New("attempt is not in progress")
	}

	// 2. Get all answers
	answers, err := s.attemptRepo.GetAnswersByAttemptID(attemptID)
	if err != nil {
		return nil, err
	}

	// 3. Calculate statistics
	totalQuestions := 0
	autoGradedQuestions := 0
	waitingAssessment := 0

	quiz, _ := s.quizRepo.GetByID(attempt.QuizID)
	if quiz != nil {
		questions, _ := s.questionRepo.GetByQuizID(quiz.QuizID)
		totalQuestions = len(questions)
	}

	for _, answer := range answers {
		if answer.GradingStatus == "auto_graded" {
			autoGradedQuestions++
		} else if answer.GradingStatus == "waiting_assessment" {
			waitingAssessment++
		}
	}

	// 4. Calculate total score
	totalScore, hasWaiting, err := s.gradingService.CalculateTotalScore(attemptID)
	if err != nil {
		return nil, err
	}

	// 5. Determine status
	status := "graded"
	if hasWaiting {
		status = "submitted" // Waiting for manual grading
	}

	// 6. Update attempt
	var scorePtr *float64
	if !hasWaiting {
		scorePtr = &totalScore
	}

	err = s.quizRepo.UpdateAttemptStatus(attemptID, status, scorePtr)
	if err != nil {
		return nil, errors.New("failed to submit quiz")
	}

	// 7. Build response
	response := &domain.SubmitQuizResponse{
		AttemptID:            attemptID,
		Status:               status,
		AutoGradedScore:      totalScore,
		PendingManualGrading: hasWaiting,
		TotalQuestions:       totalQuestions,
		AutoGradedQuestions:  autoGradedQuestions,
		WaitingAssessment:    waitingAssessment,
	}

	return response, nil
}

// GetResult - Mendapatkan hasil quiz
func (s *QuizService) GetResult(attemptID int) (*domain.QuizResult, error) {
	// 1. Get attempt
	attempt, err := s.quizRepo.GetAttemptByID(attemptID)
	if err != nil {
		return nil, err
	}
	if attempt == nil {
		return nil, errors.New("attempt not found")
	}

	// 2. Get quiz
	quiz, err := s.quizRepo.GetByID(attempt.QuizID)
	if err != nil {
		return nil, err
	}
	if quiz == nil {
		return nil, errors.New("quiz not found")
	}

	// 3. Get answers with questions
	answers, err := s.attemptRepo.GetAnswersWithQuestions(attemptID)
	if err != nil {
		return nil, errors.New("failed to fetch answers")
	}

	// 4. Build result
	result := &domain.QuizResult{
		AttemptID:  attemptID,
		QuizTitle:  quiz.Title,
		TotalScore: attempt.TotalScore,
		Status:     attempt.Status,
		StartTime:  attempt.StartTime,
		EndTime:    attempt.EndTime,
		Answers:    answers,
	}

	return result, nil
}

// GetStudentHistory - Get student quiz history
func (s *QuizService) GetStudentHistory(userID int) ([]domain.QuizHistory, error) {
	return s.quizRepo.GetStudentHistory(userID)
}

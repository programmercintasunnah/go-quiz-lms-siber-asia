package handler

import (
	"net/http"
	"strconv"

	"go-quiz-lms-siber-asia/internal/domain"
	"go-quiz-lms-siber-asia/internal/service"

	"github.com/gin-gonic/gin"
)

type QuizHandler struct {
	quizService service.QuizServiceInterface
}

func NewQuizHandler(quizService service.QuizServiceInterface) *QuizHandler {
	return &QuizHandler{quizService: quizService}
}

// StartQuiz - POST /api/v1/quiz/:quiz_id/start
func (h *QuizHandler) StartQuiz(c *gin.Context) {
	// Get quiz_id from URL
	quizID, err := strconv.Atoi(c.Param("quiz_id"))
	if err != nil {
		ErrorResponse(c, http.StatusBadRequest, "Invalid quiz ID", err.Error())
		return
	}

	// Parse request body
	var req domain.StartQuizRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		ErrorResponse(c, http.StatusBadRequest, "Invalid request body", err.Error())
		return
	}

	// Call service
	result, err := h.quizService.StartQuiz(quizID, req.UserID)
	if err != nil {
		ErrorResponse(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	SuccessResponse(c, http.StatusOK, "Quiz started successfully", result)
}

// SubmitAnswer - POST /api/v1/quiz/attempt/:attempt_id/answer
func (h *QuizHandler) SubmitAnswer(c *gin.Context) {
	// Get attempt_id from URL
	attemptID, err := strconv.Atoi(c.Param("attempt_id"))
	if err != nil {
		ErrorResponse(c, http.StatusBadRequest, "Invalid attempt ID", err.Error())
		return
	}

	// Parse request body
	var req domain.SubmitAnswerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		ErrorResponse(c, http.StatusBadRequest, "Invalid request body", err.Error())
		return
	}

	// Call service
	err = h.quizService.SubmitAnswer(attemptID, &req)
	if err != nil {
		ErrorResponse(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	SuccessResponse(c, http.StatusOK, "Answer submitted successfully", nil)
}

// SubmitQuiz - POST /api/v1/quiz/attempt/:attempt_id/submit
func (h *QuizHandler) SubmitQuiz(c *gin.Context) {
	// Get attempt_id from URL
	attemptID, err := strconv.Atoi(c.Param("attempt_id"))
	if err != nil {
		ErrorResponse(c, http.StatusBadRequest, "Invalid attempt ID", err.Error())
		return
	}

	// Call service
	result, err := h.quizService.SubmitQuiz(attemptID)
	if err != nil {
		ErrorResponse(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	SuccessResponse(c, http.StatusOK, "Quiz submitted successfully", result)
}

// GetResult - GET /api/v1/quiz/attempt/:attempt_id/result
func (h *QuizHandler) GetResult(c *gin.Context) {
	// Get attempt_id from URL
	attemptID, err := strconv.Atoi(c.Param("attempt_id"))
	if err != nil {
		ErrorResponse(c, http.StatusBadRequest, "Invalid attempt ID", err.Error())
		return
	}

	// Call service
	result, err := h.quizService.GetResult(attemptID)
	if err != nil {
		ErrorResponse(c, http.StatusNotFound, err.Error(), nil)
		return
	}

	SuccessResponse(c, http.StatusOK, "Result retrieved successfully", result)
}

// GetStudentHistory - GET /api/v1/student/:user_id/quiz-history
func (h *QuizHandler) GetStudentHistory(c *gin.Context) {
	// Get user_id from URL
	userID, err := strconv.Atoi(c.Param("user_id"))
	if err != nil {
		ErrorResponse(c, http.StatusBadRequest, "Invalid user ID", err.Error())
		return
	}

	// Call service
	history, err := h.quizService.GetStudentHistory(userID)
	if err != nil {
		ErrorResponse(c, http.StatusInternalServerError, "Failed to get quiz history", err.Error())
		return
	}

	SuccessResponse(c, http.StatusOK, "Quiz history retrieved successfully", history)
}

// BulkSubmitAnswers - POST /api/v1/quiz/attempt/:attempt_id/answers/bulk
func (h *QuizHandler) BulkSubmitAnswers(c *gin.Context) {
	// Get attempt_id from URL
	attemptID, err := strconv.Atoi(c.Param("attempt_id"))
	if err != nil {
		ErrorResponse(c, http.StatusBadRequest, "Invalid attempt ID", err.Error())
		return
	}

	// Parse request body
	var req domain.BulkSubmitAnswerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		ErrorResponse(c, http.StatusBadRequest, "Invalid request body", err.Error())
		return
	}

	// Call service
	err = h.quizService.BulkSubmitAnswers(attemptID, &req)
	if err != nil {
		ErrorResponse(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	SuccessResponse(c, http.StatusOK, "All answers submitted successfully", nil)
}

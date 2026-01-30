package app

import (
	"go-quiz-lms-siber-asia/internal/handler"
	"go-quiz-lms-siber-asia/internal/middleware"

	"github.com/gin-gonic/gin"
)

func setupRoutes(router *gin.Engine, quizHandler *handler.QuizHandler) {
	// Middleware
	router.Use(middleware.CORS())
	router.Use(middleware.ErrorHandler())
	router.Use(middleware.Logger())

	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"message": "LMS Quiz Module API is running",
		})
	})

	// API v1
	v1 := router.Group("/api/v1")
	{
		// Quiz routes
		quiz := v1.Group("/quiz")
		{
			// Start quiz
			quiz.POST("/:quiz_id/start", quizHandler.StartQuiz)

			// Attempt routes
			quiz.POST("/attempt/:attempt_id/answer", quizHandler.SubmitAnswer)
			quiz.POST("/attempt/:attempt_id/submit", quizHandler.SubmitQuiz)
			quiz.GET("/attempt/:attempt_id/result", quizHandler.GetResult)
			quiz.POST("/attempt/:attempt_id/answers/bulk", quizHandler.BulkSubmitAnswers)
		}

		// Student routes
		student := v1.Group("/student")
		{
			student.GET("/:user_id/quiz-history", quizHandler.GetStudentHistory)
		}
	}
}

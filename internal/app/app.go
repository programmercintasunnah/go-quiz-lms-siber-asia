package app

import (
	"fmt"
	"log"

	"go-quiz-lms-siber-asia/config"
	"go-quiz-lms-siber-asia/internal/handler"
	"go-quiz-lms-siber-asia/internal/repository"
	"go-quiz-lms-siber-asia/internal/service"
	"go-quiz-lms-siber-asia/pkg/database"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
)

type App struct {
	Config *config.Config
	DB     *sqlx.DB
	Router *gin.Engine
}

// New - Initialize application with dependency injection
func New() (*App, error) {
	// Load config
	cfg, err := config.Load()
	if err != nil {
		return nil, fmt.Errorf("failed to load config: %w", err)
	}

	// Connect database
	connString := cfg.Database.GetConnectionString()
	db, err := database.NewSQLServerConnection(connString)
	if err != nil {
		return nil, fmt.Errorf("failed to connect database: %w", err)
	}

	log.Println("Database connected successfully")

	// Set gin mode
	if cfg.Server.Env == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// Initialize router
	router := gin.Default()

	// Create app instance
	app := &App{
		Config: cfg,
		DB:     db,
		Router: router,
	}

	// Setup dependencies
	app.setupDependencies()

	log.Println("Application initialized successfully")

	return app, nil
}

// setupDependencies - Dependency injection
func (a *App) setupDependencies() {
	// Repositories
	quizRepo := repository.NewQuizRepository(a.DB)
	questionRepo := repository.NewQuestionRepository(a.DB)
	attemptRepo := repository.NewAttemptRepository(a.DB)

	// Services
	gradingService := service.NewGradingService(questionRepo, attemptRepo)
	quizService := service.NewQuizService(quizRepo, questionRepo, attemptRepo, gradingService)

	// Handlers
	quizHandler := handler.NewQuizHandler(quizService)

	// Setup routes
	setupRoutes(a.Router, quizHandler)
}

// Run - Start the application
func (a *App) Run() error {
	addr := fmt.Sprintf(":%s", a.Config.Server.Port)
	log.Printf("Server starting on http://localhost%s", addr)
	return a.Router.Run(addr)
}

// Close - Close database connection
func (a *App) Close() error {
	if a.DB != nil {
		return a.DB.Close()
	}
	return nil
}

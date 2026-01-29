# Makefile for LMS Quiz Module

# Variables
BINARY_NAME=lms-quiz-api
MAIN_PATH=cmd/api/main.go
BUILD_DIR=bin

# Go commands
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod

# Build the application
.PHONY: build
build:
	@echo "Building..."
	@mkdir -p $(BUILD_DIR)
	@$(GOBUILD) -o $(BUILD_DIR)/$(BINARY_NAME) $(MAIN_PATH)
	@echo "Build complete: $(BUILD_DIR)/$(BINARY_NAME)"

# Run the application
.PHONY: run
run:
	@echo "Running application..."
	@$(GOCMD) run $(MAIN_PATH)

# Clean build files
.PHONY: clean
clean:
	@echo "Cleaning..."
	@$(GOCLEAN)
	@rm -rf $(BUILD_DIR)
	@echo "Clean complete"

# Run tests
.PHONY: test
test:
	@echo "Running tests..."
	@$(GOTEST) -v ./...

# Install dependencies
.PHONY: deps
deps:
	@echo "Installing dependencies..."
	@$(GOGET) -u github.com/gin-gonic/gin
	@$(GOGET) -u github.com/jmoiron/sqlx
	@$(GOGET) -u github.com/denisenkom/go-mssqldb
	@$(GOGET) -u github.com/joho/godotenv
	@$(GOGET) -u github.com/go-playground/validator/v10
	@$(GOMOD) tidy
	@echo "Dependencies installed"

# Setup database
.PHONY: db-setup
db-setup:
	@echo "Setting up database..."
	@bash scripts/setup_db.sh

# Run database migrations
.PHONY: db-migrate
db-migrate:
	@echo "Running migrations..."
	@bash scripts/run_migrations.sh

# Reset database (drop and recreate)
.PHONY: db-reset
db-reset:
	@echo "Resetting database..."
	@sqlcmd -S localhost -U sa -P $(DB_PASSWORD) -Q "DROP DATABASE IF EXISTS LMS_QuizModule"
	@$(MAKE) db-setup

# Format code
.PHONY: fmt
fmt:
	@echo "Formatting code..."
	@$(GOCMD) fmt ./...

# Lint code
.PHONY: lint
lint:
	@echo "Linting code..."
	@golangci-lint run

# Run development server with live reload (requires air)
.PHONY: dev
dev:
	@echo "Starting development server..."
	@air

# Build for production
.PHONY: build-prod
build-prod:
	@echo "Building for production..."
	@mkdir -p $(BUILD_DIR)
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) -ldflags="-w -s" -o $(BUILD_DIR)/$(BINARY_NAME) $(MAIN_PATH)
	@echo "Production build complete"

# Create .env file from example
.PHONY: init
init:
	@echo "Initializing project..."
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo ".env file created from .env.example"; \
		echo "Please update .env with your database credentials"; \
	else \
		echo ".env file already exists"; \
	fi

# Show help
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make build       - Build the application"
	@echo "  make run         - Run the application"
	@echo "  make clean       - Clean build files"
	@echo "  make test        - Run tests"
	@echo "  make deps        - Install dependencies"
	@echo "  make db-setup    - Setup database (run migrations)"
	@echo "  make db-migrate  - Run database migrations"
	@echo "  make db-reset    - Reset database (drop and recreate)"
	@echo "  make fmt         - Format code"
	@echo "  make lint        - Lint code"
	@echo "  make dev         - Run development server with live reload"
	@echo "  make build-prod  - Build for production"
	@echo "  make init        - Initialize project (create .env)"
	@echo "  make help        - Show this help message"

# Default target
.DEFAULT_GOAL := help
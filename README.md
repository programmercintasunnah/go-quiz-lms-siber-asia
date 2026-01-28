Bismillah, API for LMS QUIZ

go-quiz-lms-siber-asia/
├── README.md                      # Dokumentasi utama
├── go.mod                         # Go modules
├── go.sum
├── .env.example                   # Template environment variables
├── .gitignore
│
├── config/                        # Konfigurasi aplikasi
│   └── config.go                  # Database config, app settings
│
├── database/                      # Database files
│   ├── migrations/               # DDL Scripts
│   │   ├── 001_create_tables.sql
│   │   ├── 002_create_stored_procedures.sql
│   │   └── 003_seed_data.sql
│   ├── erd/                      # ERD Diagram
│   │   └── quiz_module_erd.png
│   └── queries/                  # SQL queries untuk reporting
│       └── student_grade_report.sql
│
├── internal/                      # Internal application code
│   ├── models/                   # Data models/entities
│   │   ├── quiz.go
│   │   ├── question.go
│   │   ├── attempt.go
│   │   └── answer.go
│   │
│   ├── repositories/             # Database access layer
│   │   ├── quiz_repository.go
│   │   ├── question_repository.go
│   │   └── attempt_repository.go
│   │
│   ├── services/                 # Business logic
│   │   ├── quiz_service.go
│   │   └── grading_service.go
│   │
│   └── handlers/                 # HTTP handlers (controllers)
│       ├── quiz_handler.go
│       └── attempt_handler.go
│
├── pkg/                          # Shared packages
│   ├── middleware/               # HTTP middlewares
│   │   ├── auth.go
│   │   └── logger.go
│   ├── response/                 # Standard response format
│   │   └── response.go
│   └── validator/                # Input validation
│       └── validator.go
│
├── routes/                       # Route definitions
│   └── routes.go
│
├── docs/                         # Documentation
│   ├── API.md                    # API Documentation
│   ├── DATABASE.md               # Database documentation
│   └── ARCHITECTURE.md           # Architecture explanation
│
└── main.go                       # Application entry point

# Framework & Libraries yang recommended:
- github.com/gin-gonic/gin          # Web framework
- github.com/jmoiron/sqlx           # SQL extensions
- github.com/denisenkom/go-mssqldb  # SQL Server driver
- github.com/joho/godotenv          # Environment variables
- github.com/go-playground/validator/v10  # Validation
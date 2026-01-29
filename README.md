go-quiz-lms-siber-asia/
│
├── cmd/                                    # Main applications
│   └── api/
│       └── main.go                        # Entry point aplikasi
│
├── internal/                               # Private application code
│   ├── app/                               # Application initialization
│   │   ├── app.go                         # App setup & dependency injection
│   │   └── routes.go                      # Route definitions
│   │
│   ├── domain/                            # Domain models (entities)
│   │   ├── quiz.go
│   │   ├── question.go
│   │   ├── attempt.go
│   │   └── answer.go
│   │
│   ├── repository/                        # Data access layer (interface + implementation)
│   │   ├── repository.go                  # Repository interfaces
│   │   ├── quiz_repository.go
│   │   ├── question_repository.go
│   │   └── attempt_repository.go
│   │
│   ├── service/                           # Business logic layer
│   │   ├── service.go                     # Service interfaces
│   │   ├── quiz_service.go
│   │   └── grading_service.go
│   │
│   ├── handler/                           # HTTP handlers (controllers)
│   │   ├── handler.go                     # Handler interfaces/base
│   │   ├── quiz_handler.go
│   │   └── response.go                    # Response helpers
│   │
│   └── middleware/                        # HTTP middlewares
│       ├── cors.go
│       ├── logger.go
│       └── error_handler.go
│
├── pkg/                                    # Public libraries (bisa digunakan project lain)
│   ├── database/                          # Database utilities
│   │   ├── sqlserver.go                   # SQL Server connection
│   │   └── transaction.go                 # Transaction helper
│   │
│   ├── validator/                         # Custom validators
│   │   └── validator.go
│   │
│   └── utils/                             # Utility functions
│       ├── time.go
│       └── string.go
│
├── config/                                 # Configuration
│   ├── config.go                          # Config struct & loader
│   └── database.go                        # Database config
│
├── database/                               # Database files
│   ├── migrations/                        # DDL Scripts
│   │   ├── 001_create_tables.sql
│   │   ├── 002_create_stored_procedures.sql
│   │   └── 003_seed_data.sql
│   │
│   ├── erd/                               # ERD Diagram
│   │   ├── quiz_module_erd.png
│   │   └── quiz_module_erd.drawio
│   │
│   └── queries/                           # SQL queries untuk reporting
│       └── student_grade_report.sql
│
├── docs/                                   # Documentation
│   ├── API.md                             # API Documentation
│   ├── DATABASE.md                        # Database schema documentation
│   ├── ARCHITECTURE.md                    # Architecture explanation
│   └── HYBRID_GRADING_LOGIC.md           # Hybrid grading flow explanation
│
├── scripts/                                # Build & utility scripts
│   ├── setup_db.sh                        # Database setup script
│   └── run_migrations.sh                  # Migration runner
│
├── .env.example                           # Environment variables template
├── .gitignore                             # Git ignore rules
├── go.mod                                 # Go module definition
├── go.sum                                 # Go module checksums
├── Makefile                               # Make commands (optional)
└── README.md                              # Project documentation
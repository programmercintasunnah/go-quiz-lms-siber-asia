#!/bin/bash

# =============================================
# LMS Quiz Module - Database Setup Script
# =============================================

set -e  # Exit on error

echo "=================================="
echo "LMS Quiz Module - Database Setup"
echo "=================================="
echo ""

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✓ Environment variables loaded from .env"
else
    echo "⚠ Warning: .env file not found, using default values"
fi

# Database connection parameters
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-1433}
DB_USER=${DB_USER:-sa}
DB_PASSWORD=${DB_PASSWORD:-YourStrongPassword123!}
DB_NAME=${DB_NAME:-LMS_QuizModule}

# Check if sqlcmd is installed
if ! command -v sqlcmd &> /dev/null; then
    echo "❌ Error: sqlcmd is not installed"
    echo "Please install SQL Server command-line tools:"
    echo "  Ubuntu/Debian: sudo apt-get install mssql-tools"
    echo "  macOS: brew install microsoft/mssql-release/mssql-tools"
    exit 1
fi

echo "Database Configuration:"
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo "  User: $DB_USER"
echo "  Database: $DB_NAME"
echo ""

# Test connection
echo "Testing database connection..."
if sqlcmd -S "$DB_HOST,$DB_PORT" -U "$DB_USER" -P "$DB_PASSWORD" -Q "SELECT @@VERSION" > /dev/null 2>&1; then
    echo "✓ Connection successful"
else
    echo "❌ Error: Cannot connect to database"
    echo "Please check your database credentials in .env file"
    exit 1
fi

echo ""
echo "=================================="
echo "Running Database Migrations"
echo "=================================="
echo ""

# Run migrations
echo "[1/3] Creating database schema..."
if sqlcmd -S "$DB_HOST,$DB_PORT" -U "$DB_USER" -P "$DB_PASSWORD" -i database/migrations/001_create_tables.sql > /dev/null 2>&1; then
    echo "✓ Schema created successfully"
else
    echo "❌ Error: Failed to create schema"
    exit 1
fi

echo ""
echo "[2/3] Creating stored procedures..."
if sqlcmd -S "$DB_HOST,$DB_PORT" -U "$DB_USER" -P "$DB_PASSWORD" -d "$DB_NAME" -i database/migrations/002_create_stored_procedures.sql > /dev/null 2>&1; then
    echo "✓ Stored procedures created successfully"
else
    echo "❌ Error: Failed to create stored procedures"
    exit 1
fi

echo ""
echo "[3/3] Inserting seed data..."
read -p "Do you want to insert sample data? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if sqlcmd -S "$DB_HOST,$DB_PORT" -U "$DB_USER" -P "$DB_PASSWORD" -d "$DB_NAME" -i database/migrations/003_seed_data.sql > /dev/null 2>&1; then
        echo "✓ Seed data inserted successfully"
    else
        echo "⚠ Warning: Failed to insert seed data (this is optional)"
    fi
else
    echo "⊘ Skipped seed data insertion"
fi

echo ""
echo "=================================="
echo "✓ Database Setup Completed!"
echo "=================================="
echo ""
echo "Next steps:"
echo "1. Update .env file with your database credentials"
echo "2. Run: go run cmd/api/main.go"
echo ""
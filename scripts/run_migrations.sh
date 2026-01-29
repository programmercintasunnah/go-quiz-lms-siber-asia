#!/bin/bash

# =============================================
# LMS Quiz Module - Run Migrations
# =============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=================================="
echo "LMS Quiz Module - Run Migrations"
echo -e "==================================${NC}"
echo ""

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo -e "${RED}Error: .env file not found${NC}"
    exit 1
fi

# Database connection
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-1433}
DB_USER=${DB_USER:-sa}
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=${DB_NAME:-LMS_QuizModule}

# Check if sqlcmd exists
if ! command -v sqlcmd &> /dev/null; then
    echo -e "${RED}Error: sqlcmd not found${NC}"
    exit 1
fi

# Migration directory
MIGRATION_DIR="database/migrations"

# Check if migration directory exists
if [ ! -d "$MIGRATION_DIR" ]; then
    echo -e "${RED}Error: Migration directory not found: $MIGRATION_DIR${NC}"
    exit 1
fi

# Get all SQL files sorted
MIGRATIONS=$(ls $MIGRATION_DIR/*.sql 2>/dev/null | sort)

if [ -z "$MIGRATIONS" ]; then
    echo -e "${YELLOW}No migration files found${NC}"
    exit 0
fi

echo "Found migrations:"
echo "$MIGRATIONS" | nl
echo ""

# Run each migration
for migration in $MIGRATIONS; do
    filename=$(basename "$migration")
    echo -n "Running $filename... "
    
    if sqlcmd -S "$DB_HOST,$DB_PORT" -U "$DB_USER" -P "$DB_PASSWORD" -d "$DB_NAME" -i "$migration" -b > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo -e "${RED}Error: Migration failed: $filename${NC}"
        exit 1
    fi
done

echo ""
echo -e "${GREEN}All migrations completed successfully!${NC}"
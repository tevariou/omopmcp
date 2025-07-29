#!/bin/bash
# Script to create a pg_dump using a PostgreSQL container

set -e

echo "🚀 Creating pg_dump using PostgreSQL container..."

# Configuration
DB_HOST="omop_postgres"  # Container name in the omopmcp_default network
DB_PORT="5432"
DB_NAME="omop"
DB_USER="omop_user"
DB_PASSWORD="omop_password"
DUMP_FILE="omop_dump.sql"

# Check if dump file already exists
if [ -f "$DUMP_FILE.gz" ]; then
    echo "⚠️  Found existing dump file: $DUMP_FILE.gz"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Aborted."
        exit 1
    fi
fi

echo "📦 Creating pg_dump using PostgreSQL container..."

# Run pg_dump using a PostgreSQL container
docker run --rm \
    --network omopmcp_default \
    -e PGPASSWORD="$DB_PASSWORD" \
    -v "$(pwd):/backup" \
    postgres:15 \
    pg_dump \
        --host="$DB_HOST" \
        --port="$DB_PORT" \
        --username="$DB_USER" \
        --dbname="$DB_NAME" \
        --verbose \
        --clean \
        --if-exists \
        --create \
        --no-owner \
        --no-privileges \
        --schema=omop \
        --schema=public \
        --file="/backup/$DUMP_FILE"

if [ $? -eq 0 ]; then
    echo "✅ pg_dump completed: $DUMP_FILE"
    echo "📁 Size: $(du -h "$DUMP_FILE" | cut -f1)"

    # Create compressed version
    gzip "$DUMP_FILE"
    echo "🗜️  Compressed: ${DUMP_FILE}.gz"
    echo "📁 Compressed size: $(du -h "${DUMP_FILE}.gz" | cut -f1)"

    echo ""
    echo "🎉 Dump created successfully!"
    echo "📄 File: ${DUMP_FILE}.gz"
    echo "💡 You can now use this with Dockerfile.postgres"
else
    echo "❌ pg_dump failed!"
    exit 1
fi 
#!/bin/bash
set -e

# Function to run SQL commands
run_sql() {
    docker exec postgres-test psql -U postgres -d postgres -t -A -c "$1"
}

retry_sql() {
    local sql="$1"
    local attempts=5
    local delay=2
    local output=""
    local status=1
    for ((i=1; i<=attempts; i++)); do
        output=$(run_sql "$sql" 2>/dev/null)
        status=$?
        if [ $status -eq 0 ]; then
            echo "$output"
            return 0
        fi
        echo "Retrying SQL (attempt ${i}/${attempts})..."
        sleep "$delay"
    done
    return $status
}

# Wait for PostgreSQL to be ready
wait_for_postgres() {
    echo "Waiting for PostgreSQL to be ready..."
    for i in {1..30}; do
        if docker exec postgres-test pg_isready -U postgres > /dev/null 2>&1; then
            echo "PostgreSQL is ready!"
            return 0
        fi
        sleep 1
    done
    echo "PostgreSQL did not become ready in time"
    return 1
}

echo "Starting PostgreSQL container..."
docker run -d --name postgres-test \
    -e POSTGRES_PASSWORD=postgres \
    postgres-cloudsql-docker:test

# Wait for PostgreSQL to be ready
wait_for_postgres

echo "Testing pg_cron installation..."

# Verify configuration
echo "Checking PostgreSQL configuration..."
run_sql "SHOW shared_preload_libraries;"
run_sql "SHOW cron.database_name;"
run_sql "SHOW cron.use_background_workers;"
run_sql "SHOW max_worker_processes;"

# Creating extension pg_cron
echo "Installing pg_cron extension..."
run_sql "CREATE EXTENSION pg_cron;"

# Verify extension
echo "Checking pg_cron extension..."
if ! run_sql "SELECT extname, extversion FROM pg_extension WHERE extname = 'pg_cron';" | grep -q "pg_cron"; then
    echo " pg_cron extension is not installed"
    exit 1
fi
echo " pg_cron extension is installed"

# Verify cron schema and permissions
echo "Checking cron schema..."
if ! run_sql "\dn" | grep -q "cron"; then
    echo " cron schema does not exist"
    exit 1
fi
echo " cron schema exists"

echo "Testing pg_cron functionality..."
if ! output=$(retry_sql "SELECT proname FROM pg_proc WHERE pronamespace = 'cron'::regnamespace AND proname IN ('schedule','schedule_in_database');"); then
    echo " Failed to query pg_cron functions"
    exit 1
fi
if ! echo "$output" | grep -q "schedule"; then
    echo " pg_cron schedule functions are missing"
    exit 1
fi
echo " pg_cron functions are available"

# Cleanup
echo "Cleaning up..."
docker stop postgres-test
docker rm postgres-test

echo "All tests passed! "

#!/bin/bash
set -e

run_sql() {
    docker exec postgres-test psql -U postgres -d postgres -t -A -c "$1"
}

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

wait_for_postgres

echo "Testing pg_trgm installation..."
run_sql "CREATE EXTENSION pg_trgm;"

if ! run_sql "SELECT extname FROM pg_extension WHERE extname = 'pg_trgm';" | grep -q "pg_trgm"; then
    echo " pg_trgm extension is not installed"
    exit 1
fi

if ! run_sql "SELECT 'food' % 'fool';" | grep -q "t"; then
    echo " pg_trgm similarity operator test failed"
    exit 1
fi

echo " pg_trgm extension is installed and responsive"

echo "Cleaning up..."
docker stop postgres-test
docker rm postgres-test

echo "All tests passed!"

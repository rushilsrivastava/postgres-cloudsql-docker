#!/bin/bash
set -e

# Check if a test script was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <test_script|all>"
    echo "Example: $0 tests/test_pg_cron.sh"
    echo "Example: $0 all"
    exit 1
fi

TEST_SCRIPT=$1

if [ "$TEST_SCRIPT" = "all" ]; then
    shopt -s nullglob
    TEST_FILES=(tests/test_*.sh)
    shopt -u nullglob
    if [ ${#TEST_FILES[@]} -eq 0 ]; then
        echo "No test files found under tests/test_*.sh"
        exit 1
    fi
else
    if [ ! -f "$TEST_SCRIPT" ]; then
        echo "Test script $TEST_SCRIPT not found!"
        exit 1
    fi
    TEST_FILES=("$TEST_SCRIPT")
fi

# Default versions (matching the workflow defaults)
PG_VERSION=${PG_VERSION:-15}
POSTGIS_VERSION=${POSTGIS_VERSION:-3.5}
HLL_VERSION=${HLL_VERSION:-2.18}

# Function to clean up
cleanup() {
    echo "Cleaning up..."
    docker rmi -f postgres-cloudsql-docker:test >/dev/null 2>&1 || true
    docker rm -f postgres-test >/dev/null 2>&1 || true
}

# Ensure cleanup happens even on error
trap cleanup EXIT

echo "Building test image..."
docker build \
    --platform=${DOCKER_BUILD_PLATFORM:-linux/amd64} \
    --build-arg PG_VERSION=${PG_VERSION} \
    --build-arg POSTGIS_VERSION=${POSTGIS_VERSION} \
    --build-arg HLL_VERSION=${HLL_VERSION} \
    -t postgres-cloudsql-docker:test .

# Make the test scripts executable
chmod +x "${TEST_FILES[@]}"

for test_file in "${TEST_FILES[@]}"; do
    echo "Running test: $test_file"
    "./$test_file"
done

# The cleanup will happen automatically due to the trap

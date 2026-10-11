#!/usr/bin/env sh

# Synopsis:
# Test the test runner Docker image by running it against the example solutions
# of all the exercises in a checkout of the idris track repo.
# The test runner Docker image is built automatically.

# Arguments:
# $1: path to the idris track repo

# Output:
# Outputs each exercise's test status, and fails if any example solution
# doesn't pass its tests.

# Example:
# ./bin/run-all-exercises-in-docker.sh path/to/idris/

# Stop executing when a command returns a non-zero return code
set -e

# If the required argument is missing, print the usage and exit
if [ -z "$1" ]; then
    echo "usage: ./bin/run-all-exercises-in-docker.sh path/to/idris/"
    exit 1
fi

idris_repo_dir=$(realpath "${1%/}")

# Build the Docker image
docker build --rm -t exercism/idris-test-runner .

# Run the track's verification script against the image we just built
cd "${idris_repo_dir}"
bin/verify-exercises-in-docker -i exercism/idris-test-runner

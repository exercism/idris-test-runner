#!/usr/bin/env sh

# Synopsis:
# Run the test runner on a solution.

# Arguments:
# $1: exercise slug
# $2: path to solution folder
# $3: path to output directory

# Output:
# Writes the test results to a results.json file in the passed-in output directory.
# The test results are formatted according to the specifications at https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md

# Example:
# ./bin/run.sh two-fer path/to/solution/folder/ path/to/output/directory/

# If any required arguments is missing, print the usage and exit
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "usage: ./bin/run.sh exercise-slug path/to/solution/folder/ path/to/output/directory/"
    exit 1
fi

slug="$1"
solution_dir=$(realpath "${2%/}")
output_dir=$(realpath "${3%/}")
results_file="${output_dir}/results.json"

# Create the output directory if it doesn't exist
mkdir -p "${output_dir}"

echo "${slug}: testing..."

# Each pack command spends over a second loading its package collection before
# it starts idris2. bin/idris2-env.sh sets the paths pack would pass to idris2,
# so the runner calls idris2 and the test executable directly.
. /opt/test-runner/bin/idris2-env.sh
package=$(cd "${solution_dir}"; basename *.ipkg .ipkg)

# The test package depends on the solution's package. Linking the solution's
# build folder into a temporary package directory lets idris2 find it without
# installing it.
packages_dir=$(mktemp -d)
trap 'rm -rf "${output_dir}/build" "${output_dir}/test" "${packages_dir}"' EXIT
ln -s "${solution_dir}/build/ttc" "${packages_dir}/${package}-0"
export IDRIS2_PACKAGE_PATH="${IDRIS2_PACKAGE_PATH}:${packages_dir}"

build_output=$(cd "${solution_dir}" && idris2 --build "${package}.ipkg" 2>&1 && cd test && idris2 --build test.ipkg 2>&1)

if [ $? -ne 0 ]; then
  sanitized_build_output=$(printf '%s' "${build_output}" | sed '/1\/1:/d')

  jq -n --arg output "${sanitized_build_output}" '{version: 1, status: "error", message: $output}' > ${results_file}
  echo "${slug}: done"
  exit 0
fi
# Run the tests for the provided implementation file and redirect stdout and
# sterr to capture it
test_output=$(cd "${solution_dir}"; test/build/exec/"${package}"-test 2>&1)

# Write the results.json file based on the exit code of the command that was 
# just executed that tested the implementation file
if [ $? -eq 0 ]; then
    jq -n '{version: 1, status: "pass"}' > ${results_file}
else
    # OPTIONAL: Sanitize the output
    # In some cases, the test output might be overly verbose, in which case stripping
    # the unneeded information can be very helpful to the student
    sanitized_test_output=$(printf '%s' "${test_output}")
    # OPTIONAL: Manually add colors to the output to help scanning the output for errors
    # If the test output does not contain colors to help identify failing (or passing)
    # tests, it can be helpful to manually add colors to the output
    # colorized_test_output=$(echo "${test_output}" \
    #      | GREP_COLOR='01;31' grep --color=always -E -e '^(ERROR:.*|.*failed)$|$' \
    #      | GREP_COLOR='01;32' grep --color=always -E -e '^.*passed$|$')

    jq -n --arg output "${sanitized_test_output}" '{version: 1, status: "fail", message: $output}' > ${results_file}
fi

echo "${slug}: done"

#!/bin/bash

_SUCCESSFUL_TEST_COUNT=0

function console_results::render_result() {
  if [[ "$(state::is_duplicated_test_functions_found)" == true ]]; then
    console_results::print_execution_time
    printf "%s%s%s\n" "${_COLOR_RETURN_ERROR}" "Duplicate test functions found" "${_COLOR_DEFAULT}"
    printf "File with duplicate functions: %s\n" "$(state::get_file_with_duplicated_function_names)"
    printf "Duplicate functions: %s\n" "$(state::get_duplicated_function_names)"
    return 1
  fi

  echo ""

  local total_tests=0
  ((total_tests += $(state::get_tests_passed))) || true
  ((total_tests += $(state::get_tests_skipped))) || true
  ((total_tests += $(state::get_tests_incomplete))) || true
  ((total_tests += $(state::get_tests_snapshot))) || true
  ((total_tests += $(state::get_tests_failed))) || true

  local total_assertions=0
  ((total_assertions += $(state::get_assertions_passed))) || true
  ((total_assertions += $(state::get_assertions_skipped))) || true
  ((total_assertions += $(state::get_assertions_incomplete))) || true
  ((total_assertions += $(state::get_assertions_snapshot))) || true
  ((total_assertions += $(state::get_assertions_failed))) || true

  printf "%sTests:     %s" "$_COLOR_FAINT" "$_COLOR_DEFAULT"
  if [[ "$(state::get_tests_passed)" -gt 0 ]] || [[ "$(state::get_assertions_passed)" -gt 0 ]]; then
    printf " %s%s passed%s," "$_COLOR_PASSED" "$(state::get_tests_passed)" "$_COLOR_DEFAULT"
  fi
  if [[ "$(state::get_tests_skipped)" -gt 0 ]] || [[ "$(state::get_assertions_skipped)" -gt 0 ]]; then
    printf " %s%s skipped%s," "$_COLOR_SKIPPED" "$(state::get_tests_skipped)" "$_COLOR_DEFAULT"
  fi
  if [[ "$(state::get_tests_incomplete)" -gt 0 ]] || [[ "$(state::get_assertions_incomplete)" -gt 0 ]]; then
    printf " %s%s incomplete%s," "$_COLOR_INCOMPLETE" "$(state::get_tests_incomplete)" "$_COLOR_DEFAULT"
  fi
  if [[ "$(state::get_tests_snapshot)" -gt 0 ]] || [[ "$(state::get_assertions_snapshot)" -gt 0 ]]; then
    printf " %s%s snapshot%s," "$_COLOR_SNAPSHOT" "$(state::get_tests_snapshot)" "$_COLOR_DEFAULT"
  fi
  if [[ "$(state::get_tests_failed)" -gt 0 ]] || [[ "$(state::get_assertions_failed)" -gt 0 ]]; then
    printf " %s%s failed%s," "$_COLOR_FAILED" "$(state::get_tests_failed)" "$_COLOR_DEFAULT"
  fi
  printf " %s total\n" "$total_tests"

  printf "%sAssertions:%s" "$_COLOR_FAINT" "$_COLOR_DEFAULT"
  if [[ "$(state::get_tests_passed)" -gt 0 ]] || [[ "$(state::get_assertions_passed)" -gt 0 ]]; then
      printf " %s%s passed%s," "$_COLOR_PASSED" "$(state::get_assertions_passed)" "$_COLOR_DEFAULT"
  fi
  if [[ "$(state::get_tests_skipped)" -gt 0 ]] || [[ "$(state::get_assertions_skipped)" -gt 0 ]]; then
    printf " %s%s skipped%s," "$_COLOR_SKIPPED" "$(state::get_assertions_skipped)" "$_COLOR_DEFAULT"
  fi
  if [[ "$(state::get_tests_incomplete)" -gt 0 ]] || [[ "$(state::get_assertions_incomplete)" -gt 0 ]]; then
    printf " %s%s incomplete%s," "$_COLOR_INCOMPLETE" "$(state::get_assertions_incomplete)" "$_COLOR_DEFAULT"
  fi
  if [[ "$(state::get_tests_snapshot)" -gt 0 ]] || [[ "$(state::get_assertions_snapshot)" -gt 0 ]]; then
    printf " %s%s snapshot%s," "$_COLOR_SNAPSHOT" "$(state::get_assertions_snapshot)" "$_COLOR_DEFAULT"
  fi
  if [[ "$(state::get_tests_failed)" -gt 0 ]] || [[ "$(state::get_assertions_failed)" -gt 0 ]]; then
    printf " %s%s failed%s," "$_COLOR_FAILED" "$(state::get_assertions_failed)" "$_COLOR_DEFAULT"
  fi
  printf " %s total\n" "$total_assertions"

  if [[ "$(state::get_tests_failed)" -gt 0 ]]; then
    printf "\n%s%s%s\n" "$_COLOR_RETURN_ERROR" " Some tests failed " "$_COLOR_DEFAULT"
    console_results::print_execution_time
    return 1
  fi

  if [[ "$(state::get_tests_incomplete)" -gt 0 ]]; then
    printf "\n%s%s%s\n" "$_COLOR_RETURN_INCOMPLETE" " Some tests incomplete " "$_COLOR_DEFAULT"
    console_results::print_execution_time
    return 0
  fi

  if [[ "$(state::get_tests_skipped)" -gt 0 ]]; then
    printf "\n%s%s%s\n" "$_COLOR_RETURN_SKIPPED" " Some tests skipped " "$_COLOR_DEFAULT"
    console_results::print_execution_time
    return 0
  fi

  if [[ "$(state::get_tests_snapshot)" -gt 0 ]]; then
    printf "\n%s%s%s\n" "$_COLOR_RETURN_SNAPSHOT" " Some snapshots created " "$_COLOR_DEFAULT"
    console_results::print_execution_time
    return 0
  fi

  if [[ $total_tests -eq 0 ]]; then
    printf "\n%s%s%s\n" "$_COLOR_RETURN_ERROR" " No tests found " "$_COLOR_DEFAULT"
    console_results::print_execution_time
    return 1
  fi

  printf "\n%s%s%s\n" "$_COLOR_RETURN_SUCCESS" " All tests passed " "$_COLOR_DEFAULT"
  console_results::print_execution_time
  return 0
}

function console_results::print_execution_time() {
  if [[ $BASHUNIT_SHOW_EXECUTION_TIME == false ]]; then
    return
  fi

  _EXECUTION_TIME=$(clock::total_runtime_in_milliseconds)
  printf "${_COLOR_BOLD}%s${_COLOR_DEFAULT}\n" "Time taken: ${_EXECUTION_TIME} ms"
}

function console_results::print_successful_test() {
  ((_SUCCESSFUL_TEST_COUNT++)) || true

  if [[ "$BASHUNIT_SIMPLE_OUTPUT" == true ]]; then
    if (( _SUCCESSFUL_TEST_COUNT % 50 != 0 )); then
      printf "."
    else
      echo "."
    fi
  else
    local test_name=$1
    shift
    local duration=${1:-"0"}
    shift

    local line
    if [[ -z "$*" ]]; then
      line=$(printf "%s✓ Passed%s: %s" "$_COLOR_PASSED" "$_COLOR_DEFAULT" "$test_name")
    else
      line=$(printf "%s✓ Passed%s: %s (%s)" "$_COLOR_PASSED" "$_COLOR_DEFAULT" "$test_name" "$*")
    fi

    local full_line=$line
    if [[ $BASHUNIT_SHOW_EXECUTION_TIME == true ]]; then
      full_line="$(printf "%s\n" "$(str::rpad "$line" "($duration ms)")")"
    fi

    console_results::print_line "successful" "$full_line"
  fi
}

function console_results::print_failure_message() {
  local test_name=$1
  local failure_message=$2

  local line
  line="$(printf "\
${_COLOR_FAILED}✗ Failed${_COLOR_DEFAULT}: %s
    ${_COLOR_FAINT}Message:${_COLOR_DEFAULT} ${_COLOR_BOLD}'%s'${_COLOR_DEFAULT}\n"\
    "${test_name}" "${failure_message}")"

    console_results::print_line "failure" "$line"
}

function console_results::print_failed_test() {
  local test_name=$1
  local expected=$2
  local failure_condition_message=$3
  local actual=$4
  local extra_key=${5-}
  local extra_value=${6-}

  local line
  line="$(printf "\
${_COLOR_FAILED}✗ Failed${_COLOR_DEFAULT}: %s
    ${_COLOR_FAINT}Expected${_COLOR_DEFAULT} ${_COLOR_BOLD}'%s'${_COLOR_DEFAULT}
    ${_COLOR_FAINT}%s${_COLOR_DEFAULT} ${_COLOR_BOLD}'%s'${_COLOR_DEFAULT}\n" \
    "${test_name}" "${expected}" "${failure_condition_message}" "${actual}")"

  if [ -n "$extra_key" ]; then
    line+="$(printf "\
    ${_COLOR_FAINT}%s${_COLOR_DEFAULT} ${_COLOR_BOLD}'%s'${_COLOR_DEFAULT}\n" \
    "${extra_key}" "${extra_value}")"
  fi

  console_results::print_line "failed" "$line"
}


function console_results::print_failed_snapshot_test() {
  local test_name=$1
  local snapshot_file=$2

  local line
  line="$(printf "${_COLOR_FAILED}✗ Failed${_COLOR_DEFAULT}: %s
    ${_COLOR_FAINT}Expected to match the snapshot${_COLOR_DEFAULT}\n" "$test_name")"

  if command -v git > /dev/null; then
    local actual_file="${snapshot_file}.tmp"
    echo "$actual" > "$actual_file"

    local git_diff_output
    git_diff_output="$(git diff --no-index --word-diff --color=always \
      "$snapshot_file" "$actual_file" 2>/dev/null \
        | tail -n +6 | sed "s/^/    /")"

    line+="$git_diff_output"
    rm "$actual_file"
  fi

  console_results::print_line "" "$line"
}

function console_results::print_skipped_test() {
  local test_name=$1
  local reason=${2-}

  local line
  line="$(printf "${_COLOR_SKIPPED}↷ Skipped${_COLOR_DEFAULT}: %s\n" "${test_name}")"

  if [[ -n "$reason" ]]; then
    line+="$(printf "${_COLOR_FAINT}    %s${_COLOR_DEFAULT}\n" "${reason}")"
  fi

  console_results::print_line "skipped" "$line"
}

function console_results::print_incomplete_test() {
  local test_name=$1
  local pending=${2-}

  local line
  line="$(printf "${_COLOR_INCOMPLETE}✒ Incomplete${_COLOR_DEFAULT}: %s\n" "${test_name}")"

  if [[ -n "$pending" ]]; then
    line+="$(printf "${_COLOR_FAINT}    %s${_COLOR_DEFAULT}\n" "${pending}")"
  fi

  console_results::print_line "incomplete" "$line"
}

function console_results::print_snapshot_test() {
  local test_name
  test_name=$(helper::normalize_test_function_name "$1")

  local line
  line="$(printf "${_COLOR_SNAPSHOT}✎ Snapshot${_COLOR_DEFAULT}: %s\n" "${test_name}")"

  console_results::print_line "snapshot" "$line"
}

function console_results::print_error_test() {
  local test_name
  test_name=$(helper::normalize_test_function_name "$1")
  local error="$2"

  local line
  line="$(printf "${_COLOR_FAILED}✗ Failed${_COLOR_DEFAULT}: %s
    ${_COLOR_FAINT}%s${_COLOR_DEFAULT}\n" "${test_name}" "${error}")"

  console_results::print_line "error" "$line"
}

function console_results::print_line() {
  # shellcheck disable=SC2034
  local type=$1
  local line=$2
  printf "%s\n" "$line"
}

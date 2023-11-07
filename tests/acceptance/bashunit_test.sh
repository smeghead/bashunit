#!/bin/bash

function set_up_before_script() {
  TEST_ENV_FILE="tests/acceptance/fixtures/.env.default"
  TEST_ENV_FILE_SIMPLE="tests/acceptance/fixtures/.env.simple"
  TEST_ENV_FILE_WITH_PATH="tests/acceptance/fixtures/.env.with_path"
}

function test_bashunit_without_path_env_nor_argument() {
  assert_match_snapshot "$(./bashunit --env "$TEST_ENV_FILE")"
  assert_general_error "$(./bashunit --env "$TEST_ENV_FILE")"
}

function test_bashunit_with_argument_path() {
  todo "Here it is supposed to search for files ending in test, this functionality has recently stopped working"
  return

  assert_match_snapshot "$(./bashunit tests/acceptance/fixtures/tests_path --env "$TEST_ENV_FILE")"
  assert_general_error "$(./bashunit tests/acceptance/fixtures/tests_path --env "$TEST_ENV_FILE")"
}

function test_bashunit_with_env_default_path() {
  assert_match_snapshot "$(./bashunit --env "$TEST_ENV_FILE_WITH_PATH")"
  assert_successful_code "$(./bashunit --env "$TEST_ENV_FILE_WITH_PATH")"
}

function test_bashunit_when_a_test_passes_verbose_output() {
  local test_file=./tests/acceptance/fixtures/test_bashunit_when_a_test_passes.sh

  local snapshot
  snapshot="$(./bashunit --env "$TEST_ENV_FILE" "$test_file")"
  local code=$?

  assert_match_snapshot "$snapshot"
  assert_successful_code "$code"
}

function test_bashunit_when_a_test_passes_simple_output_env() {
  local test_file=./tests/acceptance/fixtures/test_bashunit_when_a_test_passes.sh

  local snapshot
  snapshot="$(./bashunit --env "$TEST_ENV_FILE_SIMPLE" "$test_file")"
  local code=$?

  assert_match_snapshot "$snapshot"
  assert_successful_code "$code"
}

function test_bashunit_when_a_test_passes_simple_output_option() {
  local test_file=./tests/acceptance/fixtures/test_bashunit_when_a_test_passes.sh

  local snapshot
  snapshot="$(./bashunit --env "$TEST_ENV_FILE" "$test_file" --simple)"
  local code=$?

  assert_match_snapshot "$snapshot"
  assert_successful_code "$code"
}

function test_bashunit_when_a_test_fail() {
  local test_file=./tests/acceptance/fake_fail_test.sh
  fixture=$(printf "Running ./tests/acceptance/fake_fail_test.sh
\e[31m✗ Failed\e[0m: Fail
    \e[2mExpected\e[0m \e[1m\'1\'\e[0m
    \e[2mbut got\e[0m \e[1m\'0\'\e[0m

\e[2mTests:     \e[0m \e[31m1 failed\e[0m, 1 total
\e[2mAssertions:\e[0m \e[31m1 failed\e[0m, 1 total")

  echo "
#!/bin/bash
function test_fail() { assert_equals \"1\" \"0\" ; }" > $test_file

  assert_contains "$fixture" "$(./bashunit --env "$TEST_ENV_FILE" "$test_file")"
  assert_general_error "$(./bashunit --env "$TEST_ENV_FILE" "$test_file")"

  rm $test_file
}

function test_bashunit_when_a_test_execution_error() {
  local test_file=./tests/acceptance/fake_error_test.sh
  local fixture_start
  fixture_start=$(printf "Running ./tests/acceptance/fake_error_test.sh
\e[31m✗ Failed\e[0m: Error
    \e[2mExpected\e[0m \e[1m\'127\'\e[0m
    \e[2mto be exactly\e[0m \e[1m\'1\'\e[0m
\e[31m✗ Failed\e[0m: Error
    \e[2m./tests/acceptance/fake_error_test.sh:")
  local fixture_end
  fixture_end=$(printf "\e[0m

\e[2mTests:     \e[0m \e[31m1 failed\e[0m, 1 total
\e[2mAssertions:\e[0m \e[31m1 failed\e[0m, 1 total")

  echo "
#!/bin/bash
function test_error() {
  invalid_function_name
  assert_general_error
}" > $test_file

  set +e

  assert_contains "$fixture_start" "$(./bashunit --env "$TEST_ENV_FILE" "$test_file")"
  assert_contains "$fixture_end" "$(./bashunit --env "$TEST_ENV_FILE" "$test_file")"
  assert_general_error "$(./bashunit --env "$TEST_ENV_FILE" "$test_file")"

  rm $test_file
}

function test_bashunit_should_allow_test_drive_development() {
  local test_file=./tests/acceptance/fake_error_test.sh
  local fixture_start
  fixture_start=$(printf "Running ./tests/acceptance/fake_error_test.sh
\e[31m✗ Failed\e[0m: Error tdd
    \e[2m./tests/acceptance/fake_error_test.sh:")
  local fixture_end
  fixture_end=$(printf "\e[0m

\e[2mTests:     \e[0m \e[31m1 failed\e[0m, 1 total
\e[2mAssertions:\e[0m \e[31m0 failed\e[0m, 0 total")

  echo "
  #!/bin/bash
  function test_error_tdd() { assert_that_will_never_exist \"1\" \"1\" ; }" > $test_file

  set +e

  assert_contains "$fixture_start" "$(./bashunit --env "$TEST_ENV_FILE" "$test_file")"
  assert_contains "$fixture_end" "$(./bashunit --env "$TEST_ENV_FILE" "$test_file")"
  assert_general_error "$(./bashunit --env "$TEST_ENV_FILE" "$test_file")"

  rm $test_file
}

function test_bashunit_should_display_version() {
  local fixture
  fixture=$(printf "%s" "$BASHUNIT_VERSION")

  assert_contains "$fixture" "$(./bashunit --version)"
}

function test_bashunit_when_stop_on_failure() {
  local test_file=./tests/acceptance/fixtures/stop_on_failure.sh
  local expected_output
  expected_output=$(printf "Running %s
\e[32m✓ Passed\e[0m: A success
\e[31m✗ Failed\e[0m: B error
    \e[2mExpected\e[0m \e[1m\'1\'\e[0m
    \e[2mbut got\e[0m \e[1m\'2\'\e[0m" "$test_file")

  assert_contains "$expected_output" "$(./bashunit --env "$TEST_ENV_FILE" --stop-on-failure "$test_file")"
}

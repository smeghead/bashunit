#!/bin/bash

function set_up() {
  ./build.sh >/dev/null
}

function tear_down() {
  rm -f ./bin/bashunit
}

function test_bashunit_upgrade_on_latest() {
  local output
  output="$(./bin/bashunit --upgrade)"

  assert_equals "> You are already on latest release" "$output"
}

function test_fake_bashunit_upgrade() {
  sed -i -e \
    's/declare -r BASHUNIT_VERSION="[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}"/declare -r BASHUNIT_VERSION="0.1.0"/' \
    ./bin/bashunit

  if [[ $_OS == "OSX" ]]; then
    rm ./bin/bashunit-e
  fi

  local output
  output="$(./bin/bashunit --upgrade)"

  assert_contains "> Upgrading bashunit to latest release" "$output"
  assert_contains "> bashunit upgraded successfully to latest version" "$output"
}

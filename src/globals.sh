#!/bin/bash
set -euo pipefail

# This file provides a set of global functions to developers.

function current_dir() {
  dirname "${BASH_SOURCE[1]}"
}

function current_filename() {
  basename "${BASH_SOURCE[1]}"
}

function current_timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

function is_command_available() {
  command -v "$1" >/dev/null 2>&1
}

function random_str() {
  local length=${1:-6}
  LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c "$length"
}

function temp_file() {
  # shellcheck disable=SC2155
  local path="/tmp/bashunit_temp.$(random_str)"
  touch "$path"
  echo "$path"
}

function temp_dir() {
  # shellcheck disable=SC2155
  local dir="/tmp/bashunit_tempdir.$(random_str 5)}"
  mkdir -p "$dir"
  echo "$dir"
}

function cleanup_temp_files() {
  rm -rf /tmp/bashunit_temp*
}

function log_info() {
  # shellcheck disable=SC2145
  echo "$(current_timestamp) [INFO]: $@" >> "$BASHUNIT_LOG_PATH"
}

function log_error() {
  # shellcheck disable=SC2145
  echo "$(current_timestamp) [ERROR]: $@" >> "$BASHUNIT_LOG_PATH"
}

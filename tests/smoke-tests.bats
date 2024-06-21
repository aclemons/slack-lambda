#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

get_value() {
  curl -f -s --data '{"key":"val"}' --header "Content-Type: application/json" --header "Accept: application/json" "http://localhost:$1/2015-03-31/functions/function/invocations" | jq -r ".key"
}

@test "x86-64 stable image echoes its input" {
  run -0 get_value "9001"
  [ "${lines[0]}" = "val" ] || { printf "%s\n" "$output" && false ; }
}

@test "x86-64 current image echoes its input" {
  run -0 get_value "9002"
  [ "${lines[0]}" = "val" ] || { printf "%s\n" "$output" && false ; }
}

@test "aarch64 current image echoes its input" {
  run -0 get_value "9003"
  [ "${lines[0]}" = "val" ] || { printf "%s\n" "$output" && false ; }
}

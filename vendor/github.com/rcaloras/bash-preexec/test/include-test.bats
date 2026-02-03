#!/usr/bin/env bats

@test "should not import if it's already defined" {
  # shellcheck disable=SC2034,SC2030
  bash_preexec_imported="defined"
  # shellcheck source=vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh
  source "${BATS_TEST_DIRNAME}/../bash-preexec.sh"
  [ -z "$(type -t __bp_install)" ]
}

@test "should not import if it's already defined (old guard, don't use elsewhere!)" {
  # shellcheck disable=SC2030
  __bp_imported="defined"
  # shellcheck source=vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh
  source "${BATS_TEST_DIRNAME}/../bash-preexec.sh"
  [ -z "$(type -t __bp_install)" ]
}

@test "should import if not defined" {
  unset bash_preexec_imported
  # shellcheck source=vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh
  source "${BATS_TEST_DIRNAME}/../bash-preexec.sh"
  [ -n "$(type -t __bp_install)" ]
}

@test "bp should stop installation if HISTTIMEFORMAT is readonly" {
  readonly HISTTIMEFORMAT
  # shellcheck source=vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh
  run source "${BATS_TEST_DIRNAME}/../bash-preexec.sh"
  [ $status -ne 0 ]
  [[ "$output" =~ "HISTTIMEFORMAT" ]] || return 1
}

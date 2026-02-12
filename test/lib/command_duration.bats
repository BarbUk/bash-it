# shellcheck shell=bats
# shellcheck disable=2034,2329

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "command_duration"
}

@test "command_duration: _command_duration_current_time" {
	run _command_duration_current_time
	assert_success
	assert_output --regexp '^[0-9]+(\.[0-9]+)?$'
}

@test "command_duration: _command_duration_current_time without EPOCHREALTIME" {
	_command_duration_current_time_no_epoch() {
		local EPOCHREALTIME
		unset EPOCHREALTIME
		local SECONDS=123
		_command_duration_current_time
	}
	run _command_duration_current_time_no_epoch
	assert_success
	assert_output "123"
}

@test "command_duration: _command_duration_pre_exec" {
	_command_duration_pre_exec
	assert [ -n "$COMMAND_DURATION_START_SECONDS" ]
}

@test "command_duration: _command_duration_pre_cmd" {
	COMMAND_DURATION_START_SECONDS="1234.567"
	_command_duration_pre_cmd
	assert [ -z "$COMMAND_DURATION_START_SECONDS" ]
}

@test "command_duration: _dynamic_clock_icon" {
	_dynamic_clock_icon 1
	assert [ -n "$COMMAND_DURATION_ICON" ]
}

@test "command_duration: _command_duration disabled" {
	unset BASH_IT_COMMAND_DURATION
	COMMAND_DURATION_START_SECONDS="100"
	run _command_duration
	assert_output ""
}

@test "command_duration: _command_duration no start time" {
	BASH_IT_COMMAND_DURATION=true
	unset COMMAND_DURATION_START_SECONDS
	run _command_duration
	assert_output ""
}

@test "command_duration: _command_duration below threshold" {
	BASH_IT_COMMAND_DURATION=true
	COMMAND_DURATION_MIN_SECONDS=2
	# Mock _command_duration_current_time
	_command_duration_current_time() { echo 101; }
	COMMAND_DURATION_START_SECONDS=100
	run _command_duration
	assert_output ""
}

@test "command_duration: _command_duration above threshold (seconds)" {
	BASH_IT_COMMAND_DURATION=true
	COMMAND_DURATION_MIN_SECONDS=1
	COMMAND_DURATION_PRECISION=0
	# Mock _command_duration_current_time
	_command_duration_current_time() { echo 105; }
	COMMAND_DURATION_START_SECONDS=100
	run _command_duration
	assert_output --regexp ".* 5s$"
}

@test "command_duration: _command_duration precision 0 with microseconds time" {
	BASH_IT_COMMAND_DURATION=true
	COMMAND_DURATION_MIN_SECONDS=1
	COMMAND_DURATION_PRECISION=0
	# Mock _command_duration_current_time
	_command_duration_current_time() { echo 105.600005; }
	COMMAND_DURATION_START_SECONDS=100.200007
	run _command_duration
	assert_output --regexp ".* 5s$"
}

@test "command_duration: _command_duration with precision" {
	BASH_IT_COMMAND_DURATION=true
	COMMAND_DURATION_MIN_SECONDS=1
	COMMAND_DURATION_PRECISION=1
	# Mock _command_duration_current_time
	_command_duration_current_time() { echo 105.600000; }
	COMMAND_DURATION_START_SECONDS=100.200000
	run _command_duration
	assert_output --regexp ".* 5.4s$"
}

@test "command_duration: _command_duration with minutes" {
	BASH_IT_COMMAND_DURATION=true
	COMMAND_DURATION_MIN_SECONDS=1
	# Mock _command_duration_current_time
	_command_duration_current_time() { echo 200; }
	COMMAND_DURATION_START_SECONDS=70
	run _command_duration
	assert_output --regexp ".* 2m 10s$"
}

@test "command_duration: _command_duration with microsecond rollover" {
	BASH_IT_COMMAND_DURATION=true
	COMMAND_DURATION_MIN_SECONDS=0
	COMMAND_DURATION_PRECISION=1
	# Mock _command_duration_current_time
	# 105.1 - 100.2 = 4.9
	_command_duration_current_time() { echo 105.100000; }
	COMMAND_DURATION_START_SECONDS=100.200000
	run _command_duration
	assert_output --regexp ".* 4.9s$"
}

@test "command_duration: _command_duration with precision and leading zeros" {
	BASH_IT_COMMAND_DURATION=true
	COMMAND_DURATION_MIN_SECONDS=0
	COMMAND_DURATION_PRECISION=3
	COMMAND_DURATION_START_SECONDS=100.001000
	_command_duration_current_time() { echo 105.002000; }
	run _command_duration
	assert_output --regexp ".* 5.001s$"
}

@test "command_duration: _command_duration without EPOCHREALTIME (SECONDS only)" {
	BASH_IT_COMMAND_DURATION=true
	COMMAND_DURATION_MIN_SECONDS=1
	COMMAND_DURATION_PRECISION=1
	# Mock _command_duration_current_time to return integer (like SECONDS would)
	_command_duration_current_time() { echo 105; }
	COMMAND_DURATION_START_SECONDS=100
	run _command_duration
	assert_output --regexp ".* 5s$"
}

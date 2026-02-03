# shellcheck shell=bash
#
# Functions for measuring and reporting how long a command takes to run.

# Get shell duration in decimal format regardless of runtime locale.
function _command_duration_current_time() {
	local current_time
	if [[ -n "${EPOCHREALTIME:-}" ]]; then
		current_time="${EPOCHREALTIME//,/.}"
	else
		current_time="$SECONDS"
	fi

	echo "$current_time"
}

function _command_duration_pre_exec() {
	COMMAND_DURATION_START_SECONDS="$(_command_duration_current_time)"
}

: "${COMMAND_DURATION_ICON:=🕘}"
: "${COMMAND_DURATION_MIN_SECONDS:=1}"

function _command_duration_pre_cmd() {
	COMMAND_DURATION_START_SECONDS=""
}

function _dynamic_clock_icon {
	local clock_hand duration="$1"

	# Clock only work for time >= 1s
	if ((duration < 1)); then
		duration=1
	fi

	# clock hand value is between 90 and 9b in hexadecimal.
	# so between 144 and 155 in base 10.
	printf -v clock_hand '%x' $((((${duration:-${SECONDS}} - 1) % 12) + 144))
	printf -v 'COMMAND_DURATION_ICON' '%b' "\xf0\x9f\x95\x$clock_hand"
}

function _command_duration() {
	[[ -n "${BASH_IT_COMMAND_DURATION:-}" ]] || return
	[[ -n "${COMMAND_DURATION_START_SECONDS:-}" ]] || return

	local current_time
	current_time="$(_command_duration_current_time)"

	local -i command_duration=0
	local -i minutes=0 seconds=0 deciseconds=0

	local -i command_start_seconds=${COMMAND_DURATION_START_SECONDS%.*}
	local -i current_time_seconds=${current_time%.*}

	# Calculate seconds difference
	command_duration=$((current_time_seconds - command_start_seconds))

	# Calculate deciseconds if both timestamps have fractional parts
	if [[ "$COMMAND_DURATION_START_SECONDS" == *.* ]] && [[ "$current_time" == *.* ]]; then
		local -i command_start_deciseconds=$((10#${COMMAND_DURATION_START_SECONDS##*.}))
		local -i current_time_deciseconds="$((10#${current_time##*.}))"

		# Take first digit for deciseconds
		command_start_deciseconds="${command_start_deciseconds:0:1}"
		current_time_deciseconds="${current_time_deciseconds:0:1}"

		if ((current_time_deciseconds >= command_start_deciseconds)); then
			deciseconds=$((current_time_deciseconds - command_start_deciseconds))
		else
			((command_duration -= 1))
			deciseconds=$((10 + current_time_deciseconds - command_start_deciseconds))
		fi
	fi

	if ((command_duration < 0)); then
		command_duration=0
		deciseconds=0
	fi

	if ((command_duration >= COMMAND_DURATION_MIN_SECONDS)); then
		minutes=$((command_duration / 60))
		seconds=$((command_duration % 60))

		_dynamic_clock_icon "${command_duration}"
		if ((minutes > 0)); then
			printf "%s %s%dm %ds" "${COMMAND_DURATION_ICON:-}" "${COMMAND_DURATION_COLOR:-}" "$minutes" "$seconds"
		else
			printf "%s %s%d.%01ds" "${COMMAND_DURATION_ICON:-}" "${COMMAND_DURATION_COLOR:-}" "$seconds" "$deciseconds"
		fi
	fi
}

_bash_it_library_finalize_hook+=("safe_append_preexec '_command_duration_pre_exec'")
_bash_it_library_finalize_hook+=("safe_append_prompt_command '_command_duration_pre_cmd'")

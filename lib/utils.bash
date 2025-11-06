#!/usr/bin/env bash

set -euo pipefail

TOOL_NAME="xcode"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

ensure_xcodes_installed() {
	if ! command -v xcodes &>/dev/null; then
		fail "xcodes is not installed. Please install it first with: brew install xcodesorg/made/xcodes"
	fi
}

resolve_version() {
	local requested_version="$1"
	local all_versions

	# If the requested version is exact, return it as-is
	if xcodes list | sed 's/ *(.*)$//' | grep -E '^[0-9]+\.[0-9]+' | awk '!seen[$0]++' | grep -Fx "$requested_version" >/dev/null; then
		echo "$requested_version"
		return
	fi

	# Get all available versions
	all_versions=$(xcodes list | sed 's/ *(.*)$//' | grep -E '^[0-9]+\.[0-9]+' | awk '!seen[$0]++')

	# For partial versions like "26" or "26.0", find the latest stable match
	# Priority: Stable release > Release Candidate > GM > Beta
	local matches
	matches=$(echo "$all_versions" | grep "^${requested_version}\\." || echo "$all_versions" | grep "^${requested_version} " || echo "$all_versions" | grep "^${requested_version}$")

	if [[ -z "$matches" ]]; then
		echo "No matching version found for: $requested_version" >&2
		return 1
	fi

	# Find the latest stable version (prefer non-beta/non-RC versions)
	local stable_match
	stable_match=$(echo "$matches" | grep -v -E "(Beta|Release Candidate|GM)" | tail -n1)

	if [[ -n "$stable_match" ]]; then
		echo "$stable_match"
	else
		# If no stable version, use the latest available (including beta/RC)
		echo "$matches" | tail -n1
	fi
}

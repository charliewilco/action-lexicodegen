#!/usr/bin/env bash
set -euo pipefail

sources="${INPUT_SOURCES:-./lexicons}"
output="${INPUT_OUTPUT:-./output/swift}"
config="${INPUT_CONFIG:-}"
extra_args="${INPUT_EXTRA_ARGS:-}"
working_directory="${INPUT_WORKING_DIRECTORY:-.}"
lexicodegen="${LEXICODEGEN_PATH:-lexicodegen}"

cd "$working_directory"

args=()
if [[ -n "$config" ]]; then
	args+=(--config "$config")
else
	while IFS= read -r source; do
		if [[ -n "$source" ]]; then
			args+=("$source")
		fi
	done <<< "$sources"

	if [[ -n "$output" ]]; then
		args+=(--output "$output")
	fi
fi

if [[ -n "$extra_args" ]]; then
	read -r -a split_extra_args <<< "$extra_args"
	args+=("${split_extra_args[@]}")
fi

printf "Running:"
printf " %q" "$lexicodegen" "${args[@]}"
printf "\n"

"$lexicodegen" "${args[@]}"

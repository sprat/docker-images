#!/bin/sh
# shellcheck shell=dash
set -euo pipefail

# get the id of the currently running container
get_container_id() {
	grep /hostname /proc/self/mountinfo | cut -d' ' -f4 | awk -F'/' '{print $(NF - 1)}'
}

# read some docker compose labels to determine how docker compose was launched
# we'll use the same parameters to run the scheduled jobs
get_compose_command() {
	local container_id project working_dir config_files env_files

	container_id=$(get_container_id)

	# get the execution context of the scheduler from its labels
	eval "$(docker inspect "$container_id" --format='
	project="{{ index .Config.Labels "com.docker.compose.project" }}"
	working_dir="{{ index .Config.Labels "com.docker.compose.project.working_dir" }}"
	config_files="{{ index .Config.Labels "com.docker.compose.project.config_files" }}"
	env_files="{{ index .Config.Labels "com.docker.compose.project.environment_file" }}"
	')"

	working_dir="$(echo "$working_dir" | normalize_path)"
	config_files="$(echo "$config_files" | normalize_and_rebase_paths "$working_dir")"
	env_files="$(echo "$env_files" | normalize_and_rebase_paths "$working_dir")"

	# build the compose command and write it to stdout
	xargs echo docker compose <<-EOF
	-p $project
	$(echo "$config_files" | prefix -f)
	$(echo "$env_files" | prefix --env-file)
	EOF
}

# normalize windows paths by replacing '\' or ':' by '/'
normalize_path() {
	tr -s '\\:' '/'
}

# normalize a list of paths separated with commas and make them absolute
normalize_and_rebase_paths() {
	normalize_path \
	| tr ',' '\n' \
	| xargs -r realpath -m --relative-to="$1" \
	| xargs -rI% realpath /app/%
}

# add a prefix to non-empty lines
prefix() {
	sed "/^\$/! s/^/$1 /g"
}

# shellcheck disable=SC2016
generate_crontab() {
	$1 --profile '*' config | yq '
	.services[] |
	select(.x-schedule) |
	.x-schedule + " $COMPOSE run " + key
	'
}

: "${LOG_LEVEL:="8"}"
crontab_file=/etc/crontabs/root

# determine the command to run docker compose
COMPOSE="$(get_compose_command)"
export COMPOSE
echo "Compose command: '$COMPOSE'"

# generate the crontab file
generate_crontab "$COMPOSE" >"$crontab_file"
echo "Generated crontab:"
echo "--------------------------------"
cat $crontab_file
echo "--------------------------------"

# run the cron daemon in foreground
exec crond -f -L /dev/stdout -l "$LOG_LEVEL"

#!/bin/bash

if [[ $(hostname) == "toolbox" ]]; then
  docker_cmd="/usr/bin/flatpak-spawn --host docker"
  docker_compose_cmd="/usr/bin/flatpak-spawn --host docker-compose"
else
  docker_cmd="docker"
  docker_compose_cmd="docker-compose"
fi

function __find_services() {
  readarray -t dirs < <(find . -maxdepth 1 -type d)
}

function __check_networks() {
  if ! $docker_cmd network ls | grep -q private; then $docker_cmd network create private; fi
  if ! $docker_cmd network ls | grep -q internal; then $docker_cmd network create internal; fi
  if ! $docker_cmd network ls | grep -q public; then $docker_cmd network create public; fi
}

function __prepare_env() {
  cp .env .env_bu

  for dir in "${dirs[@]}"; do
    if [ "$dir" != "." ]; then
     cat "$dir/.env" >> .env
   fi
  done
}

function __run_compose() {
  local command="$docker_compose_cmd"
  for dir in "${dirs[@]}"; do
     command="$command -f $dir/docker-compose.yml"
  done
  command="$command up -d"

  $command
}

function __teardown_env() {
  mv .env_bu .env
}

function __up() {
  __check_networks
  __find_services
  __prepare_env
  __run_compose
  __teardown_env
}

for arg in "$@"
do
  case $arg in
    up)
      __up
      shift
      ;;
    *)
      echo "command not found"
      shift
      ;;
  esac
done

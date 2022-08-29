#!/bin/bash

if [[ $(hostname) == "toolbox" ]]; then
  docker_cmd="/usr/bin/flatpak-spawn --host docker"
  docker_compose_cmd="/usr/bin/flatpak-spawn --host docker-compose"
  sops_cmd="/usr/bin/flatpak-spawn --host podman run --interactive --rm --security-opt label=disable --volume ${PWD}:/pwd --workdir /pwd -e SOPS_AGE_KEY_FILE=/pwd/keys.txt nixery.dev/sops sops"
else
  docker_cmd="docker"
  docker_compose_cmd="docker-compose"
  sops_cmd="podman run --interactive --rm --security-opt label=disable --volume ${PWD}:/pwd --workdir /pwd -e SOPS_AGE_KEY_FILE=/pwd/keys.txt nixery.dev/sops sops"
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
  mv .env .env.placeholder
}

function __inject_secrets() {
  file=$(cat .env.placeholder)

  for line in $file; do
    key=$(echo "$line" | awk 'BEGIN{FS=OFS="="}{print $1}')
    value=$(echo "$line" | awk 'BEGIN{FS=OFS="="}{print $2}')

    if [[ "$value" =~ ^\<sops:.+\>$ ]]; then
      var=${value//<sops:/}
      var=${var//>/}
      component="[\"docker\"][\"$var\"]"
      resolved_value=$($sops_cmd -d --extract "$component" secrets.yaml)
      echo "$key=$resolved_value" >> .env
    else
      echo "$key=$value" >> .env
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
  rm -f .env.placeholder
  mv .env_bu .env
}

__check_networks
__find_services
__prepare_env
__inject_secrets
__run_compose
__teardown_env

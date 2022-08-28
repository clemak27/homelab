#!/bin/bash

if [[ $(hostname) == "toolbox" ]]; then
  docker_cmd="/usr/bin/flatpak-spawn --host docker"
  docker_compose_cmd="/usr/bin/flatpak-spawn --host docker-compose"
else
  docker_cmd="docker"
  docker_compose_cmd="docker-compose"
fi

function __prepare_env() {
  mkdir -p tmp
  cp .env .env_bu
  cat homer/.env >> .env
  cat deemix/.env >> .env
}

function __teardown_env() {
  mv .env_bu .env
}

function __up() {
  if ! $docker_cmd network ls | grep -q private; then $docker_cmd network create private; fi
  if ! $docker_cmd network ls | grep -q internal; then $docker_cmd network create internal; fi
  if ! $docker_cmd network ls | grep -q public; then $docker_cmd network create public; fi
  __prepare_env
  $docker_compose_cmd -f docker-compose.yml -f homer/docker-compose.yml -f deemix/docker-compose.yml up -d
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

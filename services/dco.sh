#!/bin/bash

if [[ $(hostname) == "toolbox" ]]; then
  docker_cmd="/usr/bin/flatpak-spawn --host docker"
  docker_compose_cmd="/usr/bin/flatpak-spawn --host docker-compose"
else
  docker_cmd="docker"
  docker_compose_cmd="docker-compose"
fi

function __up() {
  if ! $docker_cmd network ls | grep -q private; then $docker_cmd network create private; fi
  if ! $docker_cmd network ls | grep -q internal; then $docker_cmd network create internal; fi
  if ! $docker_cmd network ls | grep -q public; then $docker_cmd network create public; fi
  $docker_compose_cmd -f homer/docker-compose.yml -f deemix/docker-compose.yml up -d
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

#!/bin/bash

if [[ $(hostname) == "toolbox" ]]; then
  docker_cmd="/usr/bin/flatpak-spawn --host docker"
  docker_compose_cmd="/usr/bin/flatpak-spawn --host docker-compose"
else
  docker_cmd="docker"
  docker_compose_cmd="docker-compose"
fi

function __up() {
  $docker_cmd network create private
  $docker_cmd network create internal
  $docker_cmd network create public
  $docker_compose_cmd -f homer/docker-compose.yml up -d
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

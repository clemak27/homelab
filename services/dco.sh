#!/bin/bash

if [[ $(hostname) == "toolbox" ]]; then
  docker_compose_cmd="/usr/bin/flatpak-spawn --host docker-compose"
else
  docker_compose_cmd="docker-compose"
fi

function __up() {
  $docker_compose_cmd up -f homer/docker-compose.yaml --env-file homer/.env
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

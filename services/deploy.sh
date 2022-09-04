#!/bin/bash

if [[ $(hostname) == "toolbox" ]]; then
  docker_cmd="/usr/bin/flatpak-spawn --host docker"
  docker_compose_cmd="/usr/bin/flatpak-spawn --host docker-compose"
  sops_cmd="/usr/bin/flatpak-spawn --host podman run --interactive --rm --security-opt label=disable --volume ${PWD}:/pwd --workdir /pwd --volume ${HOME}/.config/sops/age/keys.txt:/pwd/keys.txt:ro -e SOPS_AGE_KEY_FILE=/pwd/keys.txt nixery.dev/sops sops"
else
  docker_cmd="docker"
  docker_compose_cmd="docker-compose"
  sops_cmd="podman run --interactive --rm --security-opt label=disable --volume ${PWD}:/pwd --workdir /pwd --volume ${HOME}/.config/sops/age/keys.txt:/pwd/keys.txt:ro -e SOPS_AGE_KEY_FILE=/pwd/keys.txt nixery.dev/sops sops"
fi

function __find_services() {
  dirs=(
    "."
    "./homelab_bot"
    # "./homer"
    # "./deemix"
    # "./calibre"
    # "./cloudflare-ddns"
    # "./deconz"
    # "./syncthing"
    # "./traefik"
    # "./vaultwarden"
    # "./fireflyiii"
    # "./miniflux"
    # "./recipes"
    # "./mqtt"
    # "./pihole"
    # "./gitea"
    # "./home-assistant"
    # "./jellyfin"
    # "./torrents"
    # "./monitoring"
    # "./mp3gain_update"
    )
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

function __add_secrets() {
  $sops_cmd -d .env.secret.enc > .env.secret
  cat .env.secret >> .env
  rm .env.secret
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
  rm -f .env.secret
  mv .env_bu .env
}

__check_networks
__find_services
__prepare_env
__add_secrets
__run_compose
__teardown_env

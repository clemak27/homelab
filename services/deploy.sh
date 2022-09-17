#!/bin/bash

set -euo pipefail

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

function __add_secrets() {
  if [[ -z "${DEPLOY_TEST}" ]]; then
    $sops_cmd -d .env.secret.enc > .env.secret
    cat .env.secret >> .env
    rm .env.secret
  else
    {
      echo "CLOUDFLARE_API_KEY=someSecret"
      echo "TRAEFIK_CLOUDFLARE_API_KEY=someSecret"
      echo "PIHOLE_PW=someSecret"
      echo "MINIFLUX_ADMIN_USER=someSecret"
      echo "MINIFLUX_ADMIN_PASSWORD=someSecret"
      echo "MINIFLUX_DB_USER=someSecret"
      echo "MINIFLUX_DB_PASSWORD=someSecret"
      echo "DEEMIX_ARL=someSecret"
      echo "FIREFLYIII_APP_KEY=someSecret"
      echo "FIREFLYIII_DB_NAME=someSecret"
      echo "FIREFLYIII_DB_USER=someSecret"
      echo "FIREFLYIII_DB_PASSWORD=someSecret"
      echo "RECIPES_SECRET_KEY=someSecret"
      echo "RECIPES_DB_USER=someSecret"
      echo "RECIPES_DB_PASSWORD=someSecret"
      echo "RECIPES_DB_NAME=someSecret"
      echo "VAULTWARDEN_YUBICO_CLIENT_ID=someSecret"
      echo "VAULTWARDEN_YUBICO_SECRET_KEY=someSecret"
      echo "HOMELAB_BOT_TELEGRAM_CHAT_ID=someSecret"
      echo "HOMELAB_BOT_TELEGRAM_CHAT_URL=someSecret"
    } >> .env
  fi
}

function __run_compose() {
  local command="$docker_compose_cmd"
  for dir in "${dirs[@]}"; do
    command="$command -f $dir/docker-compose.yml"
  done

  if [[ -z "${DEPLOY_TEST}" ]]; then
    command="$command up -d --remove-orphans"
    $command
  else
    command="$command config"
    $command > compose.yaml
  fi
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

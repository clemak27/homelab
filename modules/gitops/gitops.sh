#!/bin/sh

git_cmd="git -C /var/home/clemens/Projects/homelab"

__deploy() {
  cd /var/home/clemens/Projects/homelab/services || exit 1
  curl -X POST -H 'Content-Type: application/json' --url 192.168.178.100:8525/message/silent -d "{\"title\": \"gitops\", \"text\": \"Starting deployment.\"}"
  if ./deploy.sh; then
    curl -X POST -H 'Content-Type: application/json' --url 192.168.178.100:8525/message/silent -d "{\"title\": \"gitops\", \"text\": \"Deployment successful.\"}"
  else
    curl -X POST -H 'Content-Type: application/json' --url 192.168.178.100:8525/message -d "{\"title\": \"gitops\", \"text\": \"Deployment failed!\"}"
  fi
}

if [ ! -f "/tmp/git_status_old" ]
then
  touch /var/mnt/data/docker/traefik/traefik.log
  touch /var/mnt/data/docker/traefik/acme.json
  touch /var/mnt/data/docker/home-assistant/bumper-certs/custom_ca.pem
  __deploy
fi

$git_cmd pull --rebase

$git_cmd log --oneline > /tmp/git_status_new

DIFF=$(cmp /tmp/git_status_old /tmp/git_status_new)
if [ "$DIFF" != "" ]
then
  __deploy
fi

mv /tmp/git_status_new /tmp/git_status_old

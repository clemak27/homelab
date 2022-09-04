#!/bin/sh

git_cmd="git -C /var/home/clemens/Projects/homelab"
title=$(hostname)

if [ ! -f "/tmp/git_status_old" ]
then
  cd /var/home/clemens/Projects/homelab/services || exit 1
  ./deploy.sh
  curl -X POST -H 'Content-Type: application/json' --url 192.168.178.100:8525/message -d "{\"title\": \"$title\", \"text\": \"Initial deployment done!\"}"
fi

$git_cmd pull --rebase

$git_cmd log --oneline > /tmp/git_status_new

DIFF=$(cmp /tmp/git_status_old /tmp/git_status_new)
if [ "$DIFF" != "" ]
then
  cd /var/home/clemens/Projects/homelab/services || exit 1
  curl -X POST -H 'Content-Type: application/json' --url 192.168.178.100:8525/message -d "{\"title\": \"$title\", \"text\": \"Starting deployment.\"}"
  if ./deploy.sh; then
    curl -X POST -H 'Content-Type: application/json' --url 192.168.178.100:8525/message -d "{\"title\": \"$title\", \"text\": \"Update successful.\"}"
  else
    curl -X POST -H 'Content-Type: application/json' --url 192.168.178.100:8525/message -d "{\"title\": \"$title\", \"text\": \"Update failed!\"}"
  fi
fi

mv /tmp/git_status_new /tmp/git_status_old

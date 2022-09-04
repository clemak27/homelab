#!/bin/sh

git_cmd="git -C /var/home/clemens/Projects/homelab"
message_cmd="curl -X POST -H 'Content-Type: application/json' --url 192.168.178.100:8525/message"
update_cmd="cd /var/home/clemens/Projects/homelab/services && ./deploy.sh"
title=$(hostname)

$git_cmd pull --rebase

$git_cmd log --oneline > /tmp/git_status_new

DIFF=$(cmp /tmp/git_status_old /tmp/git_status_new)
if [ "$DIFF" != "" ]
then
  echo "$update_cmd"
  "$update_cmd"
  # "$message_cmd" -d "{\"title\": \"$title\", \"text\": \"Starting deployment.\"}"
  # if $update_cmd; then
  #   "$message_cmd" -d "{\"title\": \"$title\", \"text\": \"Update successful.\"}"
  # else
  #   "$message_cmd" -d "{\"title\": \"$title\", \"text\": \"Update failed!\"}"
  # fi
fi

mv /tmp/git_status_new /tmp/git_status_old

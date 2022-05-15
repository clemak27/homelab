#!/bin/sh

git -C /home/clemens/Projects/homelab log --oneline > /tmp/git_status_new
title=$(hostname)

DIFF=$(cmp /tmp/git_status_old /tmp/git_status_new)
if [ "$DIFF" != "" ]
then
  cd /home/clemens/Projects/homelab || exit
  curl -X POST -H "Content-Type: application/json" -d "{\"title\": \"$title\", \"text\": \"Starting system update.\"}" --url 192.168.178.100:8525/message
  if nixos-rebuild switch --flake '.?submodules=1' --impure; then
    curl -X POST -H "Content-Type: application/json" -d "{\"title\": \"$title\", \"text\": \"Update successful.\"}" --url 192.168.178.100:8525/message
  else
    curl -X POST -H "Content-Type: application/json" -d "{\"title\": \"$title\", \"text\": \"Update failed!\"}" --url 192.168.178.100:8525/message
  fi
fi

mv /tmp/git_status_new /tmp/git_status_old

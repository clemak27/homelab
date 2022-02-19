#!/bin/sh

tree /home/clemens/Projects/homelab/.git > /tmp/git_tree_new

DIFF=$(cmp /tmp/git_tree_old /tmp/git_tree_new)
if [ "$DIFF" != "" ]
then
  cd /home/clemens/Projects/homelab || exit
  curl -X POST -H "Content-Type: application/json" -d '{"title": "snowflake", text": "Starting update."}' --url localhost:8525/message
  if nixos-rebuild switch --flake . --impure; then
    curl -X POST -H "Content-Type: application/json" -d '{"title": "snowflake", "text": "Update successful."}' --url localhost:8525/message
  else
    curl -X POST -H "Content-Type: application/json" -d '{"title": "snowflake", "text": "Update failed!"}' --url localhost:8525/message
  fi
fi

mv /tmp/git_tree_new /tmp/git_tree_old

#!/bin/bash

__mp3gu() {
  tree /app/music > /tmp/tree_new

  DIFF=$(cmp /tmp/tree_old /tmp/tree_new)
  if [ "$DIFF" != "" ]
  then
    readarray -d '' FOLDER < <(find "/app/music/" -type d -print0)

    for i in "${FOLDER[@]}"
    do
      cd "$i" || exit 1
      fd mp3 . -d 1 -X mp3gain -a -p -k
      cd /app/music || exit 1
    done
    curl -X POST -H "Content-Type: application/json" --url 192.168.178.100:8525/message/silent -d '{"title": "mp3gain"," text": "Update finished."}'
  fi

  mv /tmp/tree_new /tmp/tree_old
}

while :
do
  # TODO replace with cronjob/inotify
  __mp3gu
  sleep 600
done


#!/bin/bash

__mp3gu() {
    readarray -d '' FOLDER < <(find "/var/mnt/data/media/music/" -type d -print0)

    for i in "${FOLDER[@]}"
    do
      cd "$i" || exit 1
      fd mp3 . -d 1 -X mp3gain -a -p -k
      cd /var/mnt/data/media/music || exit 1
    done
    curl -X POST -H "Content-Type: application/json" --url 192.168.178.100:8525/message/silent -d '{"title": "mp3gain","text": "Update finished."}'
}

__mp3gu

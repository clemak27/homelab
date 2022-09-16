FROM nixery.dev/shell/tree/fd/mp3gain/curl/diffutils/findutils

RUN mkdir -p /app/music
ADD . /app
WORKDIR /app

CMD ["/app/mp3gain_update.bash"]

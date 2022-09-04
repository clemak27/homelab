FROM nixery.dev/shell/tree/cmp/fd/mp3gain/curl

RUN mkdir -p /app
ADD . /app
WORKDIR /app

CMD ["/app/mp3gain_update.bash"]

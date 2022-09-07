FROM nixery.dev/shell/tree/fd/mp3gain/curl/diffutils

RUN mkdir -p /app
ADD . /app
WORKDIR /app

CMD ["/app/mp3gain_update.bash"]

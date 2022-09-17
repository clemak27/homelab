# hadolint ignore=DL3006
FROM nixery.dev/shell/tree/fd/mp3gain/curl/diffutils/findutils

RUN mkdir -p /app
COPY . /app
WORKDIR /app
RUN chmod +x /app/mp3gain_update.bash

CMD ["/app/mp3gain_update.bash"]

FROM nixery.dev/shell/tree/fd/mp3gain/curl/diffutils/findutils

RUN mkdir -p /app/music
ADD . /app
WORKDIR /app
RUN chown -R 1001:1001 .
RUN chmod 775 /app/music

CMD ["/app/mp3gain_update.bash"]

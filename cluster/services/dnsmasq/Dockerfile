# docker build -t registry.wallstreet30.cc/dnsmasq:latest .
# docker push registry.wallstreet30.cc/dnsmasq:latest
FROM alpine:latest

RUN apk --no-cache add \
  tini \
  bash \
  dnsmasq && \
  rm -rf /tmp/* /var/cache/apk/*

RUN mkdir -p /etc/default/
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq

EXPOSE 53/tcp 53/udp 67/udp

ENTRYPOINT ["/sbin/tini", "--", "/usr/sbin/dnsmasq", "--conf-file=/config/dnsmasq.conf", "--no-daemon", "--no-resolv"]

FROM debian:bullseye-slim

ENV IS_CONTAINERIZED=True

RUN apt-get update && apt-get upgrade -y && apt-get clean

ADD https://github.com/nyaruka/courier/releases/download/v7.4.0/courier_7.4.0_linux_amd64.tar.gz /tmp
RUN mkdir -p /opt/courier \
    && tar -C /opt/courier -xzf /tmp/courier_7.4.0_linux_amd64.tar.gz \
    && rm -f /tmp/courier_7.4.0_linux_amd64.tar.gz \
    && mkdir -p /var/spool/courier

CMD ./opt/courier/courier --debug-conf -log-level $LOG_LEVEL 

EXPOSE 8080
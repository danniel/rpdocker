FROM debian:bullseye-slim

ENV IS_CONTAINERIZED=True

RUN apt-get update && apt-get upgrade -y && apt-get clean

ADD https://github.com/nyaruka/mailroom/releases/download/v7.4.1/mailroom_7.4.1_linux_amd64.tar.gz /tmp
RUN mkdir -p /opt/mailroom \
    && tar -C /opt/mailroom -xzf /tmp/mailroom_7.4.1_linux_amd64.tar.gz \
    && rm -f /tmp/mailroom_7.4.1_linux_amd64.tar.gz

CMD ./opt/mailroom/mailroom --debug-conf -log-level $LOG_LEVEL 

EXPOSE 8090
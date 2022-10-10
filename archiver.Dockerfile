FROM debian:bullseye-slim

ENV IS_CONTAINERIZED=True

RUN apt-get update && apt-get upgrade -y && apt-get clean

ADD https://github.com/nyaruka/rp-archiver/releases/download/v7.4.0/rp-archiver_7.4.0_linux_amd64.tar.gz /tmp
RUN mkdir -p /opt/rp-archiver \
    && tar -C /opt/rp-archiver -xzf /tmp/rp-archiver_7.4.0_linux_amd64.tar.gz \
    && rm -f /tmp/rp-archiver_7.4.0_linux_amd64.tar.gz

CMD ./opt/rp-archiver/rp-archiver --debug-conf -log-level $LOG_LEVEL 


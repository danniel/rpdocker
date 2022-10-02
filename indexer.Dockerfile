FROM debian:bullseye-slim

ENV IS_CONTAINERIZED=True

RUN apt-get update && apt-get upgrade -y

ADD https://github.com/nyaruka/rp-indexer/releases/download/v7.4.0/rp-indexer_7.4.0_linux_amd64.tar.gz /tmp
RUN mkdir -p /opt/rp-indexer \
    && tar -C /opt/rp-indexer -xzf /tmp/rp-indexer_7.4.0_linux_amd64.tar.gz \
    && rm -f /tmp/rp-indexer_7.4.0_linux_amd64.tar.gz

CMD ./opt/rp-indexer/rp-indexer --debug-conf -log-level $LOG_LEVEL 

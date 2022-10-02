# The build image
FROM debian:bullseye-slim as build

ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        build-essential gettext libpq-dev gdal-bin libgdal-dev \
        python3.9 python3.9-dev python3-pip python3-venv

# Temba source
ADD https://github.com/rapidpro/rapidpro/archive/refs/tags/v7.4.2.tar.gz /tmp
RUN mkdir -p /var/www/ && tar -C /var/www/ -xzf /tmp/v7.4.2.tar.gz \
    && mv /var/www/rapidpro-7.4.2/ /var/www/rapidpro/

# Python venv
WORKDIR /var/www/rapidpro
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH=/root/.local/bin:$VIRTUAL_ENV/bin:$PATH

RUN python3.9 -m pip install poetry gunicorn[gevent] GDAL==$(gdal-config --version)
RUN poetry install

# The final image
FROM debian:bullseye-slim

ENV PYTHONUNBUFFERED=1
ENV IS_CONTAINERIZED=True

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
         xz-utils curl nginx gettext python3.9 gdal-bin

COPY --from=build /var/www/rapidpro /var/www/rapidpro
WORKDIR /var/www/rapidpro

COPY --from=build /opt/venv /opt/venv
ENV VIRTUAL_ENV=/opt/venv
ENV PATH=/root/.local/bin:$VIRTUAL_ENV/bin:$PATH

# NodeJS (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt install -y nodejs npm
RUN npm install less -g --no-audit && npm install coffeescript -g --no-audit && npm install -y --no-audit

# Django
COPY temba/settings.py temba/settings.py
RUN python3.9 manage.py collectstatic

# Supervision
ARG S6_OVERLAY_VERSION=3.1.2.1
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME 0

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

ENTRYPOINT ["/init"]

COPY docker/s6-rc.d /etc/s6-overlay/s6-rc.d

# NGINX
COPY docker/nginx/nginx.conf /etc/nginx/sites-available/default

EXPOSE 80 443

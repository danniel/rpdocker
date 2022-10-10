# The build image
FROM debian:bullseye-slim as build

ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        build-essential gettext libpq-dev gdal-bin libgdal-dev git \
        python3.9 python3.9-dev python3.9-distutils python3-pip python3-venv

# Temba source
ADD https://github.com/rapidpro/rapidpro/archive/refs/tags/v7.4.2.tar.gz /tmp
RUN mkdir -p /var/www/ && tar -C /var/www/ -xzf /tmp/v7.4.2.tar.gz \
    && mv /var/www/rapidpro-7.4.2/ /var/www/rapidpro/

# Build the RapidPro API importer app (TODO: switch to another github account)
RUN git clone https://github.com/danniel/django-tembaimporter.git /tmp/django-tembaimporter/
RUN cd /tmp/django-tembaimporter/ && make build

# Python venv
WORKDIR /var/www/rapidpro
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH=/root/.local/bin:$VIRTUAL_ENV/bin:$PATH

RUN python3.9 -m pip install poetry gunicorn[gevent] GDAL==$(gdal-config --version)
RUN poetry add /tmp/django-tembaimporter/dist/django-tembaimporter-0.1.tar.gz
RUN poetry install

# The final image
FROM debian:bullseye-slim

ENV PYTHONUNBUFFERED=1
ENV IS_CONTAINERIZED=True

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
         xz-utils nginx gettext python3.9 gdal-bin nodejs npm \
    && apt-get clean && apt-get autoclean

# Less and Coffescript
RUN npm install less -g --no-audit && npm install coffeescript -g --no-audit

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
COPY docker/nginx/selfsigned.crt /etc/ssl/localcerts/selfsigned.crt
COPY docker/nginx/selfsigned.key /etc/ssl/localcerts/selfsigned.key
COPY docker/nginx/nginx.conf /etc/nginx/sites-available/default

# Application files
COPY --from=build /var/www/rapidpro /var/www/rapidpro
WORKDIR /var/www/rapidpro

# Application virtual env
COPY --from=build /opt/venv /opt/venv
ENV VIRTUAL_ENV=/opt/venv
ENV PATH=/root/.local/bin:$VIRTUAL_ENV/bin:$PATH

# Application set up
COPY docker/temba/settings.py temba/settings.py
RUN npm install -y --no-audit
RUN python3.9 manage.py collectstatic

EXPOSE 80 443

FROM ubuntu:xenial-20180228

ARG VERSION=0.3
ARG UID=1000
ARG GID=1000
ARG USERNAME=scabbers

LABEL maintainer="rado.salov@gmail.com" \
    version="${VERSION}" \
    description="This image will be used as base for other images"

ENV UID ${UID}
ENV GID ${GID}
ENV USERNAME ${USERNAME}

# We will use supervisor for managing services
RUN apt-get update -y && apt-get upgrade -y \
    && apt-get install --no-install-recommends --no-install-suggests -y supervisor cron \
    && groupadd -g ${GID} ${USERNAME} \
    && useradd -g ${GID} -u ${UID} -m -d /home/${USERNAME} -s /bin/bash ${USERNAME} \
    && mkdir -p /app \
    && chown -R ${UID}:${GID} /app \
    && sed -i '/session    required     pam_loginuid.so/c\#session    required     pam_loginuid.so' /etc/pam.d/cron \
    && apt-get clean && apt -y autoremove

COPY supervisord.conf /etc/supervisord.conf
# Script to wait for other hosts
COPY wait.sh /opt/wait.sh

VOLUME ["/app"]
WORKDIR /app
USER ${USERNAME}

CMD /opt/wait.sh && /usr/bin/supervisord -n -c /etc/supervisord.conf

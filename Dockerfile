FROM ubuntu:20.04
MAINTAINER https://github.com/gseldon
ARG INSTALL_DEB_PACKAGE

ENV WEB_HEALTHCHECK=${WEB_HEALTHCHECK}
ENV INSTALL_DEB_PACKAGE=${INSTALL_DEB_PACKAGE}
ENV DNS_SERVER=${DNS_SERVER:-77.88.8.8}
ENV DEBUG_LEVEL=${DEBUG_LEVEL:-1}
ENV KEYFILE_PASS=${KEYFILE_PASS}

RUN apt-get -o Acquire::Max-FutureTime=86400 update && \
    apt-get -fy install procps cron curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /vipnet
COPY ./app/${INSTALL_DEB_PACKAGE} .
COPY ./entrypoint.sh /vipnet/entrypoint.sh

RUN mkdir -p /vipnet && \
    dpkg -i ${INSTALL_DEB_PACKAGE} && \
    rm -f ${INSTALL_DEB_PACKAGE}

ADD entrypoint.sh .

HEALTHCHECK --interval=5s --timeout=15s --retries=3 \
            CMD curl -o /dev/null -s -w "%{http_code}\n" ${WEB_HEALTHCHECK} || bash -c 'kill -s 15 -1 && (sleep 10; kill -s 9 -1)'

CMD bash /vipnet/entrypoint.sh

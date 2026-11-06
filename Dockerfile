FROM ubuntu:22.04

ARG INSTALL_DEB_PACKAGE
ARG DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.authors="https://github.com/gseldon" \
      org.opencontainers.image.source="https://github.com/gseldon/vipnet-client-docker" \
      org.opencontainers.image.title="ViPNet Client 5"

# Max-FutureTime: обход ошибки при сбитых часах (например, в WSL)
# .deb монтируется на время сборки и не попадает в слой образа
RUN --mount=type=bind,source=app,target=/tmp/app \
    apt-get -o Acquire::Max-FutureTime=86400 update && \
    apt-get install -y --no-install-recommends \
        procps curl ca-certificates iputils-ping \
        "/tmp/app/${INSTALL_DEB_PACKAGE}" && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /vipnet
COPY --chmod=755 entrypoint.sh healthcheck.sh /

HEALTHCHECK --interval=30s --timeout=30s --retries=3 CMD ["/healthcheck.sh"]

ENTRYPOINT ["/entrypoint.sh"]

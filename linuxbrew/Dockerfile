# syntax=docker/dockerfile:1.4
FROM debian:bookworm-slim

RUN <<EOF
  apt-get update
  apt-get install -y --no-install-recommends \
    build-essential procps curl file git \
    ca-certificates ssh sudo zsh locales
  rm -rf /var/lib/apt/lists/*
EOF

WORKDIR /app

COPY --chmod=755 entrypoint.sh /app/
COPY etc/locale.gen /etc/locale.gen

RUN <<EOF
  locale-gen
  mkdir -p /run/sshd
  cp -rp /etc/ssh /app/ssh
EOF

VOLUME [ "/etc/ssh" ]
EXPOSE 22

ENV UID 1000
ENV GROUP users
ENV GROUPS users
ENV LOGIN_SHELL /bin/bash

ENTRYPOINT [ "/app/entrypoint.sh" ]
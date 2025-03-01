# syntax=docker/dockerfile:1.4
FROM golang:1.24-bookworm as build

RUN <<EOF
set -eux
apt-get update
apt-get install -y --no-install-recommends \
    git \
    curl
rm -rf /var/lib/apt/lists/*
EOF

WORKDIR /build

RUN <<EOF
set -eux
git clone https://github.com/pvelati/cheap-switch-exporter.git src
cd src
go mod download
go mod verify
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build \
    -ldflags="-w -s -X 'main.Version=$(git describe --tags --always --dirty)'" \
    -o ./cheap-switch-exporter
EOF

FROM debian:bookworm-slim

WORKDIR /app

RUN <<EOF
set -eux
apt-get update
apt-get install -y --no-install-recommends \
    wget
rm -rf /var/lib/apt/lists/*
EOF

COPY --from=build /build/src/cheap-switch-exporter /app/cheap-switch-exporter

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s \
  CMD wget -q -O- http://localhost:8080/metrics || exit 1

CMD ["cheap-switch-exporter"]

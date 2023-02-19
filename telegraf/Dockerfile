# syntax=docker/dockerfile:1.4
FROM telegraf:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
  sudo smartmontools nvme-cli && \
  rm -rf /var/lib/apt/lists/*

COPY --chown=root:root etc/sudoers.d/telegraf /etc/sudoers.d/telegraf
RUN chmod 440 /etc/sudoers.d/telegraf

RUN /usr/sbin/update-smart-drivedb

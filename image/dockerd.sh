#!/bin/bash
set -e
if [ ! -S "/var/run/docker.sock" ] && [ -f /usr/local/bin/dockerd ]; then
  echo '[ Starting Docker... ]'
  exec dockerd &>/var/log/docker.log &
fi

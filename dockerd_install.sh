#!/bin/sh
set -ex \
# Install Docker CE
DOCKER_BUCKET="download.docker.com"
ARCH=x86_64
DOCKER_VERSION=$(curl -fsSL https://${DOCKER_BUCKET}/linux/static/stable/$ARCH/ | \
  grep -Eo '[0-9]+\.[0-9]+\.[0-9]*' | tail -1)
curl -fsSL "https://${DOCKER_BUCKET}/linux/static/stable/$ARCH/docker-${DOCKER_VERSION}.tgz" \
  -o docker.tgz
tar --extract --file docker.tgz --strip-components 1  \
  --directory /usr/local/bin/
rm docker.tgz
addgroup -g 133 docker || true
# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
addgroup dockremap || true
id dockremap || useradd -g dockremap -s /bin/bash -d /home/dockremap -m dockremap
grep dockremap /etc/subuid || echo 'dockremap:165536:65536' >> /etc/subuid
grep dockremap /etc/subgid || echo 'dockremap:165536:65536' >> /etc/subgid
# Buildx Plugin
mkdir -p /usr/local/lib/docker/cli-plugins
BUILDX_RELESES="https://github.com/docker/buildx/releases"
BUILDX_VERSION=$(curl -fsL $BUILDX_RELESES | grep -m 1 -Eo 'v[0-9]+\.[0-9]+\.[0-9]*')
curl -fsSL $BUILDX_RELESES/download/$BUILDX_VERSION/buildx-$BUILDX_VERSION.linux-amd64 \
  -o /usr/local/lib/docker/cli-plugins/docker-buildx
chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx

mkdir -p /etc/docker
cat <<'EOF'> /etc/docker/daemon.json
{
  "storage-driver": "overlay2",
  "iptables": true,
  "ipv6": false,
  "ip6tables": false,
  "live-restore": false,
  "metrics-addr": "127.0.0.1:9323",
  "features": {
    "buildkit": true
  },
  "hosts": [
    "unix:///var/run/docker.sock",
    "tcp://127.0.0.1:2376"
  ],
  "pidfile": "/var/run/docker.pid",
  "group": "docker"
}
EOF

echo '%docker ALL=(ALL) NOPASSWD: /usr/local/bin/dockerd' | tee /etc/sudoers.d/docker1
echo "$SUDO_USER" 'ALL=(ALL) NOPASSWD: /usr/local/bin/dockerd' | tee /etc/sudoers.d/docker2

sed -i "/group/ s/docker/$SUDO_USER/" /etc/docker/daemon.json

docker --version

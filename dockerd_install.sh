#!/bin/sh
set -ex
if [ -z $SUDO_USER ] || [ $SUDO_USER == "root" ]; then 
  printf '\nRun with sudo, NOT as root!\n\n'
  exit 1
fi
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
addgroup --gid 133 docker || true
# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
grep $SUDO_USER /etc/subuid || echo "$SUDO_USER:165536:65536" >> /etc/subuid
grep $SUDO_USER /etc/subgid || echo "$SUDO_USER:165536:65536" >> /etc/subgid
# Buildx Plugin
mkdir -p /usr/local/lib/docker/cli-plugins
BUILDX_RELESES="https://github.com/docker/buildx/releases"
BUILDX_VERSION=$(curl -fsL $BUILDX_RELESES/latest | grep -m 1 -Eo 'v[0-9]+\.[0-9]+\.[0-9]*')
curl -fsSL $BUILDX_RELESES/download/$BUILDX_VERSION/buildx-$BUILDX_VERSION.linux-amd64 \
  -o /usr/local/lib/docker/cli-plugins/docker-buildx
chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx

# Docker Compose
COMPOSE_RELESES="https://github.com/docker/compose/releases"
COMPOSE_VERSION=$(curl -fsL $COMPOSE_RELESES/latest | grep -m 1 -Eo 'v[0-9]+\.[0-9]+\.[0-9]*')
curl -fsSL $COMPOSE_RELESES/download/$COMPOSE_VERSION/docker-compose-linux-x86_64 \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/local/lib/docker/cli-plugins/docker-compose
docker-compose version

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
    "unix:///var/run/docker.sock"
  ],
  "pidfile": "/var/run/docker.pid",
  "group": "docker"
}
EOF

cat <<'EOF'> /dockerd.sh
#!/bin/bash
set -e
if [ ! -S "/var/run/docker.sock" ] && [ -f /usr/local/bin/dockerd ]; then
  echo '[ Starting Docker... ]'
  exec dockerd &>/var/log/docker.log &
fi
EOF

chmod +x /dockerd.sh

cat <<'EOF'> /home/$SUDO_USER/.profile
sudo /dockerd.sh
source ~/.bashrc
EOF

echo '%docker ALL=(ALL) NOPASSWD: /dockerd.sh' | tee /etc/sudoers.d/99-dockerd
echo "$SUDO_USER" 'ALL=(ALL) NOPASSWD: /dockerd.sh' | tee -a /etc/sudoers.d/99-dockerd

sed -i "/group/ s/docker/$SUDO_USER/" /etc/docker/daemon.json

cat <<EOF> /etc/wsl.conf
[user]
default=$SUDO_USER
[automount]
options=metadata
EOF

docker --version

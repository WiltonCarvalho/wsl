FROM docker.io/library/ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=America/Sao_Paulo
USER root
RUN set -ex \
    && apt-get -q update \
    && apt-get -q -y install --only-upgrade $( apt-get --just-print upgrade | \
        awk 'tolower($4) ~ /.*security.*/ || tolower($5) ~ /.*security.*/ {print $2}' | sort | uniq ) \
    && apt-get -q -y install --no-install-recommends \
        tzdata openssl gnupg2 ca-certificates git curl wget less lynx \
        jq jp procps psmisc zip unzip iptables iproute2 openssh-client \
        python3-minimal python3-pip iputils-ping telnet \
    && apt-get -q -y install locales dialog sudo vim bash-completion \
        zsh zsh-syntax-highlighting zsh-autosuggestions powerline zsh-theme-powerlevel9k fonts-font-awesome \
    && rm -rf /var/lib/apt/lists/*

# SSH Client Config
RUN set -ex \
    && mkdir -p /etc/ssh/ssh_config.d \
    && echo '\
Host * \n\
    ConnectTimeout=10 \n\
    ConnectionAttempts=10 \n\
    StrictHostKeyChecking=no \n\
    UserKnownHostsFile=/dev/null \n\
' > /etc/ssh/ssh_config.d/custom.conf

# Install Docker
RUN set -ex \
    # Install Docker CE
    && DOCKER_BUCKET="download.docker.com" \
    && ARCH=$(uname -p) \
    && DOCKER_VERSION=$(curl -fsSL https://${DOCKER_BUCKET}/linux/static/stable/$ARCH/ | grep -Eo '[0-9]+\.[0-9]+\.[0-9]*' | tail -1) \
    && curl -fsSL "https://${DOCKER_BUCKET}/linux/static/stable/$(uname -p)/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
    && tar --extract --file docker.tgz --strip-components 1  --directory /usr/local/bin/ \
    && rm docker.tgz \
    && addgroup -gid 133 docker \
    # Buildx Plugin
    && mkdir -p /usr/local/lib/docker/cli-plugins \
    && BUILDX_RELESES="https://github.com/docker/buildx/releases" \
    && BUILDX_VERSION=$(curl -fsL $BUILDX_RELESES | grep -m 1 -Eo 'v[0-9]+\.[0-9]+\.[0-9]*') \
    && curl -fsSL $BUILDX_RELESES/download/$BUILDX_VERSION/buildx-$BUILDX_VERSION.linux-amd64 \
        -o /usr/local/lib/docker/cli-plugins/docker-buildx \
    && chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx \
    # Smoke Test
    && docker --version

# AWS CLI
COPY --chmod=755 sts-token.sh /usr/local/bin/sts-token.sh
RUN set -ex \
    && curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /opt \
    && /opt/aws/install -i /usr/local/aws-cli -b /usr/local/bin --update \
    && rm /tmp/awscliv2.zip \
    && rm -rf /opt/aws \
    && pip3 --no-cache-dir install git-remote-codecommit \
    && aws --version

# WSL
COPY --chmod=755 dockerd.sh /dockerd.sh
COPY wsl.conf /etc/wsl.conf
COPY ps1.txt /opt/ps1.txt
RUN set -ex \
    && mkdir -p /etc/docker \
    && addgroup -g 133 docker || true \
    && echo 'ubuntu ALL=(ALL) NOPASSWD: /dockerd.sh' > /etc/sudoers.d/99-dockerd \
    && useradd -s /bin/bash -d /home/ubuntu -G sudo,docker -m ubuntu \
    && echo "ubuntu:ubuntu" | chpasswd \
    && grep ubuntu /etc/subuid || echo 'ubuntu:165536:65536' >> /etc/subuid \
    && grep ubuntu /etc/subgid || echo 'ubuntu:165536:65536' >> /etc/subgid \
    && locale-gen en_US.UTF-8 \
    && update-alternatives --set iptables /usr/sbin/iptables-legacy \
    && update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy \
    && echo "none /tmp tmpfs defaults 0 0" | tee -a /etc/fstab \
    && cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime \
    && echo "America/Sao_Paulo" | tee /etc/timezone \
    && for i in $(echo /home/*/.bashrc /etc/skel/.bashrc /root/.bashrc); do cat /opt/ps1.txt >> $i; done

COPY daemon.json /etc/docker/daemon.json
COPY --chown=ubuntu:ubuntu zprofile /home/ubuntu/.zprofile
COPY --chown=ubuntu:ubuntu profile /home/ubuntu/.profile
COPY --chown=ubuntu:ubuntu zshrc /home/ubuntu/.zshrc



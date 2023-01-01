# WSL Requirements
```
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```
```
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```
```
dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V /all /norestart
```
```
# reboot
shutdown.exe -r -t 00
```
# Update WSL
```
curl.exe -L# -o wsl_update_x64.msi https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
```
```
msiexec /i wsl_update_x64.msi
```
```
wsl --update
```
```
# reboot
shutdown.exe -r -t 00
```
# Install WSL Ubuntu 22.04
# Download Appx Image
```
curl.exe -L# -o ubuntu-2204.appx https://aka.ms/wslubuntu2204
```
# Install Appx Image  from powershell
```
Add-AppxPackage ubuntu-2204.appx
```

# WSL Initial Setup
```
wsl -l -v
wsl --set-default-version 2

ubuntu.exe

```
# Set iptables-legacy and fix /tmp
```
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
echo "none  /tmp  tmpfs  defaults  0 0" | sudo tee -a /etc/fstab
sudo rm -rf /tmp/*
sudo mount /tmp
```
# Docker Ubuntu WSL
```
curl -fsSL https://raw.githubusercontent.com/WiltonCarvalho/wsl/main/dockerd_install.sh \
  -o dockerd_install.sh
chmod +x dockerd_install.sh
sudo ./dockerd_install.sh
```
# WSL Data Volume
```
New-VHD -Path $env:USERPROFILE\WSL_DATA.vhdx -Dynamic -SizeBytes 10GB

wsl -d Ubuntu --mount --vhd $env:USERPROFILE\WSL_DATA.vhdx --bare

wsl

sudo su -
lsblk | grep 10G
parted /dev/sdc print
parted /dev/sdc mklabel gpt
parted -a optimal /dev/sdc mkpart primary ext4 0% 100%
mkfs.ext4 -L WSL_DATA /dev/sdc1
mkdir /tmp/WSL_DATA
mount /dev/sdc1 /tmp/WSL_DATA
df -h /tmp/WSL_DATA
chown -R 1000:1000 /tmp/WSL_DATA
umount /tmp/WSL_DATA
exit
exit

wsl -d Ubuntu --unmount \\?\$env:USERPROFILE\WSL_DATA.vhdx
wsl --shutdown
wsl --mount --vhd $env:USERPROFILE\WSL_DATA.vhdx --partition 1 --type ext4 --name WSL_DATA
wsl
df -h /mnt/wsl/WSL_DATA
```
```
cat <<'EOF'> /mount-vhd.sh
#!/bin/bash
set -e
if ! df -h /mnt/wsl/WSL_DATA &> /dev/null; then
        powershell.exe 'wsl --mount --vhd $env:USERPROFILE\WSL_DATA.vhdx --partition 1 --type ext4 --name WSL_DATA'
else
        echo "The disk already mounted as '/mnt/wsl/WSL_DATA'."
        echo 'To unmount and detach the disk, run' 'powershell.exe '\''wsl -d Ubuntu --unmount \\?\$env:USERPROFILE\WSL_DATA.vhdx'\'
fi
EOF
```
```
chmod +x /mount-vhd.sh

echo 'source /mount-vhd.sh' >> $HOME/.profile
```
# Podman Ubuntu WSL
```
sudo apt update
```
```
sudo apt install qemu-user-static podman buildah skopeo jq
sudo /etc/init.d/binfmt-support restart
```
```
podman run -d --rm -p 8080:80 --name nginx docker.io/library/nginx:stable
```
```
curl http://localhost:8080
podman logs nginx
podman stop nginx
```
```
echo ok > index.html

cat <<'EOF'> Dockerfile
FROM docker.io/library/nginx:stable
COPY index.html /usr/share/nginx/html/index.html
EOF
```
```
podman build -t website:v1 .
podman run -d --rm -p 8080:80 --name nginx website:v1
curl http://localhost:8080
podman logs nginx
podman stop nginx
```
# Podman Alpine WSL
- https://apps.microsoft.com/store/detail/alpine-wsl/9P804CRF0395
```
su -c "
  set -ex
  apk add libstdc++ tzdata sudo tmux jq curl git podman buildah skopeo
  echo "$USER" 'ALL=(ALL:ALL) NOPASSWD: ALL' | tee /etc/sudoers.d/$USER
  echo 'none  /tmp  tmpfs  defaults  0 0' | tee -a /etc/fstab
  rm -rf /tmp/*
  mount /tmp
  echo $USER:100000:65536 | tee /etc/subuid
  echo $USER:100000:65536 | tee /etc/subgid
  cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
  echo "America/Sao_Paulo" | tee /etc/timezone
"
```
# Restart WSL
```
wsl.exe --shutdown
wsl --exec ash
podman ps
```
# Podman Docker CLI
```
sudo apk add docker-cli netcat-openbsd

cat <<'EOF'> .profile
if ! nc -z 127.0.0.1 2376; then
  nohup podman system service --time=0 tcp:127.0.0.1:2376 &
fi
export DOCKER_HOST=tcp://127.0.0.1:2376
EOF
```
# MS OpenJDK
```
winget search Microsoft.OpenJDK
```
```
winget install Microsoft.OpenJDK.11
```
# Git
```
winget install --id Git.Git -e --source winget
```

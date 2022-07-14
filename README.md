# WSL
```
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```
```
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```
```
curl.exe -L# -o wsl_update_x64.msi https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
```
```
msiexec /i wsl_update_x64.msi
```
# Install WSL Ubuntu 22.04
- From App Store
- https://apps.microsoft.com/store/detail/ubuntu-2204-lts/9PN20MSR04DW
```
# From Winget
winget search -s winget Ubuntu
winget install -e --id Canonical.Ubuntu

# From Appx Image
curl.exe -L# -o ubuntu-2204.appx https://aka.ms/wslubuntu2204
```
# Install Appx Image
```
dism.exe /online /add-ProvisionedAppxPackage /PackagePath:ubuntu-2204.appx /SkipLicense

# OR

Add-AppxPackage ubuntu-2204.appx
```

# WSL Initial Setup
```
wsl -l -v
wsl --set-default-version 2

ubuntu2204.exe

wsl.exe --shutdown
wsl --exec bash
```
# Set iptables-legacy and fix /tmp
```
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
echo "none  /tmp  tmpfs  defaults  0 0" | sudo tee -a /etc/fstab
sudo rm -rf /tmp/*
sudo mount /tmp
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
su -c "apk add libstdc++ podman buildah skopeo jq curl git"
su -c 'echo "none  /tmp  tmpfs  defaults  0 0" | tee -a /etc/fstab'
su -c "rm -rf /tmp/*"
su -c "mount /tmp"
su -c "echo $USER:100000:65536 | tee /etc/subuid
su -c "echo $USER:100000:65536 | tee /etc/subgid"
```

# Restart WSL
```
wsl.exe --shutdown
wsl --exec ash
podman ps
```

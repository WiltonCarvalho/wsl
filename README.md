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
```
curl.exe -L# -o ubuntu-2204.appx https://aka.ms/wslubuntu2204
```
```
Add-AppxPackage ubuntu-2204.appx
```
```
wsl -l -v
```
# Podman
```
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
echo "none  /tmp  tmpfs  defaults  0 0" | sudo tee -a /etc/fstab
rm /tmp/*
mount /tmp
```
```
apt update
```
```
sudo apt install qemu-user-static podman buildah skopeo jq
sudo /etc/init.d/binfmt-support restart
```
```
podman run -d --rm -p 8080:80 --name nginx docker.io/library/nginx:stable
```
```
curl localhost:8080
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
curl localhost:8080
```

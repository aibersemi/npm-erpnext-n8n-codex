#!/usr/bin/env bash
set -euo pipefail
trap 'echo "[ERROR] Line $LINENO failed"; exit 1' ERR

# Deps
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg

# Repo Docker resmi (jammy)
sudo install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
fi
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# Install Docker Engine + Compose plugin
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable & start Docker
sudo systemctl enable --now docker

# (opsional) tambah user aktif ke grup docker agar tak perlu sudo
if ! id -nG "$USER" | grep -qw docker; then
  sudo usermod -aG docker "$USER" || true
fi

# Buat network "proxy" bila belum ada
if ! sudo docker network inspect proxy >/dev/null 2>&1; then
  sudo docker network create --driver bridge proxy
fi

# Ringkasan
echo "[INFO] Versions:"
docker --version
docker compose version
echo "[INFO] Networks:"
sudo docker network ls | grep proxy || true

echo "OK"

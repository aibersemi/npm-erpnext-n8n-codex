# Docker Setup

Run the installer to provision Docker Engine, Docker Compose plugin, and the shared `proxy` network.

```bash
chmod +x infra/docker/install_docker.sh
./infra/docker/install_docker.sh
```

Verify the installation:

```bash
docker --version
docker compose version
sudo docker network ls | grep proxy || true
```

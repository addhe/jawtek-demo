#!/bin/bash
# ============================================================
# Startup Script: Docker + Docker Compose + Ops Agent
# ============================================================

set -euo pipefail

# --- Logging ---
exec > >(tee /var/log/startup-script.log) 2>&1
echo "[$(date)] Startup script started"

# --- Update & install basics ---
apt-get update
apt-get upgrade -y
apt-get install -y \
  curl \
  wget \
  git \
  jq \
  ca-certificates \
  gnupg \
  lsb-release \
  apt-transport-https \
  software-properties-common

# --- Install Docker ---
echo "[$(date)] Installing Docker..."

# Add Docker GPG key and repo
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Add default user to docker group (if OS Login user exists)
usermod -aG docker $USER 2>/dev/null || true

echo "[$(date)] Docker installed: $(docker --version)"

# --- Install Docker Compose (standalone v2) ---
echo "[$(date)] Installing Docker Compose..."
DOCKER_COMPOSE_VERSION="2.24.5"
curl -SL "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-$(uname -m)" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

echo "[$(date)] Docker Compose installed: $(docker-compose --version)"

# --- Install Google Cloud Ops Agent ---
echo "[$(date)] Installing Ops Agent..."
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install

# Wait for Ops Agent to be ready
sleep 10

# Copy custom Ops Agent config (if mounted via metadata)
OPS_CONFIG=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/ops-agent-config" 2>/dev/null || echo "")
if [ -n "$OPS_CONFIG" ]; then
  echo "$OPS_CONFIG" > /etc/google-cloud-ops-agent/config.yaml
  systemctl restart google-cloud-ops-agent
  echo "[$(date)] Ops Agent config applied from metadata."
else
  echo "[$(date)] No custom Ops Agent config found in metadata, using default."
fi

echo "[$(date)] Ops Agent installed and running."

# --- Final status ---
echo "[$(date)] Startup script completed!"
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker-compose --version)"
echo "Ops Agent: $(systemctl is-active google-cloud-ops-agent)"

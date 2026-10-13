#!/usr/bin/env bash
#
# script-install-docker.sh
# Install and enable Docker on an Amazon Linux EC2 instance
# (Amazon Linux 2023 uses dnf, Amazon Linux 2 uses yum).
#
# Usage: ./script-install-docker.sh

set -euo pipefail

TARGET_USER="${SUDO_USER:-$USER}"

# Pick the available package manager
if command -v dnf >/dev/null 2>&1; then
  PKG_MANAGER="dnf"
elif command -v yum >/dev/null 2>&1; then
  PKG_MANAGER="yum"
else
  echo "ERROR: neither dnf nor yum found. This script targets Amazon Linux." >&2
  exit 1
fi

echo ">>> Updating system packages with ${PKG_MANAGER}"
sudo "${PKG_MANAGER}" update -y

echo ">>> Installing Docker"
sudo "${PKG_MANAGER}" install -y docker

echo ">>> Enabling and starting the Docker service"
sudo systemctl enable --now docker

echo ">>> Adding '${TARGET_USER}' to the docker group"
sudo usermod -aG docker "${TARGET_USER}"

echo ">>> Docker version:"
sudo docker --version

echo
echo "Done. Log out and log back in (or run 'newgrp docker') so that"
echo "'${TARGET_USER}' can run Docker without sudo, then test with:"
echo "  docker run --rm hello-world"
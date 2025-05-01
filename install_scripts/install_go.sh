#!/bin/bash

set -e

# Fetch latest stable version from official Go site
LATEST_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n1)
GO_TAR="${LATEST_VERSION}.linux-amd64.tar.gz"
GO_URL="https://dl.google.com/go/${GO_TAR}"
INSTALL_DIR="/usr/local"

echo "Latest Go version is: ${LATEST_VERSION}"

# Remove any previous Go installation
echo "Removing existing Go installation (if any)..."
sudo rm -rf "${INSTALL_DIR}/go"

# Download latest Go
echo "Downloading ${GO_URL}..."
wget -q "${GO_URL}" -O "/tmp/${GO_TAR}"
echo "Finished downloading"

# Extract to /usr/local
echo "Installing Go..."
sudo tar -C "${INSTALL_DIR}" -xzf "/tmp/${GO_TAR}"
rm "/tmp/${GO_TAR}"

# Verify
echo "Go installation complete."
go version

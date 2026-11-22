#!/bin/sh
# Download a pinned MinIO Client (mc) release from GitHub.
# This script is run during Docker build

set -e

ARCH=$(uname -m)
MC_VERSION="RELEASE.2025-08-13T08-35-41Z"

echo "[BUILD] Downloading MinIO Client (mc) for ${ARCH}..."

case "$ARCH" in
    x86_64)
        MC_ARCH="linux-amd64"
        MC_SHA256="01f866e9c5f9b87c2b09116fa5d7c06695b106242d829a8bb32990c00312e891"
        ;;
    aarch64|arm64)
        MC_ARCH="linux-arm64"
        MC_SHA256="14c8c9616cfce4636add161304353244e8de383b2e2752c0e9dad01d4c27c12c"
        ;;
    *)
        echo "[BUILD] Unsupported architecture: $ARCH"
        echo "[BUILD] MinIO Client will not be available"
        exit 1
        ;;
esac

DOWNLOAD_URL="https://github.com/minio/mc/releases/download/${MC_VERSION}/mc.${MC_ARCH}.${MC_VERSION}"

echo "[BUILD] Downloading from: $DOWNLOAD_URL"

# Download with retry
MAX_RETRIES=3
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if wget -O /tmp/mc "$DOWNLOAD_URL" 2>/dev/null; then
        echo "[BUILD] ✓ Download successful"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "[BUILD] Download failed, retry $RETRY_COUNT/$MAX_RETRIES..."
    sleep 2
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "[BUILD] ✗ Failed to download MinIO Client after $MAX_RETRIES attempts"
    exit 1
fi

# Verify the pinned release artifact before installing it.
echo "${MC_SHA256}  /tmp/mc" | sha256sum -c -

# Install binary
chmod +x /tmp/mc
mv /tmp/mc /usr/local/bin/mc

echo "[BUILD] ✓ MinIO Client (mc) installed successfully"
/usr/local/bin/mc --version

exit 0
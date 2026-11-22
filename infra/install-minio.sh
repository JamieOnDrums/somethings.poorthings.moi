#!/bin/sh
# Download a pinned MinIO Server release from GitHub.
# This script is run during Docker build

set -e

MINIO_VERSION="RELEASE.2024-10-13T13-34-11Z"
ARCH=$(uname -m)

echo "[BUILD] Downloading storage system ${MINIO_VERSION} for ${ARCH}..."

case "$ARCH" in
    x86_64)
        MINIO_ARCH="linux-amd64"
        MINIO_SHA256="1126bbb3276321e7fed0167682d92a03572862f73802658f616af43d9a951e6a"
        ;;
    aarch64|arm64)
        MINIO_ARCH="linux-arm64"
        MINIO_SHA256="d89a1c767182fb599b975b6177b517b17b3bee2d0948dcef4adfd0b886a09354"
        ;;
    *)
        echo "[BUILD] Unsupported architecture: $ARCH"
        echo "[BUILD] Palmr will fallback to external S3"
        exit 0
        ;;
esac

DOWNLOAD_URL="https://github.com/minio/minio/releases/download/${MINIO_VERSION}/minio.${MINIO_ARCH}.${MINIO_VERSION}"

echo "[BUILD] Downloading from: $DOWNLOAD_URL"

# Download with retry
MAX_RETRIES=3
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if wget -O /tmp/minio "$DOWNLOAD_URL" 2>/dev/null; then
        echo "[BUILD] ✓ Download successful"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "[BUILD] Download failed, retry $RETRY_COUNT/$MAX_RETRIES..."
    sleep 2
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "[BUILD] ✗ Failed to download MinIO Server after $MAX_RETRIES attempts"
    exit 1
fi

# Verify the pinned release artifact before installing it.
echo "${MINIO_SHA256}  /tmp/minio" | sha256sum -c -

# Install binary
chmod +x /tmp/minio
mv /tmp/minio /usr/local/bin/minio

echo "[BUILD] ✓ Storage system installed successfully"
/usr/local/bin/minio --version

exit 0



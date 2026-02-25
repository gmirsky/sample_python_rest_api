#!/usr/bin/env bash
# Exit on errors, undefined vars, and pipeline failures.
set -euo pipefail

# Output directory for generated cert and key.
OUT_DIR="${1:-certs}"
# Certificate validity period in days.
DAYS_VALID="${2:-365}"

# Ensure output directory exists.
mkdir -p "$OUT_DIR"

# Generate a self-signed TLS cert and private key for localhost.
openssl req -x509 -nodes -newkey rsa:4096 \
  -keyout "$OUT_DIR/server.key" \
  -out "$OUT_DIR/server.crt" \
  -days "$DAYS_VALID" \
  -subj "/CN=localhost"

# Print generated file locations.
echo "Generated TLS certificate and key:"
echo "- $OUT_DIR/server.crt"
echo "- $OUT_DIR/server.key"

#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-certs}"
DAYS_VALID="${2:-365}"

mkdir -p "$OUT_DIR"

openssl req -x509 -nodes -newkey rsa:4096 \
  -keyout "$OUT_DIR/server.key" \
  -out "$OUT_DIR/server.crt" \
  -days "$DAYS_VALID" \
  -subj "/CN=localhost"

echo "Generated TLS certificate and key:"
echo "- $OUT_DIR/server.crt"
echo "- $OUT_DIR/server.key"

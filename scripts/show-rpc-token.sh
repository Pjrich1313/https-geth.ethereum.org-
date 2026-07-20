#!/usr/bin/env bash
# show-rpc-token.sh
# Prints a short-lived JWT bearer token for the Pamela Coin authenticated RPC.
#
# Usage:
#   ./scripts/show-rpc-token.sh
#
# The token is valid for 60 seconds and can be used like:
#   curl -X POST http://localhost:8551 \
#     -H "Content-Type: application/json" \
#     -H "Authorization: ******" \
#     -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

set -euo pipefail

DATADIR="${PAMELA_DATADIR:-$HOME/.pamela}"
JWT_FILE="$DATADIR/jwt.hex"

if [ ! -f "$JWT_FILE" ]; then
  echo "ERROR: JWT secret not found at $JWT_FILE" >&2
  echo "Run ./scripts/init-pamela-network.sh first." >&2
  exit 1
fi

SECRET=$(cat "$JWT_FILE" | tr -d '[:space:]')

# Generate a HS256 JWT with {"iat":<now>} payload using Python 3 (no extra deps).
if command -v python3 &> /dev/null; then
  python3 - "$SECRET" <<'EOF'
import sys, json, hmac, hashlib, base64, time

def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()

secret_hex = sys.argv[1]
secret = bytes.fromhex(secret_hex)

header  = b64url(json.dumps({"alg":"HS256","typ":"JWT"}, separators=(",",":")).encode())
payload = b64url(json.dumps({"iat": int(time.time())},   separators=(",",":")).encode())

sig_input = f"{header}.{payload}".encode()
sig = hmac.new(secret, sig_input, hashlib.sha256).digest()

print(f"{header}.{payload}.{b64url(sig)}")
EOF
else
  echo "ERROR: python3 is required to generate a JWT token." >&2
  exit 1
fi

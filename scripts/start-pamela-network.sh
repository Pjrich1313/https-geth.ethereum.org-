#!/usr/bin/env bash
# start-pamela-network.sh
# Starts a Pamela Coin private development node.
# Run ./scripts/init-pamela-network.sh first if this is a fresh install.

set -euo pipefail

# ============================================================
# SECURITY WARNING
# This script is intended for LOCAL DEVELOPMENT ONLY.
#
# - HTTP RPC and WebSocket are bound to 127.0.0.1 (localhost).
#   Do NOT expose these ports to a public network.
# - CORS and WebSocket origins are set to '*' for development
#   convenience. Restrict them in any networked environment.
# - The sealer account is unlocked with an empty password via
#   /dev/null. This is safe only on an isolated local machine.
#   NEVER run this configuration on a shared or internet-facing
#   host.
# ============================================================

DATADIR="${PAMELA_DATADIR:-$HOME/.pamela}"
NETWORK_ID=1313
HTTP_PORT=8545
WS_PORT=8546
AUTH_PORT=8551
P2P_PORT=30313
JWT_FILE="$DATADIR/jwt.hex"

# Clique sealer account (Account 0 - dev only, never use in production)
SEALER="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"

if ! command -v geth &> /dev/null; then
  echo "ERROR: geth is not installed or not in PATH." >&2
  echo "Install geth: https://geth.ethereum.org/docs/getting-started/installing-geth" >&2
  exit 1
fi

if [ ! -d "$DATADIR/geth" ]; then
  echo "ERROR: Data directory $DATADIR has not been initialized." >&2
  echo "Run ./scripts/init-pamela-network.sh first." >&2
  exit 1
fi

# Generate JWT secret if missing (e.g. carried over from an old init run)
if [ ! -f "$JWT_FILE" ]; then
  echo "JWT secret not found — generating one now..."
  if command -v openssl &> /dev/null; then
    openssl rand -hex 32 > "$JWT_FILE"
  elif command -v python3 &> /dev/null; then
    python3 -c "import secrets; print(secrets.token_hex(32))" > "$JWT_FILE"
  else
    echo "ERROR: openssl or python3 is required to generate the JWT secret." >&2
    exit 1
  fi
  chmod 600 "$JWT_FILE"
fi

echo "=== Starting Pamela Coin Development Node ==="
echo "Data directory   : $DATADIR"
echo "Network ID       : $NETWORK_ID"
echo "HTTP RPC         : http://localhost:$HTTP_PORT  (unauthenticated, localhost only)"
echo "WebSocket        : ws://localhost:$WS_PORT     (unauthenticated, localhost only)"
echo "Auth RPC (JWT)   : http://localhost:$AUTH_PORT  (JWT-protected)"
echo "JWT secret file  : $JWT_FILE"
echo ""
echo "To get a ready-to-use JWT bearer token run:"
echo "  ./scripts/show-rpc-token.sh"
echo ""
echo "Press Ctrl+C to stop the node."
echo ""

exec geth \
  --datadir "$DATADIR" \
  --networkid "$NETWORK_ID" \
  --http \
  --http.addr "127.0.0.1" \
  --http.port "$HTTP_PORT" \
  --http.api "eth,net,web3,personal,miner,clique,txpool,debug" \
  --http.corsdomain "*" \
  --ws \
  --ws.addr "127.0.0.1" \
  --ws.port "$WS_PORT" \
  --ws.api "eth,net,web3,personal,miner,clique,txpool,debug" \
  --ws.origins "*" \
  --authrpc.addr "127.0.0.1" \
  --authrpc.port "$AUTH_PORT" \
  --authrpc.vhosts "localhost" \
  --authrpc.jwtsecret "$JWT_FILE" \
  --port "$P2P_PORT" \
  --mine \
  --miner.etherbase "$SEALER" \
  --unlock "$SEALER" \
  --password /dev/null \
  --allow-insecure-unlock \
  --nodiscover \
  --verbosity 3 \
  console

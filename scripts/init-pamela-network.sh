#!/usr/bin/env bash
# init-pamela-network.sh
# Initializes the Pamela Coin private development blockchain.
# Run this script once before starting the network for the first time.

set -euo pipefail

DATADIR="${PAMELA_DATADIR:-$HOME/.pamela}"
GENESIS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/genesis-pamela.json"

if ! command -v geth &> /dev/null; then
  echo "ERROR: geth is not installed or not in PATH." >&2
  echo "Install geth: https://geth.ethereum.org/docs/getting-started/installing-geth" >&2
  exit 1
fi

if [ ! -f "$GENESIS" ]; then
  echo "ERROR: genesis file not found at $GENESIS" >&2
  exit 1
fi

echo "=== Pamela Coin Network Initialization ==="
echo "Data directory : $DATADIR"
echo "Genesis file   : $GENESIS"
echo ""

if [ -d "$DATADIR/geth" ]; then
  echo "WARNING: Data directory already exists at $DATADIR"
  read -r -p "Re-initialize? This will delete existing chain data. [y/N] " confirm
  case "$confirm" in
    [yY][eE][sS]|[yY])
      rm -rf "$DATADIR/geth"
      ;;
    *)
      echo "Aborted."
      exit 0
      ;;
  esac
fi

geth init --datadir "$DATADIR" "$GENESIS"

# Generate a JWT secret for the authenticated RPC endpoint.
JWT_FILE="$DATADIR/jwt.hex"
if [ ! -f "$JWT_FILE" ]; then
  if command -v openssl &> /dev/null; then
    openssl rand -hex 32 > "$JWT_FILE"
  elif command -v python3 &> /dev/null; then
    python3 -c "import secrets; print(secrets.token_hex(32))" > "$JWT_FILE"
  else
    echo "ERROR: openssl or python3 is required to generate the JWT secret." >&2
    exit 1
  fi
  chmod 600 "$JWT_FILE"
  echo "JWT secret generated : $JWT_FILE"
fi

echo ""
echo "=== Initialization complete ==="
echo "Run ./scripts/start-pamela-network.sh to start the node."

#!/usr/bin/env bash
# start-pamela-network.sh
# Starts a Pamela Coin private development node.
# Run ./scripts/init-pamela-network.sh first if this is a fresh install.

set -euo pipefail

DATADIR="${PAMELA_DATADIR:-$HOME/.pamela}"
NETWORK_ID=1313
HTTP_PORT=8545
WS_PORT=8546
P2P_PORT=30313

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

echo "=== Starting Pamela Coin Development Node ==="
echo "Data directory : $DATADIR"
echo "Network ID     : $NETWORK_ID"
echo "HTTP RPC       : http://localhost:$HTTP_PORT"
echo "WebSocket      : ws://localhost:$WS_PORT"
echo "P2P Port       : $P2P_PORT"
echo ""
echo "Press Ctrl+C to stop the node."
echo ""

exec geth \
  --datadir "$DATADIR" \
  --networkid "$NETWORK_ID" \
  --http \
  --http.addr "0.0.0.0" \
  --http.port "$HTTP_PORT" \
  --http.api "eth,net,web3,personal,miner,clique,txpool,debug" \
  --http.corsdomain "*" \
  --ws \
  --ws.addr "0.0.0.0" \
  --ws.port "$WS_PORT" \
  --ws.api "eth,net,web3,personal,miner,clique,txpool,debug" \
  --ws.origins "*" \
  --port "$P2P_PORT" \
  --mine \
  --miner.etherbase "$SEALER" \
  --unlock "$SEALER" \
  --password /dev/null \
  --allow-insecure-unlock \
  --nodiscover \
  --verbosity 3 \
  console

# Pamela Private Development Network

This guide explains how to run a private **Pamela Coin** development blockchain using `geth`.
Pamela Coin uses Clique proof-of-authority (PoA) consensus, which is ideal for local
development because it produces blocks at a predictable rate without requiring mining power.

## Network Parameters

| Parameter      | Value                         |
|----------------|-------------------------------|
| Network name   | Pamela                        |
| Chain ID       | `1313`                        |
| Network ID     | `1313`                        |
| Consensus      | Clique PoA                    |
| Block period   | 5 seconds                     |
| Gas limit      | 30,000,000                    |
| Genesis file   | `genesis-pamela.json`         |

## Pre-funded Development Accounts

> **⚠️ WARNING — DEV ONLY**  
> These private keys are publicly known and must **never** be used on any public or
> production network. They are provided solely for local development and testing.

| # | Address | Private Key |
|---|---------|-------------|
| 0 | `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266` | `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80` |
| 1 | `0x70997970C51812dc3A010C7d01b50e0d17dc79C8` | `0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d` |
| 2 | `0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC` | `0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a` |
| 3 | `0x90F79bf6EB2c4f870365E785982E1f101E93b906` | `0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6` |
| 4 | `0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65` | `0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a` |

Each account is pre-funded with **10,000 PAMELA** (10,000 × 10¹⁸ wei) in the genesis block.

Account `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266` is also the initial Clique PoA sealer
(block signer). Blocks will be produced automatically once the node is running.

## Quick Start

### Prerequisites

Build `geth` from this repository:

```sh
make geth
```

Or install a released binary from [https://geth.ethereum.org/downloads](https://geth.ethereum.org/downloads).

### 1. Initialise the Pamela data directory

```sh
geth init --datadir ~/.pamela genesis-pamela.json
```

This creates the genesis block and writes the initial chain state under `~/.pamela`.

### 2. Import the sealer account

Import account `0` (the Clique sealer) into geth's keystore so the node can sign blocks:

```sh
geth account import --datadir ~/.pamela <(echo -n "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80")
```

Enter a password when prompted (use something simple like `pamela` for dev). Note the
address printed — it should be `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`.

### 3. Start the Pamela node

```sh
geth \
  --datadir ~/.pamela \
  --networkid 1313 \
  --http \
  --http.api eth,net,web3,personal,miner,admin \
  --http.corsdomain "*" \
  --http.addr 0.0.0.0 \
  --http.port 8545 \
  --ws \
  --ws.api eth,net,web3,personal \
  --ws.addr 0.0.0.0 \
  --ws.port 8546 \
  --unlock 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 \
  --password <(echo "pamela") \
  --mine \
  --miner.etherbase 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 \
  console
```

The node will begin producing blocks every ~5 seconds automatically.

### 4. Verify the node is running

Inside the `geth` console:

```javascript
// Check the current block number
eth.blockNumber

// Check your account balance (should be 10000 PAMELA)
eth.getBalance("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")

// List connected peers
net.peerCount
```

## Connecting a Second Node

To create a small private test network with multiple nodes:

### On the first node, get the enode URL

In the first node's console:

```javascript
admin.nodeInfo.enode
// Returns something like:
// "enode://PUBKEY@127.0.0.1:30303"
```

### Start a second node

```sh
geth \
  --datadir ~/.pamela2 \
  --networkid 1313 \
  --port 30304 \
  --bootnodes "enode://PUBKEY@127.0.0.1:30303" \
  console
```

Replace `PUBKEY` with the value from `admin.nodeInfo.enode` on the first node.

### Verify peering

On either node:

```javascript
net.peerCount   // Should be 1 or more
admin.peers     // Lists connected peers
```

## Sending a Transaction

Inside the geth console:

```javascript
// Unlock an account for a single transaction
personal.unlockAccount("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", "pamela", 60)

// Send 1 PAMELA to account #1
eth.sendTransaction({
  from: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  to:   "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
  value: web3.toWei(1, "ether")
})
```

## Resetting the Network

To wipe state and start fresh:

```sh
rm -rf ~/.pamela
geth init --datadir ~/.pamela genesis-pamela.json
```

## JSON-RPC Access

Once the HTTP server is enabled (`--http`), you can interact with the node from any
web3-compatible tool or library:

```
RPC endpoint:  http://localhost:8545
WS endpoint:   ws://localhost:8546
Chain ID:      1313
```

Example with `curl`:

```sh
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

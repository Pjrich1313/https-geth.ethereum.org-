# Pamela Coin — Private Development Network

Pamela Coin is a private Ethereum-compatible development blockchain built on top of [go-ethereum (geth)](https://geth.ethereum.org/). It uses **Clique Proof-of-Authority (PoA)** consensus so blocks seal instantly without any mining hardware or stake. The network is intended for local development and testing only — **never use the dev accounts or this configuration on mainnet or any public testnet**.

---

## Network Details

| Parameter          | Value                                      |
|--------------------|--------------------------------------------|
| Chain ID           | `1313`                                     |
| Network ID         | `1313`                                     |
| Consensus          | Clique PoA (Proof of Authority)            |
| Block time         | 5 seconds                                  |
| Gas limit (genesis)| 8,000,000                                  |
| HTTP RPC           | `http://localhost:8545`                    |
| WebSocket          | `ws://localhost:8546`                      |
| P2P port           | `30313`                                    |

---

## Quick Start

### Prerequisites

- [geth](https://geth.ethereum.org/docs/getting-started/installing-geth) v1.14+ installed and on your `PATH`
- Bash-compatible shell (Linux, macOS, WSL)

### 1. Initialize the genesis block (run once)

```bash
./scripts/init-pamela-network.sh
```

This writes the Pamela genesis block into `~/.pamela/` (or the directory set by `$PAMELA_DATADIR`).

### 2. Start a node

```bash
./scripts/start-pamela-network.sh
```

The node starts with HTTP RPC, WebSocket, and the interactive JavaScript console enabled.

### 3. Connect via RPC

Any Ethereum tooling (Hardhat, Foundry, Remix, ethers.js, web3.js) can connect using:

- **HTTP**: `http://localhost:8545`
- **WebSocket**: `ws://localhost:8546`
- **Chain ID / Network ID**: `1313`

Example (cast):

```bash
cast block-number --rpc-url http://localhost:8545
```

Example (ethers.js):

```js
const provider = new ethers.JsonRpcProvider("http://localhost:8545");
```

### 4. Deploy contracts and send transactions

Use any of the pre-funded development accounts below. For example, using Foundry:

```bash
forge create src/MyContract.sol:MyContract \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

---

## Development Accounts

> ⚠️  **WARNING: DEVELOPMENT USE ONLY**
>
> These accounts and private keys are publicly known. They are pre-seeded in every Pamela development network. **Never use them on mainnet, Holesky, Sepolia, or any other public network. Never send real ETH to these addresses.**

Each account starts with **1,000,000 ETH** on the Pamela network.

| # | Address | Private Key |
|---|---------|-------------|
| 0 (sealer) | `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266` | `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80` |
| 1 | `0x70997970C51812dc3A010C7d01b50e0d17dc79C8` | `0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d` |
| 2 | `0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC` | `0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a` |
| 3 | `0x90F79bf6EB2c4f870365E785982E1f101E93b906` | `0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6` |
| 4 | `0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65` | `0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926b` |

Account 0 is also the Clique sealer — it produces all blocks while the node is running.

---

## Useful Commands

All commands below assume the node is running and reachable at `http://localhost:8545`.

### Check balance (geth console)

```js
web3.fromWei(eth.getBalance("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"), "ether")
```

### Check balance (cast)

```bash
cast balance 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 \
  --rpc-url http://localhost:8545 --ether
```

### Send a transaction (geth console)

```js
eth.sendTransaction({
  from: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  to:   "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
  value: web3.toWei(1, "ether")
})
```

### Send a transaction (cast)

```bash
cast send 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 \
  --value 1ether \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

### Check current block (geth console)

```js
eth.blockNumber
```

### List current peers (geth console)

```js
admin.peers
```

---

## Multi-Node Setup

To connect a second node to the Pamela network:

1. **Start the first node** and get its enode URL:

   ```js
   admin.nodeInfo.enode
   // "enode://PUBKEY@IP:30313"
   ```

2. **Initialize the second node** with the same genesis:

   ```bash
   PAMELA_DATADIR=~/.pamela2 ./scripts/init-pamela-network.sh
   ```

3. **Start the second node** on a different port:

   ```bash
   geth \
     --datadir ~/.pamela2 \
     --networkid 1313 \
     --port 30314 \
     --http --http.port 8546 \
     --bootnodes "enode://PUBKEY@127.0.0.1:30313"
   ```

4. **Add the peer manually** from the first node's console if autodiscovery is disabled:

   ```js
   admin.addPeer("enode://PUBKEY@127.0.0.1:30314")
   ```

---

## Changing the Data Directory

Set the `PAMELA_DATADIR` environment variable before running either script:

```bash
export PAMELA_DATADIR=/path/to/custom/datadir
./scripts/init-pamela-network.sh
./scripts/start-pamela-network.sh
```

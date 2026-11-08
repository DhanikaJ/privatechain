# privatechain

A small private Ethereum blockchain built with [go-ethereum (geth)](https://geth.ethereum.org/), written for an online blockchain-developer course assignment. It has its own genesis block, its own chain ID, two pre-funded accounts, and a single node that seals a block every 5 seconds.

It's a learning sandbox, not a production network.

## What it does

- Custom genesis (`genesis.template.json`) with chain ID `4242`
- Proof-of-authority consensus (Clique), 5-second block time
- Two funded test accounts, generated fresh on your machine
- Isolated node (no discovery, no peers)
- Scripts to initialise and start the chain on Windows

## Requirements

- [geth](https://geth.ethereum.org/downloads) **1.13.x**, the last release line that can seal Clique blocks. Tested with: _(fill in your version)_
- Windows PowerShell 5.1+

geth 1.14 and later removed Clique block production. On a newer geth, use the dev-mode alternative below.

## Quick start

From the repo root:

```bash
powershell -ExecutionPolicy Bypass -File scripts\init.ps1
```

```bash
powershell -ExecutionPolicy Bypass -File scripts\start.ps1
```

`init.ps1` creates two accounts with a random password, fills in `genesis.template.json`, and initialises the chain in `data/`. `start.ps1` runs the node and begins sealing blocks.

In a second terminal, open a console:

```bash
geth attach
```

Try a few things:

```js
eth.accounts                      // [signer, account2]
eth.blockNumber                   // grows every ~5 seconds
web3.fromWei(eth.getBalance(eth.accounts[1]), "ether")   // 1000 (balances are in wei, so convert to ETH)

// send 1 ETH from the signer to account2
eth.sendTransaction({from: eth.accounts[0], to: eth.accounts[1], value: "0xde0b6b3a7640000"})
web3.fromWei(eth.getBalance(eth.accounts[1]), "ether")   // 1001 once the next block is sealed
```

To start over, stop the node and delete the `data/` folder.

## Newer geth (1.14+)

Use geth's built-in dev mode, which produces blocks on its own. It uses its own pre-funded account and does not use this repo's genesis file:

```bash
geth --dev --dev.period 5 console
```

## Project layout

```
genesis.template.json   chain config and funded accounts (addresses filled in by init.ps1)
scripts/init.ps1        creates accounts, builds genesis.json, runs `geth init`
scripts/start.ps1       starts the node and seals blocks
```

## Security

Everything sensitive is generated locally into `data/`, which is git-ignored: keystores, the node key and the account password. Never commit that folder. The accounts are for this isolated test chain only. Don't reuse a password or key from a real wallet.

## Possible next steps

- Deploy a simple smart contract (Solidity + Remix or Hardhat)
- Add a second node and connect the two with `admin.addPeer`
- Move to a proof-of-stake setup with a consensus client
- Add a macOS/Linux version of the scripts

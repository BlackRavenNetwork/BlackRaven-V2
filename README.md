# BlackRaven V2 (BLKR)

Independent Layer-1 chain based on [Neoxa](https://github.com/NeoxaChain/Neoxa) (MIT), rebranded and re-parameterized for [blackraven.network](https://blackraven.network/).

**Repository:** [BlackRavenNetwork/BlackRaven-V2](https://github.com/BlackRavenNetwork/BlackRaven-V2)

## What is BlackRaven V2?

BlackRaven V2 is a KawPoW proof-of-work blockchain with native asset issuance (Ravencoin-style assets), Dash-derived infrastructure code (governance hooks, BLS, etc.), and **smartnodes disabled** at launch. Block subsidies go to **miners (~99.5%)** and a **fixed 0.5% dev treasury** (basis points on the post-halving subsidy).

V1 ([BlackRavenNetwork/BlackRaven](https://github.com/BlackRavenNetwork/BlackRaven)) remains the separate Ravencoin-lineage tree; this repo is the Neoxa-lineage V2 transition.

## Network parameters (mainnet)

| Parameter | Value |
| --- | --- |
| Ticker | BLKR |
| Consensus | KawPoW |
| Block time | ~60 seconds |
| Initial block reward | 5,000 BLKR |
| Halving interval | 3,200,000 blocks |
| Max supply (asymptotic) | 32,000,000,000 BLKR |
| Reward split | 99.5% miner / 0.5% dev fee |
| Smartnodes | Disabled (`fSmartnodesEnabled=false`) |
| P2P port | 9777 |
| RPC port | 9776 |
| Magic bytes | `BLKR` |
| P2PKH addresses | Prefix `B` (base58 type 25) |
| DNS seeds | `seed1.blackraven.network`, `seed2.blackraven.network`, `seed3.blackraven.network` |
| Genesis (mined) | `0001a5916e8deb24b32cfa5c8b97c0b40685bd7616a40cdc27088ce4c690bd1a` |

Full design notes: [`contrib/blackraven-v2-chain-spec.txt`](contrib/blackraven-v2-chain-spec.txt). Genesis values: [`contrib/genesis-values.h`](contrib/genesis-values.h).

## Binaries

| Binary | Purpose |
| --- | --- |
| `blackravend` | Daemon |
| `blackraven-qt` | GUI wallet |
| `blackraven-cli` | RPC client |
| `blackraven-tx` | Transaction utility |

Default data directory: `~/.blackraven/` (config file: `blackraven.conf`).

## Build from source

See platform guides under [`doc/`](doc/):

- [`doc/build-unix.md`](doc/build-unix.md)
- [`doc/build-osx.md`](doc/build-osx.md)
- [`doc/build-windows.md`](doc/build-windows.md)

Quick Linux build (with depends):

```bash
./build.sh
```

Or manual:

```bash
./autogen.sh
CONFIG_SITE=$PWD/depends/x86_64-pc-linux-gnu/share/config.site ./configure --prefix=$PWD/depends/x86_64-pc-linux-gnu --with-gui
make -j$(nproc) -C src
```

See [INSTALL.md](INSTALL.md).

Berkeley DB 4.8 is required for the wallet; use [`contrib/install_db4.sh`](contrib/install_db4.sh) if needed.

## Minimal `blackraven.conf`

```ini
server=1
listen=1
rpcuser=changeMe
rpcpassword=longRandomStringYouChooseHere
rpcallowip=127.0.0.1
```

## Mining (KawPoW)

After sync, enable built-in CPU mining in `blackraven.conf`:

```ini
gen=1
```

Or use an external KawPoW miner against RPC (`getblocktemplate` / `submitblock`).

## Wallet note

Wallets from Neoxa or BlackRaven v5.x are **not** compatible with v0.1.0. Use a fresh `~/.blackraven` data directory or re-import keys.

Optional indexes (increase disk and sync time):

```ini
txindex=1
addressindex=1
assetindex=1
spentindex=1
```

## Releases

Official release binaries will be published under [BlackRavenNetwork/BlackRaven-V2 releases](https://github.com/BlackRavenNetwork/BlackRaven-V2/releases) when available.

## Development

- Contribution workflow: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Rebrand helper (reference): [`contrib/rebrand-to-blackraven.sh`](contrib/rebrand-to-blackraven.sh)
- String scrub helper: [`contrib/scrub-neoxa-strings.sh`](contrib/scrub-neoxa-strings.sh)

Unit tests: `src/test/test_blackraven` (after build).

## License

MIT — see [`COPYING`](COPYING).

Lineage: Bitcoin → Dash → Ravencoin (assets) / Neoxa (KawPoW integration) → BlackRaven V2.

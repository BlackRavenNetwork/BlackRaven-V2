# BlackRaven v2 genesis and testnet

## Locked mainnet parameters (in `src/chainparams.cpp`)

| Field | Value |
| --- | --- |
| Coinbase message | `BlackRaven BLKR genesis 2026-05-17T02:10:30Z fair launch` |
| `nGenesisTime` | `1778983830` (2026-05-17 02:10:30 UTC) |
| `nBits` | `0x1f0fffff` (KawPoW-friendly; same class as V1 BlackRaven) |
| Subsidy | 5,000 BLKR |

Testnet uses a separate message and time (`1778987430` = +1 hour).

## Mine genesis (required before mainnet/testnet)

Build dependencies (Ubuntu):

```bash
sudo apt-get install build-essential libtool autotools-dev automake pkg-config \
  python3 bsdmainutils libssl-dev libevent-dev libboost-all-dev libgmp-dev \
  libminiupnpc-dev libzmq3-dev cmake
cd ~/BlackRaven-V2/depends && make -j$(nproc)   # provides bls-dash + boost
cd ..
./autogen.sh
./configure --prefix=$(pwd)/depends/x86_64-pc-linux-gnu --without-gui --disable-wallet
```

Mine (CPU; often a few minutes per network):

```bash
./contrib/mine-genesis.sh main
./contrib/mine-genesis.sh test
```

This prints `nNonce`, `nNonce64`, `mix_hash`, `hashGenesisBlock`, and `hashMerkleRoot`.  
Copy them into `contrib/genesis-values.h` and set `BLKR_*_GENESIS_MINED` to `1`, or re-run the script after it is updated to patch the header automatically.

Rebuild:

```bash
make -j$(nproc) blackravend blackraven-cli
```

## Run testnet

```bash
./src/blackravend -testnet -daemon
./src/blackraven-cli -testnet getblockhash 0
./src/blackraven-cli -testnet getnewaddress
```

Default testnet P2P port: **4572**, RPC: **15425**, datadir suffix: `testv9`.

## After genesis is mined

1. Replace BlackRaven-era **`G…` asset burn addresses** with `B…` burns or new constants.
2. Point `testnet.blackraven.network` (or your seed) at a node with the new chain.
3. Smoke-test block 1 subsidy payout to the miner.

Until `BLKR_MAINNET_GENESIS_MINED` is `1`, mainnet asserts are disabled and you should use **testnet** or **regtest** only.

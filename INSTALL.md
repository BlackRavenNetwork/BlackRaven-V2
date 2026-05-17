# Installing BlackRaven Core v0.1.0

## Linux (recommended: depends toolchain)

```bash
git clone https://github.com/BlackRavenNetwork/BlackRaven-V2.git
cd BlackRaven-V2
./build.sh
```

Binaries: `src/blackravend`, `src/blackraven-cli`, `src/qt/blackraven-qt`.

Copy `share/examples/blackraven.conf` to `~/.blackraven/blackraven.conf`.

## Linux (system packages)

```bash
sudo apt install build-essential libtool autotools-dev automake pkg-config \
  libevent-dev libboost-all-dev libssl-dev libzmq3-dev libdb-dev libdb++-dev
./autogen.sh
./configure --with-gui
make -j$(nproc) -C src
```

## Windows (cross-compile from Linux)

See [doc/build-windows.md](doc/build-windows.md). Summary:

```bash
cd depends
make HOST=x86_64-w64-mingw32 -j$(nproc)
cd ..
CONFIG_SITE=$PWD/depends/x86_64-w64-mingw32/share/config.site \
  ./configure --prefix=$PWD/depends/x86_64-w64-mingw32
make -j$(nproc) -C src
```

## macOS

See [doc/build-osx.md](doc/build-osx.md). Use `depends` with `HOST=x86_64-apple-darwin*` and Xcode command-line tools.

## Run

```bash
./src/blackravend -daemon -datadir=$HOME/.blackraven
./src/blackraven-cli getblockchaininfo
./src/qt/blackraven-qt
```

**Ports (mainnet):** P2P `9777`, RPC `9776`. **Testnet:** P2P `19777`, RPC `19776`.

**DNS seeds:** `seed1.blackraven.network`, `seed2.blackraven.network`, `seed3.blackraven.network` (see [SEEDS.md](SEEDS.md)).

## Wallet migration

Wallets from Neoxa or BlackRaven v5.x use a higher internal `minversion` and are **not** compatible with v0.1.0. Export keys from the old client and import into a new v0.1.0 wallet, or use a fresh data directory.

## Genesis

Do not change `contrib/genesis-values.h` or genesis timestamps without re-mining. See `contrib/mine-genesis.sh` and `contrib/GENESIS.md`.

# Changelog

## [0.1.0] - 2026-05-17

### Added
- BlackRaven (BLKR) v2 chain forked from Neoxa with new genesis and network magic (`BLKR`).
- KawPoW mainnet genesis mined; testnet genesis mined (see `contrib/genesis-values.h`).
- Depends build fixes for GCC 11 / Qt 5.9 (BLS relic headers, Qt parallel build).
- Linux `build.sh`, example `share/examples/blackraven.conf`, Docker daemon image.

### Changed
- Rebrand Neoxa → BlackRaven across binaries, RPC, GUI, and docs.
- Mainnet P2P port **9777**, RPC **9776**; testnet P2P **19777**, RPC **19776**.
- Address prefixes: mainnet P2PKH `B…`, testnet `r…`.
- Spork addresses and asset burn sinks updated to BLKR address format.

### Notes
- Official domain: **blackraven.network**. DNS seeds: `seed1/2/3.blackraven.network` (deploy before public launch).
- Smartnodes disabled on mainnet/testnet in this release.

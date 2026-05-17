# BlackRaven DNS seeds

Official domain: **blackraven.network**

## Mainnet and testnet

| Host | Purpose |
| --- | --- |
| `seed1.blackraven.network` | DNS seed node 1 |
| `seed2.blackraven.network` | DNS seed node 2 |
| `seed3.blackraven.network` | DNS seed node 3 |

Configured in `src/chainparams.cpp` for mainnet and testnet.

## Deploying a seed

1. Run a synced `blackravend` with `listen=1` and a public IP.
2. Publish an **A/AAAA** record for `seedN.blackraven.network` pointing at that IP.
3. Optionally run [blackraven-seeder](https://github.com/BlackRavenNetwork/blackraven-seeder) (DNS crawler).

P2P ports: mainnet **9777**, testnet **19777**.

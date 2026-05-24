# BlackRaven v0.1.0 release checklist

## Build verification
- [ ] `./build.sh` completes on clean Ubuntu 22.04
- [ ] `src/blackravend -version` shows `v0.1.0`
- [ ] Mainnet starts: `UpdateTip` hash `0001a5916e8deb24b32cfa5c8b97c0b40685bd7616a40cdc27088ce4c690bd1a`
- [ ] Testnet starts: genesis `000dbaec850661cdaf56d728e3629f08f47e917afe259b66606211935816771c`
- [ ] `blackraven-qt` creates HD wallet on first run

## Network launch
- [ ] Deploy DNS seeds (`seed1.blackraven.network`, `seed2.blackraven.network`, `seed3.blackraven.network`)
- [ ] Publish `blackraven.conf` example and port list (9777/9776)
- [ ] Set operational dev-fee address in `chainparams.cpp` (replace placeholder)
- [ ] Set operational spork keys (replace placeholder addresses)

## Distribution
- [ ] GitHub release assets: Linux x86_64 tarball, optional Windows/macOS builds
- [ ] Signed git tag `v0.1.0`
- [ ] Docker image smoke test: `docker build -t blackraven:0.1.0 .`

## Mining (KawPoW)
- [ ] Document `gen=1` or external miner compatibility
- [ ] Confirm `getblocktemplate` / RPC mining paths

## Security
- [ ] No private keys or old Neoxa alert keys in repo
- [ ] Review `vSporkAddresses` and checkpoint data

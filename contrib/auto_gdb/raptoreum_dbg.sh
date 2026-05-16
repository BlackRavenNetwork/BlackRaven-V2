#!/bin/bash
# use testnet settings,  if you need mainnet,  use ~/.blackraven/blackravend.pid file instead
blackraven_pid=$(<~/.blackraven/testnet3/blackravend.pid)
sudo gdb -batch -ex "source debug.gdb" blackravend ${blackraven_pid}

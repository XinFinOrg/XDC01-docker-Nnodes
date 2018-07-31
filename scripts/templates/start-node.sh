#!/bin/bash

#
# This is used at Container start up to run the constellation and geth nodes
#

set -u
set -e

### Configuration Options
TMCONF=/qdata/tm.conf

GETH_ARGS="--datadir /qdata/dd --syncmode full _MINE_ --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --unlock 0 --password /qdata/passwords.txt --rpcport _RPCPORT_ --port _PORT_ --istanbul.blockperiod=10"

if [ ! -d /qdata/dd/geth/chaindata ]; then
  echo "[*] Mining Genesis block"
  /usr/local/bin/geth --datadir /qdata/dd init /qdata/genesis.json
fi

echo "[*] Starting Constellation node"
nohup /usr/local/bin/constellation-node $TMCONF 2>> /qdata/logs/constellation.log &

sleep 2

BOOTNODE_ARGS="--bootnodes=enode://_BOOTENODE_@_BOOTNODEIP_:30301"

echo "[*] Starting node"
PRIVATE_CONFIG=$TMCONF nohup /usr/local/bin/geth $BOOTNODE_ARGS $GETH_ARGS 2>&1 >>/qdata/logs/geth.log | tee --append /qdata/logs/geth.log

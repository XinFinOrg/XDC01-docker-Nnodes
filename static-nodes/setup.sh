#!/bin/bash

#
# Create all the necessary scripts, keys, configurations etc. to run
# a cluster of N Quorum nodes with Raft consensus.
#
# Run the cluster with "docker-compose up -d"
#
# Geth and Constellation logfiles for Node N will be in qdata_N/logs/
#

#### Configuration options #############################################

# One Docker container will be configured for each IP address in this subnet
subnet="172.13.0.0/16"

read -p "Please enter no. of inital nodes you wish to setup (min. 2) : " nnodes
read -p "Please enter public IP of this host machine : " public_ip

# Docker image name
image=quorum

########################################################################

if [[ $nnodes < 2 ]]
then
    echo "ERROR: There must be more than one node IP address."
    exit 1
fi

./cleanup.sh

uid=`id -u`
gid=`id -g`
pwd=`pwd`

#### Create directories for each node's configuration ##################

echo '[1] Configuring for '$nnodes' nodes.'

for n in $(seq 1 $nnodes)
do
    qd=qdata_$n
    mkdir -p $qd/{logs,keys}
    mkdir -p $qd/dd/geth
done

#### Make static-nodes.json and store keys #############################

echo '[2] Creating Enodes and static-nodes.json.'

echo "[" > static-nodes.json
for n in $(seq 1 $nnodes)
do
    qd=qdata_$n

    # Generate the node's Enode and key
    docker run -u $uid:$gid -v $pwd/$qd:/qdata $image /usr/local/bin/bootnode -genkey /qdata/dd/nodekey
    enode=`docker run -u $uid:$gid -v $pwd/$qd:/qdata $image /usr/local/bin/bootnode --nodekey /qdata/dd/nodekey -writeaddress`

    # Add the enode to static-nodes.json
    sep=`[[ $n < $nnodes ]] && echo ","`
    echo '  "enode://'$enode'@'$public_ip':'$((n+21000))'?discport=0&raftport='$((n+23000))'"'$sep >> static-nodes.json

done
echo "]" >> static-nodes.json

#### Create accounts, keys and genesis.json file #######################

echo '[3] Creating Ether accounts and genesis.json.'

cat > genesis.json <<EOF
{
  "alloc": {
EOF

for n in $(seq 1 $nnodes)
do
    qd=qdata_$n

    # Generate an Ether account for the node
    touch $qd/passwords.txt
    account=`docker run -u $uid:$gid -v $pwd/$qd:/qdata $image /usr/local/bin/geth --datadir=/qdata/dd --password /qdata/passwords.txt account new | cut -c 11-50`

    # Add the account to the genesis block so it has some Ether at start-up
    sep=`[[ $n < $nnodes ]] && echo ","`
    cat >> genesis.json <<EOF
    "${account}": {
      "balance": "1000000000000000000000000000"
    }${sep}
EOF

done

cat >> genesis.json <<EOF
  },
  "coinbase": "0x0000000000000000000000000000000000000000",
  "config": {
    "homesteadBlock": 0
  },
  "difficulty": "0x0",
  "extraData": "0x",
  "gasLimit": "0x2FEFD800",
  "mixhash": "0x00000000000000000000000000000000000000647572616c65787365646c6578",
  "nonce": "0x0",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "timestamp": "0x00"
}
EOF


#### Make node list for tm.conf ########################################


nodelist=()
for n in $(seq 1 $nnodes)
do
    sep=`[[ $n != 1 ]] && echo ","`
    nodelist=${nodelist}${sep}'"http://'${public_ip}':'$((n+9000))'/"'
done


#### Complete each node's configuration ################################

echo '[4] Creating Quorum keys and finishing configuration.'

for n in $(seq 1 $nnodes)
do
    qd=qdata_$n

    cat templates/tm.conf \
        | sed s/_NODEIP_/$public_ip/g \
        | sed s%_NODELIST_%$nodelist%g \
        | sed s/_NODEPORT_/$((n+9000))/g \
              > $qd/tm.conf

    cp genesis.json $qd/genesis.json
    cp static-nodes.json $qd/dd/static-nodes.json

    # Generate Quorum-related keys (used by Constellation)
    docker run -u $uid:$gid -v $pwd/$qd:/qdata $image /usr/local/bin/constellation-node --generatekeys=qdata/keys/tm < /dev/null > /dev/null
    echo 'Node '$n' public key: '`cat $qd/keys/tm.pub`

    cat templates/start-node.sh \
        | sed s/_PORT_/$((n+21000))/g \
        | sed s/_RPCPORT_/$((n+22000))/g \
        | sed s/_RAFTPORT_/$((n+23000))/g \
              > $qd/start-node.sh

    #cp templates/start-node.sh $qd/start-node.sh
    chmod 755 $qd/start-node.sh

done
rm -rf genesis.json static-nodes.json

#### Create the docker-compose file ####################################

cat > docker-compose.yml <<EOF
version: '2'
services:
EOF

for n in $(seq 1 $nnodes)
do
    qd=qdata_$n

    cat >> docker-compose.yml <<EOF
  node_$n:
    image: $image
    volumes:
      - './$qd:/qdata'
    networks:
      - quorum_net
    ports:
      - $((n+21000)):$((n+21000))
      - $((n+22000)):$((n+22000))
      - $((n+23000)):$((n+23000))
      - $((n+9000)):$((n+9000))
    user: '$uid:$gid'
EOF

done

cat >> docker-compose.yml <<EOF

networks:
  quorum_net:
    driver: bridge
    ipam:
      driver: default
      config:
      - subnet: $subnet
EOF

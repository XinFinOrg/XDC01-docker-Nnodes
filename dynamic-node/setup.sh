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

RPC_PORT=22000
GETH_PORT=21000
RAFT_PORT=23000
CONSTELLATION_PORT=9000

function isPortInUse {
        if nc -zv -w30 $1 $2 <<< '' &> /dev/null
        then
                return 1
        else
                return 0
        fi
}

read -p "Please enter public IP of this host machine : " node_ip
ips=("$node_ip")

# One Docker container will be configured for each IP address in this subnet
read -p "Please enter a unique subnet to use for local docker n/w (e.g. 172.13.0.0/16) : " docker_subnet

# Docker image name
image=xinfinorg/quorum:v2.1.0

########################################################################

nnodes=${#ips[@]}

./cleanup.sh

uid=`id -u`
gid=`id -g`
pwd=`pwd`

#### Create directories for each node's configuration ##################

echo '[1] Configuring for '$nnodes' nodes.'

read -p "Enter Node Number (e.g. 4) : " node_number

n=$node_number

 until $(isPortInUse 'localhost' $((n+GETH_PORT+OFFSET)))
        do
                if ! $(isPortInUse 'localhost' $((n+GETH_PORT+OFFSET))); then
                        echo "Port is in use so auto incrementing"
                        echo $((n+GETH_PORT+4000))
                        OFFSET=$OFFSET+4000
                        echo $OFFSET
                else
                        echo "Port is free so using default port"
                        echo $((n+GETH_PORT))
                        OFFSET=0
                        echo $OFFSET
                fi

done



for ip in ${ips[*]}
do
    qd=qdata_$n
    mkdir -p $qd/{logs,keys}
    mkdir -p $qd/dd/geth

    let n++
done


#### Make static-nodes.json and store keys #############################

echo '[2] Creating Enodes & enode-url.json for raft.addPeer'

echo "[" > enode-url.json
n=$node_number
for ip in ${ips[*]}
do
    qd=qdata_$n

    # Generate the node's Enode and key
    docker run -u $uid:$gid -v $pwd/$qd:/qdata $image /usr/local/bin/bootnode -genkey /qdata/dd/nodekey
    enode=`docker run -u $uid:$gid -v $pwd/$qd:/qdata $image /usr/local/bin/bootnode --nodekey /qdata/dd/nodekey -writeaddress`


    # Add the enode to enode-url.json
    sep=`[[ $n < $nnodes ]] && echo ","`
    echo '  "enode://'$enode'@'$ip':'$((n+21000+OFFSET))'?discport=0&raftport='$((n+23000+OFFSET))'"'$sep >> enode-url.json
    echo '  [*] Login to geth console of any node of existing cluster & run the following command:'
    echo '  raft.addPeer("enode://'$enode'@'$ip':'$((n+21000+OFFSET))'?discport=0&raftport='$((n+23000+OFFSET))'")'
    let n++
done
echo "]" >> enode-url.json


#### Create accounts, keys and genesis.json file #######################

echo '[3] Copying genesis.json'

n=$node_number
for ip in ${ips[*]}
do
    qd=qdata_$n
    # Generate passwords.txt for unlocking accounts, To-Do Accept user-input for password
    touch $qd/passwords.txt
    cp ../genesis.json $qd/genesis.json
    mkdir -p $qd/dd/keystore
    cp ../keys/key.json $qd/dd/keystore/key
    let n++
done

#### Make node list for tm.conf ########################################

nodelist=
n=$node_number
for ip in ${ips[*]}
do
    sep=`[[ $ip != ${ips[0]} ]] && echo ","`
    nodelist=${nodelist}${sep}'"http://'${public_ip}':'$((n+9000+OFFSET))'/"'
    let n++
done


#### Complete each node's configuration ################################

echo '[4] Creating Quorum keys and finishing configuration.'

n=$node_number
for ip in ${ips[*]}
do
    qd=qdata_$n

    cat templates/tm.conf \
        | sed s/_NODEIP_/$node_ip/g \
        | sed s%_NODELIST_%$nodelist%g \
        | sed s/_NODEPORT_/$((n+9000+OFFSET))/g \
              > $qd/tm.conf

    # Generate Quorum-related keys (used by Constellation)
    docker run -u $uid:$gid -v $pwd/$qd:/qdata $image /usr/local/bin/constellation-node --generatekeys=qdata/keys/tm < /dev/null > /dev/null
    echo 'Node '$n' public key: '`cat $qd/keys/tm.pub`

    cat templates/start-node.sh \
        | sed s/_PORT_/$((n+21000+OFFSET))/g \
        | sed s/_RPCPORT_/$((n+22000+OFFSET))/g \
        | sed s/_RAFTPORT_/$((n+23000+OFFSET))/g \
        | sed s/_RAFTID_/$node_number/g \
              > $qd/start-node.sh

    #cp templates/start-node.sh $qd/start-node.sh
    chmod 755 $qd/start-node.sh

    let n++
done

#### Create the docker-compose file ####################################

cat > docker-compose.yml <<EOF
version: '2'
services:
EOF

n=$node_number
for ip in ${ips[*]}
do
    qd=qdata_$n

    cat >> docker-compose.yml <<EOF
  node_$n:
    image: $image
    restart: always
    volumes:
      - './$qd:/qdata'
    networks:
      - xdc_dynamic_node_network
    ports:
      - $((n+21000+OFFSET)):$((n+21000+OFFSET))
      - $((n+22000+OFFSET)):$((n+22000+OFFSET))
      - $((n+23000+OFFSET)):$((n+23000+OFFSET))
      - $((n+9000+OFFSET)):$((n+9000+OFFSET))
    user: '$uid:$gid'
EOF

    let n++
done

cat >> docker-compose.yml <<EOF

networks:
  xdc_dynamic_node_network:
    driver: bridge
    ipam:
      driver: default
      config:
      - subnet: $docker_subnet
EOF

echo '[5] Removing temporary containers.'
# Remove temporary containers created for keys & enode addresses - Note this will remove ALL stopped containers
docker container prune -f > /dev/null 2>&1

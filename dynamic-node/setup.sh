#!/bin/bash

#
# Create all the necessary scripts, keys, configurations etc. to run
# a cluster of N Quorum nodes with Raft consensus.
#
# The nodes will be in Docker containers. List the IP addresses that
# they will run at below (arbitrary addresses are fine).
#
# Run the cluster with "docker-compose up -d"
#
# Run a console on Node N with "geth attach qdata_N/dd/geth.ipc"
# (assumes Geth is installed on the host.)
#
# Geth and Constellation logfiles for Node N will be in qdata_N/logs/
#

# TODO: check file access permissions, especially for keys.


#### Configuration options #############################################

# One Docker container will be configured for each IP address in $ips
subnet="172.13.0.0/16"
read -p "Enter Node IP (e.g. 172.13.0.5) : " node_ip
ips=("$node_ip")

# Docker image name
image=quorum

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
for ip in ${ips[*]}
do
    qd=qdata_$n
    mkdir -p $qd/{logs,keys}
    mkdir -p $qd/dd/geth

    let n++
done


#### Make static-nodes.json and store keys #############################

echo '[2] Creating Enodes & enode-url.json for raft.AddPeer.'

echo "[" > enode-url.json
n=$node_number
for ip in ${ips[*]}
do
    qd=qdata_$n

    # Generate the node's Enode and key
    docker run -u $uid:$gid -v $pwd/$qd:/qdata $image /usr/local/bin/bootnode -genkey /qdata/dd/nodekey
    enode=`docker run -u $uid:$gid -v $pwd/$qd:/qdata $image /usr/local/bin/bootnode --nodekey /qdata/dd/nodekey -writeaddress`


    # Add the enode to static-nodes.json
    sep=`[[ $n < $nnodes ]] && echo ","`
    echo '  "enode://'$enode'@'$ip':30303?discport=0&raftport=50400"'$sep >> enode-url.json

    let n++
done
echo "]" >> enode-url.json


#### Create accounts, keys and genesis.json file #######################

echo '[3] Creating Ether accounts.'

n=$node_number
for ip in ${ips[*]}
do
    qd=qdata_$n

    # Generate an Ether account for the node
    touch $qd/passwords.txt
    account=`docker run -u $uid:$gid -v $pwd/$qd:/qdata $image /usr/local/bin/geth --datadir=/qdata/dd --password /qdata/passwords.txt account new | cut -c 11-50`
    let n++
done

#### Make node list for tm.conf ########################################

nodelist=
n=$node_number
for ip in ${ips[*]}
do
    sep=`[[ $ip != ${ips[0]} ]] && echo ","`
    nodelist=${nodelist}${sep}'"http://'${ip}':9000/"'
    let n++
done


#### Complete each node's configuration ################################

echo '[4] Creating Quorum keys and finishing configuration.'

n=$node_number
for ip in ${ips[*]}
do
    qd=qdata_$n

    cat templates/tm.conf \
        | sed s/_NODEIP_/${ips[$((n-1))]}/g \
        | sed s%_NODELIST_%$nodelist%g \
              > $qd/tm.conf

    # Generate Quorum-related keys (used by Constellation)
    docker run -u $uid:$gid -v $pwd/$qd:/qdata $image /usr/local/bin/constellation-node --generatekeys=qdata/keys/tm < /dev/null > /dev/null
    echo 'Node '$n' public key: '`cat $qd/keys/tm.pub`

    cat templates/start-node.sh \
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
    volumes:
      - './$qd:/qdata'
    ports:
      - $((n+22000)):8545
    user: '$uid:$gid'
    networks:
            default:
                ipv4_address: $node_ip
EOF

    let n++
done

cat >> docker-compose.yml <<EOF

networks:
  default:
    external:
      name: staticnodes_quorum_net
EOF

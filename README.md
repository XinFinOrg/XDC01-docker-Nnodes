# XDC01-docker-Nnodes 

Run a bunch of Quorum nodes, each in a separate Docker container.

## Install Docker & Docker Compose

    ./install_docker.sh


## Building

In the top level directory:

    docker build -t quorum .
    
The first time will take a while, but after some caching it gets much quicker for any minor updates.

## Running

Change to the *Nnodes/* directory. Edit the `ips` variable in *setup.sh* to list two or more IP addresses on the Docker network that will host nodes:

    ips=("172.13.0.2" "172.13.0.3" "172.13.0.4")

The IP addresses are needed for Constellation to work. Now run,

    cd static-nodes 
    ./setup.sh
    docker-compose up -d
    
This will set up as many Quorum nodes as IP addresses you supplied, each in a separate container, on a Docker network, all hopefully talking to each other.

    Nnodes> docker ps
    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                     NAMES
    83ad1de7eea6        quorum              "/qdata/start-node.sh"   55 seconds ago      Up 53 seconds       0.0.0.0:22002->8545/tcp   staticnodes_node_2_1
    14b903ca465c        quorum              "/qdata/start-node.sh"   55 seconds ago      Up 54 seconds       0.0.0.0:22003->8545/tcp   staticnodes_node_3_1
    d60bcf0b8a4f        quorum              "/qdata/start-node.sh"   55 seconds ago      Up 54 seconds       0.0.0.0:22001->8545/tcp   staticnodes_node_1_1

## Stopping

    docker-compose down
  
## Playing

### Accessing the Geth console

    docker exec -it staticnodes_node_1_1 geth attach /qdata/dd/geth.ipc


## Dynamically Adding a New RAFT Node

    cd dynamic-node
    ./setup.sh
  

### Copy genesis.json from static-nodes/qdata_n to dynamic-node/qdata_n

### Copy enodeID from enode-url.json attach to a geth console to any of the staticnodes & do 
    
    raft.addPeer(enodeID)

### Start Dynamic Peer
    cd dynamic-node
    docker-compose up -d
   
# Migration Process 
Ref URL :- https://github.com/XinFinorg/MigrationFiles/

Use Remix Solidity IDE to compile the code :- https://remix.ethereum.org

We need to compile the code first, and then we can deploy the smart contract to the network. The simplest way is to use the Remix — Solidity IDE to do the task.
In Remix, press the “+” button on the left corner to start a new Solidity file with .sol extension. Copy and paste the code in the center region. Since Remix will auto-compile the code by default, there should be no error or warning messages showed up in the right panel.

If no error message is generated, that means our code is compiled and good to go.

In the Web3 deploy field, copy all the code in that field.

Generate a new file called 001-Deploy_XDC_Contract.js,Paste the code which you copied from Remix.

Now, we need to load the script we just created to our private network. Before loading the script, you need to unlock the coinbase account.
 

```
personal.unlockAccount(eth.accounts[0], 'password')
```

Then it’s the time to load the web3 deploy script you created.
```
> loadScript('001-Deploy_XDC_Contract.js')
>null [object Object]
>true
>// use your own file path!
```

The contract is now waiting to be mined. The contract is successfully deployed to the network until it’s being mined!
```
> null [object Object]
>Contract mined! address: 0x2d29437ff1c7c90f58316ffaac697faefaf56985 transactionHash: 0x1ac0da0d8128955008c7b4dbf1d11fa12b22b4173bc263654f30a80c30d7495b
```
Once Contract Mined...We will process for XDC Migration :-

Step 01 :- Deploy Token balance in console
```
> loadScript('002-balancePool.js')
>true
>// Deploy Token balance in console
```
Step 01 :- Deploy ForLoop To transfer Token in recpective Accounts
```
> loadScript('003-transferCoins.js')
>//This will show Number Transfers 
```

```
#Thank You

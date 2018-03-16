# XDC01-docker-Nnodes 

## Launch Ubuntu 16.04 Instance

## Clone Repository
    git clone -b "multi-node" https://github.com/XinFinorg/XDC01-docker-Nnodes.git    
   
## Install Docker & Docker Compose
    sudo ./install_docker.sh

## Pull Image from Docker Hub
    sudo docker pull xinfinorg/quorum:v2.0.0

## Setup 

    cd static-nodes 
    sudo ./setup.sh

    Enter the inital number of nodes & public IP address of host machine & then start the nodes using.

    sudo docker-compose -p <PROJECT_NAME_STATIC_NODE> up -d

## Stopping

    sudo docker-compose -p <PROJECT_NAME_STATIC_NODE> down

## Accessing the Geth console

    sudo docker exec -it PROJECT_NAME_STATIC_NODES_node_1_1 geth attach /qdata/dd/geth.ipc

# Upgrade Quorum

## Pull newer version of quorum from docker hub
    sudo docker pull xinfinorg/quorum:v2.0.1-pre

## Update docker-compose.yml to use new image (specify quorum:TAG_NAME as argument)
    sudo ./update_quorum.sh quorum:v2.0.1-pre

## Stop containers running old version
   sudo docker-compose -p <PROJECT_NAME_STATIC/DYNAMIC_NODE> down
  
## Run new version     
   sudo docker-compose -p <PROJECT_NAME_STATIC/DYNAMIC_NODE> up -d

## Dynamically Adding a New RAFT Node on a separate/same host machine 

### Install docker & build the Quorum image as done on previous host machine then

    cd dynamic-node
    sudo ./setup.sh
    
   Enter the public IP of the new host machine & enter the node number.
    
### Copy enodeID from enode-url.json then attach to geth console of any  earlier created staticnodes & do 
    
    raft.addPeer(enodeID)

### Start dynamic raft peer
    cd dynamic-node
    sudo docker-compose -p <PROJECT_NAME_DYNAMIC_NODE> up -d

 # Migration Process 

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

# Thank You

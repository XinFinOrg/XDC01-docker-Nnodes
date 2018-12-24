# XDC01-docker-Nnodes 
#### Create and customize your XDC01 private chain with ShellScript in Just minutes. 

XinFin Core Quorum Network

![XinFin Core Quorum Network][fig1]




## Prerequisite
**Operating System**: Ubuntu 16.04 64-bit

**Tools**: Docker, Docker Compose

**Hardware**:

| Hardware | Minimum | Desired |
|:------- |:-------- |:---------|
| **CPU's**: | 2 |  4 |
| **Memory**: | 4 GB |  8 GB |
| **Storage**: | 100 GB |  500 GB |

## Network

Following network ports need to be open for the nodes to communicate

| Port | Type | Definition |
|:------:|:-----:|:---------- |
|21001-2100*| TCP/UDP | GETH |
|22001-2200*| TCP | RPC |
|23001-2300*| TCP | RAFT |
|9001-900*| TCP | Constellation |

*-auto-increment depending on number of nodes

## Clone Repository
    git clone https://github.com/XinFinorg/XDC01-docker-Nnodes.git    
   
## Install Docker & Docker Compose
    sudo ./install_docker.sh

## Pull Image from Docker Hub
    sudo docker pull xinfinorg/quorum:v2.1.0

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
    sudo docker pull xinfinorg/quorum:v2.1.0

## Update docker-compose.yml to use new image (specify quorum:TAG_NAME as argument)
    sudo ./update_quorum.sh quorum:v2.1.0

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

## Contacting Us

Join our [Telegram Developer Group](https://t.me/XinFinDevelopers) and put up your queries or raise issue in Github to get answer. We would love to answer your questions.



[fig1]: /docs/CoreQuorumNetwork.jpg "XinFin Core Quorum Network"
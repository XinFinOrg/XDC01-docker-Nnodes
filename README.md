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

# Thank You

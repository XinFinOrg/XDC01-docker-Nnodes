# XDC01-docker-Nnodes - Istanbul Tools 

## Launch Ubuntu 16.04 Instance

## Clone Repository
    git clone -b "istanbul-tools" https://github.com/XinFinorg/XDC01-docker-Nnodes.git    
   
## Install docker, docker-compose, jq
    sudo ./install.sh
    
## Setup an IBFT Network

    cd static-nodes 
    sudo ./setup.sh

    Enter the inital number of nodes & public IP address of host machine & then start the nodes using.

    sudo docker-compose -p <PROJECT_NAME_STATIC_NODE> up -d

## Stopping

    sudo docker-compose -p <PROJECT_NAME_STATIC_NODE> down

## Accessing the GETH console of First Node

    sudo docker exec -it PROJECT_NAME_STATIC_NODES_node_1_1 geth attach /qdata/dd/geth.ipc

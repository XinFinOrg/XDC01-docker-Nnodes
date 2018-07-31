# XDC01-docker-Nnodes - Istanbul Tools 

## Launch Ubuntu 16.04 Instance

## Clone Repository
    git clone -b "istanbul-tools-with-discovery" https://github.com/XinFinorg/XDC01-docker-Nnodes.git    
   
## Install docker, docker-compose, jq
    sudo ./install.sh
    
## Setup an IBFT Network

    cd scripts
    sudo ./setup.sh

    Enter the inital number of nodes & public IP address of host machine & then start the nodes using

    sudo docker-compose up -d

## Stopping

    sudo docker-compose -p down

## Accessing GETH console

    sudo docker exec -it node_# geth attach /qdata/dd/geth.ipc

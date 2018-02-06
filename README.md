# XDC01-docker-Nnodes 

## Install Docker & Docker Compose

    sudo ./install_docker.sh

## Building

In the top level directory:

    sudo docker build -t quorum .

## Running 

    cd static-nodes 
    sudo ./setup.sh

    Enter the inital number of nodes & public IP address of host machine & then start the nodes using.

    sudo docker-compose up -d

## Stopping

    sudo docker-compose down

## Accessing the Geth console

    sudo docker exec -it staticnodes_node_1_1 geth attach /qdata/dd/geth.ipc


## Dynamically Adding a New RAFT Node on a separate/same host machine 

### Install docker & build the Quorum image as done on previous host machine then

    cd dynamic-node
    sudo ./setup.sh
    
   Enter the public IP of the new host machine & enter the node number.
    
### Copy enodeID from enode-url.json then attach to geth console of any  earlier created staticnodes & do 
    
    raft.addPeer(enodeID)

### Start dynamic raft peer
    cd dynamic-node
    sudo docker-compose up -d

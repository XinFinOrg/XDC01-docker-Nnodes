# XDC01-docker-Nnodes 
#### Create and customize your XDC01 private chain within minutes. ( please go here to setup XinFin Public node: https://github.com/XinFinOrg/XinFin-Node )

XinFin Core Network

![XinFin Core Quorum Network][fig1]




## Prerequisite
**Operating System**: Ubuntu 16.04 64-bit or higher

**Tools**: Docker, Docker Compose

**Hardware**:

| Hardware | Minimum | Desired |
|:------- |:-------- |:---------|
| **CPU's**: | 2 |  4 |
| **Memory**: | 4 GB |  8 GB |
| **Storage**: | 100 GB |  500 GB |

## Network Ports

Following network ports need to be open for the nodes to communicate

| Port | Type | Definition |
|:------:|:-----:|:---------- |
|21001-2100*| TCP/UDP | GETH |
|22001-2200*| TCP | RPC |
|23001-2300*| TCP | RAFT |
|9001-900*| TCP | Constellation |

*-auto-increment depending on number of nodes

## Clone repository
    git clone https://github.com/XinFinorg/XDC01-docker-Nnodes.git    
   
## Step: 1 Install docker & docker-compose
    sudo ./install_docker.sh

## Step: 2 Pull image from Docker Hub
    sudo docker pull xinfinorg/quorum:v2.1.0

## Step: 3 Launch the setup script

    cd static-nodes 
    sudo ./setup.sh

    Enter number of nodes, private IP of host machine & unique docker subnet

    sudo docker-compose -p <PROJECT_NAME_STATIC_NODE> up -d

## Accessing console

    sudo docker exec -it PROJECT_NAME_STATIC_NODES_node_1_1 geth attach /qdata/dd/geth.ipc
    
## Stopping the network

    sudo docker-compose -p <PROJECT_NAME_STATIC_NODE> down


## Adding a new node to the existing network

### Install docker & pull image on the new host machine as done earlier in Step 1 & 2

    cd dynamic-node
    sudo ./setup.sh
    
   Enter the public IP of the new host machine (private IP in case of local setup, assigned by router)
   Enter the node number (e.g. if you have 3 nodes up with the initial setup then node number here would be 4)
    
### Copy enodeID from enode-url.json then attach to geth console of any running node & execute
    
    raft.addPeer(enodeID)

### Start the new node
    cd dynamic-node
    sudo docker-compose -p <PROJECT_NAME_DYNAMIC_NODE> up -d
    
# Upgrade Network

## Pull newer version of image from docker hub
    sudo docker pull xinfinorg/quorum:v2.x.x

## Stop containers running old version
    sudo docker-compose -p <PROJECT_NAME_STATIC/DYNAMIC_NODE> down
    
## Update docker-compose.yml to use new image (specify quorum:TAG_NAME as argument)
    sudo ./update_quorum.sh quorum:v2.x.x
  
## Run new version     
    sudo docker-compose -p <PROJECT_NAME_STATIC/DYNAMIC_NODE> up -d
    
   
# Windows / macOS Support Using Vagrant
1. Install Oracle [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Install [Vagrant](https://www.vagrantup.com/downloads.html)
3. Install [GIT](https://gitforwindows.org/)
4. Launch command prompt & follow the commands below  
   ```sh
    git clone https://github.com/XinFinOrg/XDC01-docker-Nnodes.git
    cd XDC01-docker-Nnodes
    vagrant up
    vagrant ssh
    ```
5. XDC01-docker-Nnodes is automatically copied to /home/vagrant/ follow Step 1, 2 & 3 as explained before in this document to complete the network setup.
6. To shutdown the vagrant instance, run vagrant suspend. To delete it, run vagrant destroy.


( please go here to setup XinFin Public node: https://github.com/XinFinOrg/XinFin-Node )

## Contacting Us

Join our [Telegram Developer Group](https://t.me/joinchat/IDjEOEUaNJNpbeM-c1YtZw) and put up your queries or raise issue in Github to get answer. We would love to answer your questions.



[fig1]: /docs/CoreQuorumNetwork.jpg "XinFin Core Quorum Network"

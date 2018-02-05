#!/bin/bash

function installDocker(){
    echo "Installing Docker"

    sudo apt-get update

    sudo apt-get install \
            apt-transport-https \
            ca-certificates \
            curl \
            software-properties-common -y

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    sudo add-apt-repository \
         "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
         $(lsb_release -cs) \
         stable"

    sudo apt-get update

    sudo apt-get install docker-ce -y
    
    curl -o /usr/local/bin/docker-compose -L \
         "https://github.com/docker/compose/releases/download/1.18.0/docker-compose-$(uname -s)-$(uname -m)"         

    chmod +x /usr/local/bin/docker-compose
    sleep 5
    echo "Docker Installed successfully"
}

function init(){

    if [ -z "$(which docker)" ]; then
        installDocker
    fi
}


function main(){

    init
    
}

main

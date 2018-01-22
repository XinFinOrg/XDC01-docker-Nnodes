# Use Ubuntu
FROM ubuntu:16.04

# Install updates
RUN apt-get update && apt-get install -y

# Install build-essential
RUN apt-get install -y --no-install-recommends build-essential

# Install git & wget
RUN apt-get install -y git wget psmisc nano net-tools

# Build GOLang 1.8.5
ENV GOREL go1.8.5.linux-amd64.tar.gz
ENV PATH $PATH:/usr/local/go/bin
RUN wget -q https://storage.googleapis.com/golang/${GOREL}
RUN tar -xvzf ${GOREL}
RUN mv go /usr/local/go
RUN rm ${GOREL}

# Build Constellation 0.2.0
RUN apt-get install -y --no-install-recommends libdb-dev libleveldb-dev libsodium-dev zlib1g-dev libtinfo-dev 
RUN wget -q https://github.com/jpmorganchase/constellation/releases/download/v0.2.0/constellation-0.2.0-ubuntu1604.tar.xz -O constellation-0.2.0-ubuntu1604.tar.xz  
RUN tar -xf constellation-0.2.0-ubuntu1604.tar.xz
RUN rm -rf constellation-0.2.0-ubuntu1604.tar.xz
RUN cp constellation-0.2.0-ubuntu1604/constellation-node /usr/local/bin
RUN chmod +x /usr/local/bin/constellation-node

# Build Quorum 2.0.0
RUN git clone https://github.com/jpmorganchase/quorum.git && cd quorum && git checkout tags/v2.0.0 && make all
RUN cp quorum/build/bin/geth /usr/local/bin
RUN cp quorum/build/bin/bootnode /usr/local/bin
RUN rm -rf quorum

EXPOSE 21000 23000

#!/bin/bash

rm -rf qdata_[0-9] qdata_[0-9][0-9]
rm -f docker-compose.yml

# Shouldn't be needed, but just in case:
rm -f enode-url.json genesis.json

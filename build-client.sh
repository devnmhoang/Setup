#!/bin/bash
set -e
# git submodule init && git submodule update
cd ./setup-tools
./build.sh
cd ../setup-mpc-common
docker build -t aztec/setup-mpc-common:latest .
cd ../setup-mpc-client
docker build -t aztec/setup-mpc-client:latest .
#!/bin/bash
docker build -f Dockerfile.build -t aztec/setup-tools-build .
docker build -f Dockerfile.deploy -t aztec/setup-tools .
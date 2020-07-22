#!/bin/bash
set -e
aws ecr describe-repositories --repository-names setup-tools > /dev/null 2>&1 || aws ecr create-repository --repository-name setup-tools
docker push aztec/setup-tools
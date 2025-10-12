#!/bin/bash
# Author: Gleb Denisov
# Description: This script builds Blog app and pushes it to Docker repository

IMAGE_NAME=blog-web-app
TAG=${1:-latest}
USERNAME=gl3b

# Build image
docker build -t $USERNAME/$IMAGE_NAME:$TAG .
if [ $? -ne 0 ];then
  echo "ERROR: Failed to build $IMAGE_NAME"
  exit 1
else
  echo "[*] $IMAGE_NAME successfully built."
fi


# Push to Docker hub
docker push $USERNAME/$IMAGE_NAME:$TAG
if [ $? -ne 0 ];then
  echo "ERROR: Failed to push $IMAGE_NAME to Docker hub"
  exit 1
else
  echo "[*] $IMAGE_NAME successfully pushed"
fi

#!/bin/bash

_VERSION=$(echo -n $(cat VERSION))

docker build -t mwvaughn/imagenet-tensorflow-reactor:${_VERSION} .
docker tag mwvaughn/imagenet-tensorflow-reactor:${_VERSION} mwvaughn/imagenet-tensorflow-reactor:latest
#docker push mwvaughn/imagenet-tensorflow-reactor:${_VERSION}
#docker push mwvaughn/imagenet-tensorflow-reactor:latest

#!/bin/bash

_VERSION=$(echo -n $(cat VERSION))

docker push mwvaughn/imagenet-tensorflow-reactor:${_VERSION}
docker push mwvaughn/imagenet-tensorflow-reactor:latest

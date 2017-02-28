#!/bin/bash

_VERSION=$(echo -n $(cat VERSION))

docker build -t ${huborg}/${hubimage}:${_VERSION} .
docker tag ${huborg}/${hubimage}:${_VERSION} ${huborg}/${hubimage}:latest

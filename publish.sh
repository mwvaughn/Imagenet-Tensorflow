#!/bin/bash

_VERSION=$(echo -n $(cat VERSION))

docker push ${huborg}/${hubimage}:${_VERSION}
docker push ${huborg}/${hubimage}:latest

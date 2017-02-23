#!/bin/bash

STARTTIME=$(date +%s)
docker run -t --env-file tester.env mwvaughn/imagenet-tensorflow-reactor
ENDTIME=$(date +%s)
>&2 echo "tester-runtime: $(($ENDTIME - $STARTTIME)) seconds"

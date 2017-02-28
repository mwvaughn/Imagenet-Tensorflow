#!/bin/bash

STARTTIME=$(date +%s)
docker run -t --env-file tester.env ${huborg}/${hubimage}
ENDTIME=$(date +%s)
>&2 echo "tester-runtime: $(($ENDTIME - $STARTTIME)) seconds"

#!/bin/bash

set -e

export actor=7ba286ec-f956-11e6-9c50-0242ac110005-059
export base=https://dev.tenants.staging.agaveapi.co
export token=20eab246a12fd55ffb972e4e2d68d9d5

STARTTIME=$(date +%s)

die () { echo "An error occurred and has caused this task to fail"; }

data_url=$1
predictions=$2
data_name="classify.img"

# Die if URL NOT specified
if [[  -z  $data_url  ]];
	then
	die
fi

if [[  -z  $predictions  ]];
	then
	predictions=5
fi

data_url=$(urlencode $data_url)
data_name=$(urlencode $data_name)

execution_record=$(curl -H "Authorization: Bearer $token" -sk -X POST --data "message=classify" "$base/actors/v2/$actor/messages?data_url=${data_url}&data_name=${data_name}&predictions=${predictions}&pretty=true")
#echo $execution_record

status=$(echo $execution_record | jq -r .status)
message=$(echo $execution_record | jq -r .message)

if [ "$status" != "success" ]; then
	echo "Oops! $message"
	die
fi

execution=$(echo $execution_record | jq -r .result.executionId)

sleeptime=0.100
runstatus=
while [  "$runstatus" != "COMPLETE" ]; do
	execution_record=$(curl -H "Authorization: Bearer $token" -sk -X GET "$base/actors/v2/$actor/executions/$execution")
	runstatus=$(echo $execution_record | jq -r .result.status)
	sleep $sleeptime
	sleeptime=$(echo ${sleeptime} \* 1.05 | bc -l)
done

ENDTIME=$(date +%s)

logs_record=$(curl -H "Authorization: Bearer $token" -sk -X GET --data "message=classify" "$base/actors/v2/$actor/executions/$execution/logs")
logs=$(echo $logs_record | jq -r .result.logs)

echo -e "$logs"

>&2 echo "runtime: $(($ENDTIME - $STARTTIME)) seconds"

set +e

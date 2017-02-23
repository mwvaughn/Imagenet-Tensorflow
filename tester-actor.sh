#!/bin/bash

set -e

export actor=60f2c2b6-f9f6-11e6-90b1-0242ac110005-059
export base=https://dev.tenants.staging.agaveapi.co
export token=20eab246a12fd55ffb972e4e2d68d9d5

stderr () {

	if [[ -n $benchmark  ]];
	then
		>&2 echo -e $1
	fi

}

die () { echo "An error occurred ($1) and has caused this task to fail"; }

data_url=$1
predictions=$2
data_name="classify.img"
benchmark=$benchmark

# Die if URL NOT specified
if [[  -z  $data_url  ]];
	then
	die "\$data_url was not provided"
fi

if [[  -z  $predictions  ]];
	then
	predictions=5
fi

data_url=$(urlencode $data_url)
data_name=$(urlencode $data_name)

STARTTIME=$(date +%s)

execution_record=$(curl -H "Authorization: Bearer $token" -sk -X POST --data "message=classify" "$base/actors/v2/$actor/messages?data_url=${data_url}&data_name=${data_name}&predictions=${predictions}&pretty=true")

stderr "executionid\t$(echo $execution_record | jq -r .result.executionId)"
stderr "test-start\t$(gdate -u +%Y-%m-%dT%H:%M:%S.%9NZ)"

status=$(echo $execution_record | jq -r .status)
message=$(echo $execution_record | jq -r .message)

if [ "$status" != "success" ]; then
	die ${message}
fi

execution=$(echo $execution_record | jq -r .result.executionId)

sleeptime=0.100
runstatus=
while [  "$runstatus" != "COMPLETE" ]; do
	execution_record=$(curl -H "Authorization: Bearer $token" -sk -X GET "$base/actors/v2/$actor/executions/$execution")
	runstatus=$(echo $execution_record | jq -r .result.status)
	sleep $sleeptime
done

ENDTIME=$(date +%s)

exec_final_start=$(echo $execution_record | jq -r .result.finalState.StartedAt)
stderr "exec-start\t$exec_final_start"

exec_final_finish=$(echo $execution_record | jq -r .result.finalState.FinishedAt)
stderr "exec-finish\t$exec_final_finish"

if [[ -z $benchmark  ]];
then
	logs_record=$(curl -H "Authorization: Bearer $token" -sk -X GET --data "message=classify" "$base/actors/v2/$actor/executions/$execution/logs")
	logs=$(echo $logs_record | jq -r .result.logs)
	echo -e "$logs"
fi

stderr "test-finish\t$(gdate -u +%Y-%m-%dT%H:%M:%S.%9NZ)"
stderr "test-total\t$(($ENDTIME - $STARTTIME)) seconds"

set +e

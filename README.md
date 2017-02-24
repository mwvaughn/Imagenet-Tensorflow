# Imagenet Tensorflow as a Service Using Abaco

https://github.com/TACC/abaco/

## Build and push container to public Docker hub

```./build.sh```

## Test locally

Edit tester.env to set variables

```./tester.sh```

## Create actor

```
export base=https://dev.tenants.staging.agaveapi.co
export token=20eab246a12fd55ffb972e4e2d68d9d5
curl -sk -X GET -H "Authorization: Bearer $token" $base/actors/v2

# Create a new actor for imagenet-tensorflow
curl -H "Authorization: Bearer $token" -sk -X POST --data "description=Imagenet%20Classifier%20using%20Tensorflow&stateless=true&image=mwvaughn/imagenet-tensorflow-reactor&name=imagenet-tensorflow" $base/actors/v2?pretty=true

{
  "message": "Actor created successfully.",
  "result": {
    "_links": {
      "executions": "https://dev.tenants.staging.agaveapi.co/actors/v2/ef2cb526-fae2-11e6-bf76-0242ac110005-059/executions",
      "owner": "https://dev.tenants.staging.agaveapi.co/profiles/v2/abaco_admin",
      "self": "https://dev.tenants.staging.agaveapi.co/actors/v2/ef2cb526-fae2-11e6-bf76-0242ac110005-059"
    },
    "defaultEnvironment": {},
    "description": "Imagenet Classifier using Tensorflow",
    "id": "ef2cb526-fae2-11e6-bf76-0242ac110005-059",
    "image": "mwvaughn/imagenet-tensorflow-reactor",
    "name": "imagenet-tensorflow",
    "owner": "abaco_admin",
    "privileged": false,
    "state": {},
    "stateless": true,
    "status": "SUBMITTED",
    "statusMessage": ""
  },
  "status": "success",
  "version": "0.1"
}

export actor=ef2cb526-fae2-11e6-bf76-0242ac110005-059

# Poll actor status

curl -sk -X GET -H "Authorization: Bearer $token" $base/actors/v2/$actor?pretty=true

{
  "message": "Actor retrieved successfully.",
  "result": {
    "_links": {
      "executions": "https://dev.tenants.staging.agaveapi.co/actors/v2/ef2cb526-fae2-11e6-bf76-0242ac110005-059/executions",
      "owner": "https://dev.tenants.staging.agaveapi.co/profiles/v2/abaco_admin",
      "self": "https://dev.tenants.staging.agaveapi.co/actors/v2/ef2cb526-fae2-11e6-bf76-0242ac110005-059"
    },
    "defaultEnvironment": {},
    "description": "Imagenet Classifier using Tensorflow",
    "id": "ef2cb526-fae2-11e6-bf76-0242ac110005-059",
    "image": "mwvaughn/imagenet-tensorflow-reactor",
    "name": "imagenet-tensorflow",
    "owner": "abaco_admin",
    "privileged": false,
    "state": {},
    "stateless": true,
    "status": "READY",
    "statusMessage": ""
  },
  "status": "success",
  "version": "0.1"
}

# Execute a task
# Pass variables in as a JSON object

curl -H "Authorization: Bearer $token" -sk -X POST -H "Content-type:application/json" -d '{"data_url": "https://columbuszoo.org/Media/columbus-zoo-aquarium-2/my-barn---grahm-s-jones-columbus-zoo-and-aquarium.jpg", "data_name": "barn.jpg", "predictions": "3"}' $base/actors/v2/$actor/messages?pretty=true

{
  "message": "The request was successful",
  "result": {
    "_links": {
      "messages": "https://dev.tenants.staging.agaveapi.co/actors/v2/ef2cb526-fae2-11e6-bf76-0242ac110005-059/messages",
      "owner": "https://dev.tenants.staging.agaveapi.co/profiles/v2/abaco_admin",
      "self": "https://dev.tenants.staging.agaveapi.co/actors/v2/ef2cb526-fae2-11e6-bf76-0242ac110005-059/executions/34998ec0-fae3-11e6-80a4-0242ac110006-053"
    },
    "executionId": "34998ec0-fae3-11e6-80a4-0242ac110006-053",
    "msg": {
      "data_name": "monkey.jpg",
      "data_url": "http://ste.india.com/sites/default/files/2016/01/21/452974-monkey.jpg",
      "predictions": "3"
    }
  },
  "status": "success",
  "version": "0.1"
}

# Find status of execution
curl -sk -X GET -H "Authorization: Bearer $token" $base/actors/v2/$actor/executions/$execution?pretty=true

{
  "message": "Actor execution retrieved successfully.",
  "result": {
    "_links": {
      "logs": "https://dev.tenants.staging.agaveapi.co/actors/v2/DEV-STAGING_ef2cb526-fae2-11e6-bf76-0242ac110005-059/executions/34998ec0-fae3-11e6-80a4-0242ac110006-053/logs",
      "owner": "https://dev.tenants.staging.agaveapi.co/profiles/v2/abaco_admin",
      "self": "https://dev.tenants.staging.agaveapi.co/actors/v2/DEV-STAGING_ef2cb526-fae2-11e6-bf76-0242ac110005-059/executions/34998ec0-fae3-11e6-80a4-0242ac110006-053"
    },
    "actorId": "ef2cb526-fae2-11e6-bf76-0242ac110005-059",
    "apiServer": "https://dev.tenants.staging.agaveapi.co",
    "cpu": 14630339804,
    "executor": "abaco_admin",
    "exitCode": 0,
    "finalState": {
      "Dead": false,
      "Error": "",
      "ExitCode": 0,
      "FinishedAt": "2017-02-24T22:47:27.533811498Z",
      "OOMKilled": false,
      "Paused": false,
      "Pid": 0,
      "Restarting": false,
      "Running": false,
      "StartedAt": "2017-02-24T22:47:23.948651903Z",
      "Status": "exited"
    },
    "id": "34998ec0-fae3-11e6-80a4-0242ac110006-053",
    "io": 118727,
    "runtime": 4,
    "status": "COMPLETE",
    "workerId": "ef2cdf9a-fae2-11e6-9879-0242ac110005-060"
  },
  "status": "success",
  "version": "0.1"
}

# Now fetch the log, which is STDOUT and 
# should contain the classification info

curl -sk -X GET -H "Authorization: Bearer $token" $base/actors/v2/$actor/executions/$execution/logs?pretty=true

{
  "message": "Logs retrieved successfully.",
  "result": {
    "_links": {
      "execution": "https://dev.tenants.staging.agaveapi.co/actors/v2/6c473b1c-fae6-11e6-9664-0242ac110005-059/executions/9ac40b38-fae6-11e6-8bc2-0242ac110006-053",
      "owner": "https://dev.tenants.staging.agaveapi.co/profiles/v2/abaco_admin",
      "self": "https://dev.tenants.staging.agaveapi.co/actors/v2/6c473b1c-fae6-11e6-9664-0242ac110005-059/executions/9ac40b38-fae6-11e6-8bc2-0242ac110006-053/logs"
    },
    "logs": "barn (score = 0.98347)\nchurch, church building (score = 0.00107)\nboathouse (score = 0.00060)\n"
  },
  "status": "success",
  "version": "0.1"
}

```


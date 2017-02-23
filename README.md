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
      "executions": "https://dev.tenants.staging.agaveapi.co/actors/v2/7ba286ec-f956-11e6-9c50-0242ac110005-059/executions",
      "owner": "https://dev.tenants.staging.agaveapi.co/profiles/v2/abaco_admin",
      "self": "https://dev.tenants.staging.agaveapi.co/actors/v2/7ba286ec-f956-11e6-9c50-0242ac110005-059"
    },
    "defaultEnvironment": {},
    "description": "Imagenet Classifier using Tensorflow",
    "id": "7ba286ec-f956-11e6-9c50-0242ac110005-059",
    "image": "mwvaughn/imagenet-tensorflow-reactor",
    "name": "imagenet-tensorflow",
    "owner": "abaco_admin",
    "privileged": false,
    "state": {},
    "stateless": true,
    "status": "SUBMITTED"
  },
  "status": "success",
  "version": "0.01"
}

export actor=a64baab0-f9ed-11e6-b790-0242ac110005-059

# Poll actor status

curl -sk -X GET -H "Authorization: Bearer $token" $base/actors/v2/$actor?pretty=true

{
  "message": "Actor retrieved successfully.",
  "result": {
    "_links": {
      "executions": "https://dev.tenants.staging.agaveapi.co/actors/v2/7ba286ec-f956-11e6-9c50-0242ac110005-059/executions",
      "owner": "https://dev.tenants.staging.agaveapi.co/profiles/v2/abaco_admin",
      "self": "https://dev.tenants.staging.agaveapi.co/actors/v2/7ba286ec-f956-11e6-9c50-0242ac110005-059"
    },
    "defaultEnvironment": {},
    "description": "Imagenet Classifier using Tensorflow",
    "id": "7ba286ec-f956-11e6-9c50-0242ac110005-059",
    "image": "mwvaughn/imagenet-tensorflow-reactor",
    "name": "imagenet-tensorflow",
    "owner": "abaco_admin",
    "privileged": false,
    "state": {},
    "stateless": true,
    "status": "READY"
  },
  "status": "success",
  "version": "0.01"
}

# Execute a task
# Pass environment vars for container as query parameters
# Don't forget to uuencode

curl -H "Authorization: Bearer $token" -sk -X POST --data "message=classify" "$base/actors/v2/$actor/messages?data_url=http%3A%2F%2Fste.india.com%2Fsites%2Fdefault%2Ffiles%2F2016%2F01%2F21%2F452974-monkey.jpg&data_name=monkey.jpg&predictions=3&pretty=true"

{
  "message": "The request was successful",
  "result": {
    "_links": {
      "messages": "https://dev.tenants.staging.agaveapi.co/actors/v2/7ba286ec-f956-11e6-9c50-0242ac110005-059/messages",
      "owner": "https://dev.tenants.staging.agaveapi.co/profiles/v2/abaco_admin",
      "self": "https://dev.tenants.staging.agaveapi.co/actors/v2/7ba286ec-f956-11e6-9c50-0242ac110005-059/executions/d1bd189e-f956-11e6-b979-0242ac110006-053"
    },
    "executionId": "d1bd189e-f956-11e6-b979-0242ac110006-053",
    "msg": "classify"
  },
  "status": "success",
  "version": "0.01"
}

# Find status of execution
curl -sk -X GET -H "Authorization: Bearer $token" $base/actors/v2/$actor/executions/$execution?pretty=true

{
  "message": "Actor execution retrieved successfully.",
  "result": {
    "_links": {
      "logs": "https://dev.tenants.staging.agaveapi.co/actors/v2/DEV-STAGING_7ba286ec-f956-11e6-9c50-0242ac110005-059/executions/d1bd189e-f956-11e6-b979-0242ac110006-053/logs",
      "owner": "https://dev.tenants.staging.agaveapi.co/profiles/v2/abaco_admin",
      "self": "https://dev.tenants.staging.agaveapi.co/actors/v2/DEV-STAGING_7ba286ec-f956-11e6-9c50-0242ac110005-059/executions/d1bd189e-f956-11e6-b979-0242ac110006-053"
    },
    "actorId": "7ba286ec-f956-11e6-9c50-0242ac110005-059",
    "apiServer": "https://dev.tenants.staging.agaveapi.co",
    "cpu": 12558664280,
    "executor": "abaco_admin",
    "id": "d1bd189e-f956-11e6-b979-0242ac110006-053",
    "io": 118331,
    "runtime": 4,
    "status": "COMPLETE"
  },
  "status": "success",
  "version": "0.01"
}

# Now fetch the log, which is STDOUT and 
# should contain the classification info

curl -sk -X GET -H "Authorization: Bearer $token" $base/actors/v2/$actor/executions/$execution/logs?pretty=true

{
  "message": "Logs retrieved successfully.",
  "result": {
    "_links": {
      "execution": "https://dev.tenants.staging.agaveapi.co/actors/v2/7ba286ec-f956-11e6-9c50-0242ac110005-059/executions/d1bd189e-f956-11e6-b979-0242ac110006-053",
      "owner": "https://dev.tenants.staging.agaveapi.co/profiles/v2/abaco_admin",
      "self": "https://dev.tenants.staging.agaveapi.co/actors/v2/7ba286ec-f956-11e6-9c50-0242ac110005-059/executions/d1bd189e-f956-11e6-b979-0242ac110006-053/logs"
    },
    "logs": "macaque (score = 0.71029)\nbaboon (score = 0.06636)\npatas, hussar monkey, Erythrocebus patas (score = 0.03243)\n"
  },
  "status": "success",
  "version": "0.01"
}


# Another execution, this time with another image

curl -H "Authorization: Bearer $token" -sk -X POST --data "message=classify" "$base/actors/v2/$actor/messages?data_url=https%3A%2F%2Fcolumbuszoo.org%2FMedia%2Fcolumbus-zoo-aquarium-2%2Fmy-barn---grahm-s-jones-columbus-zoo-and-aquarium.jpg&data_name=barn.jpg&predictions=8&pretty=true"

{
  "message": "Logs retrieved successfully.",
  "result": {
    "_links": {
      "execution": "https://dev.tenants.staging.agaveapi.co/actors/v2/7ba286ec-f956-11e6-9c50-0242ac110005-059/executions/e32bd0d0-f957-11e6-b7cd-0242ac110006-053",
      "owner": "https://dev.tenants.staging.agaveapi.co/profiles/v2/abaco_admin",
      "self": "https://dev.tenants.staging.agaveapi.co/actors/v2/7ba286ec-f956-11e6-9c50-0242ac110005-059/executions/e32bd0d0-f957-11e6-b7cd-0242ac110006-053/logs"
    },
    "logs": "barn (score = 0.98347)\nchurch, church building (score = 0.00107)\nboathouse (score = 0.00060)\nlumbermill, sawmill (score = 0.00025)\nworm fence, snake fence, snake-rail fence, Virginia fence (score = 0.00016)\nalp (score = 0.00015)\nlibrary (score = 0.00013)\npicket fence, paling (score = 0.00011)\n"
  },
  "status": "success",
  "version": "0.01"
}

```


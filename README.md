# Imagenet Tensorflow as a Service Using Abaco

_[Abaco](https://github.com/TACC/abaco/) is a web service and distributed system that implements the actor model of concurrent computation whereby each actor registered in the system is associated with a Docker image. Actor containers are executed in response to messages posted to their inbox which itself is given by a URI exposed via abaco. In the process of executing the actor container, state, logs and execution statistics are collected._

This repository provides a worked example of deploying a classifier based on Tensorflow as an Abaco container. 

Pre-requisites:

1. Up-to-date Linux or macOS 
2. Docker 1.12+
3. curl 7.43+
4. An account on the public Docker Hub
5. Familiarity with Bash shell, environment variables, and Python
6. Access to an Abaco installation

## Outline

Here's the general sequence of steps for deploying a container-as-a-service using Abaco...

1. Design, build, and test your code as a function inside a local Docker container
2. Push your container to the public Docker Hub
3. Register your container as an Abaco container
4. Execute your container by sending a message
5. Fetch the logs and results

### Design, build, and test your code as a function inside a local Docker container

Each container in Abaco must be able to:
* Access and retrieve external data (optional, per use case)
* Accomplish the desired function by running its default `ENTRYPOINT` (mandatory)
  * Learn the parameters for container execution from one or more environment variables (mandatory)
* Write results of the execution to some defined location (optional, per use case)

We started with an [existing container](https://github.com/atong01/Imagenet-Tensorflow) that someone else designed to do ImageNet classification. You can also start from the ground up and craft your own container.

I set out to implement the following behavior for my Abaco container:

Given a URL pointing to an image file, an optional filename, and a optional number of predictions

1. Download the URL to a file
2. Perform ImageNet classification on it
3. Print the classification to STDOUT to be captured as a log

The original ImagetNet::Tensorflow image was invokable like so:

```docker run -v $PWD:/root/tmp:ro atong01/imagenet-tensorflow python classify_image.py --image_file tmp/$(IMAGE)```

This is close to the desired behavior, but we need URL handling and some baby bumpers on the parameterization. Also, we need to be able to read parameters from an environment variable provided by the Abaco platform. The worked implementation of this is found in [runner.py](runner.py)

When you read the `runner.py` source, keep an eye out for a few things:

1. We read in parameters from an environment variable called `MSG`
2. They are in the form of a JSON-like object but aren't quite JSON
3. In keeping with the functions-as-a-service model, `runner.py`'s essential behavior is available in `main()` 
4. The ONLY text printed to `STDOUT` is the classification on success. For everything else we try to raise an Exception and print error text there. This helps the container engine know whether success has happened.
5. Like AWS Lambda, we have to manually orchestrate the data ingest and, should we have chosen to, egress. Unlike Lambda or other similar platforms, we are using a full container and so have to manage `requirements.txt` ourselves
6. We use a very defensive setup (`subprocess.Popen()` without `Shell=false`) to handle forking a classifier process with user-specified parameters

In order to isolate the initial debugging to a local environment without worrying about getting all the Abaco platform stuff working, we test using a simple [tester.sh](tester.sh) script that populates a `MSG` environment variable in a local version of our container and invokes the default entrypoint manually. Rather than hard-coding the environment into `tester.sh`, it is defined in [tester.env](tester.env). One major objective in taking this approach is to avoid URL-escaping issues that will torment even the most seasoned developers. Note that we don't have to escape the URL for the test image by following this approach!

#### The Dockerfile

The objective of an Abaco-compatible [Dockerfile](Dockerfile) is to ensure that the container has all the capabilities it needs to serve its functions. Most of the heavy-lifting Tensorflow stuff is built into the base `tensorflow/tensorflow:latest` image, but we still need to:

1. Install Python requests with current PyOpenSSL support
2. Over-ride the work directory since it's `/notebooks` in the `tensorflow` image by default
3. Define the `ENTRYPOINT` to point a copy of `runner.py` in the container

## Using This Example Repository

First, create a `config.rc` file, following the example provided in [config.rc.sample](config.rc.sample). Then, source it.

`. config.rc`

*You must source config.rc every time you begin working in this repository anew* 

Next, build your local version of the container

`./build.sh`

Now, test locally. Since `tester.env` points at a photo of a barn, the results should not shock you.

![This is definitely a barn][https://columbuszoo.org/Media/columbus-zoo-aquarium-2/my-barn---grahm-s-jones-columbus-zoo-and-aquarium.jpg]
*barn.jpg*

```./tester.sh 
barn (score = 0.98347)
church, church building (score = 0.00107)
boathouse (score = 0.00060)
lumbermill, sawmill (score = 0.00025)
worm fence, snake fence, snake-rail fence, Virginia fence (score = 0.00016)
alp (score = 0.00015)
tester-runtime: 8 seconds
```

Push the container to Docker Hub.

`./publish.sh`

Create an actor. You will do this by `POST`-ing to the `/actors` endpoint of the Abaco service

```
. config.rc
curl -sk -X GET -H "Authorization: Bearer $token" $base/actors/v2

# Create a new actor for imagenet-tensorflow
# Note we are using environment variables for the org/containerset in config.rc to define "image"
curl -H "Authorization: Bearer $token" -sk -X POST --data "description=Imagenet%20Classifier%20using%20Tensorflow&stateless=true&image=${huborg}/${hubimage}&name=imagenet-tensorflow" $base/actors/v2?pretty=true

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

=======
#Imagenet Tensorflow

Single command imagenet classifier run through docker.

Use the following command for the default image:
```
docker run atong01/imagenet-tensorflow python classify_image.py
```
or
```
sh run.sh 
```

expected output
```
running on default
-----------------------------------------------------------------------------
giant panda, panda, panda bear, coon bear, Ailuropoda melanoleuca (score = 0.89233)
indri, indris, Indri indri, Indri brevicaudatus (score = 0.00859)
lesser panda, red panda, panda, bear cat, cat bear, Ailurus fulgens (score = 0.00264)
custard apple (score = 0.00141)
earthstar (score = 0.00107)
```

Or, to use your own image file:
```
docker run -v $PWD:/root/tmp:ro atong01/imagenet-tensorflow python classify_image.py --image_file tmp/$(IMAGE)
```
or
```
sh run.sh $(IMAGE)
```
Where $(IMAGE) is the imagename, note that your $PWD must be a parent directory of your imagefile.

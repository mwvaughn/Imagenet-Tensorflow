#!/bin/bash

set -e

# Inherit specific key:value settings from ENV
# These are passed into the container by Abaco
# when an execution is requested. They are set
# by specifying extra parameters in the POST
# sent to the actor's /messages endpoint

die () { echo "An error occurred and has caused this task to fail"; }

data_url=${data_url}
data_name=${data_name:-input}
predictions=${predictions:-5}

# Die if URL NOT specified
if [[  -z  $data_url  ]];
	then
	die
fi

{ # try
    curl -skL -o "${data_name}" "${data_url}" &&
    python classify_image.py --num_top_predictions "${predictions}" --image_file "${PWD}/${data_name}" 2> /dev/null

} || { # catch
    die
}

set +e

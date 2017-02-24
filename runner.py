#!/usr/bin/env python

from __future__ import print_function

import os
import json
import ast
import subprocess

import requests


'''
Objective: Materialize event as a dict
Have to use ast instead of json.dumps because MSG comes in single-quoted
MSG={'predictions': '3', 'data_name': 'monkey.jpg', 'data_url': 'http://ste.india.com/sites/default/files/2016/01/21/452974-monkey.jpg'}
'''
try:
    event = ast.literal_eval(os.environ['MSG'])
except:
    raise EnvironmentError("MSG not set or interepretable as a dict object.")


def main(event):

    # Check parameterization
    #
    # data_url is mandatory
    assert 'data_url' in event, "data_url was not defined"
    data_url = event['data_url']

    if 'data_name' in event:
        data_name = event['data_name']
    else:
        data_name = 'classify.img'

    if 'predictions' in event:
        predictions = int(event['predictions'])
    else:
        predictions = 3

    # Fetch data_url using requests
    #
    # Use streaming for memory efficiency
    try:
        r = requests.get(data_url, stream=True)
        if r.status_code == 200:
            with open(data_name, 'wb') as f:
                for chunk in r.iter_content(1024):
                    f.write(chunk)
    except:
        raise IOError("data_url was not downloaded")

    # Launch our classifier as subprocess
    cmd = ['python', 'classify_image.py', '--num_top_predictions',
                     str(predictions), '--image_file',
                     os.path.realpath(data_name)]
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=None)
    for line in p.stdout.readlines():
        print(line, end='')


if __name__ == "__main__":
    main(event)

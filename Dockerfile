FROM            tensorflow/tensorflow:latest

MAINTAINER      Matthew Vaughn <vaughn@tacc.utexas.edu>

# Turn off all the "helpful" log messages from Tensorflow
ENV TF_CPP_MIN_LOG_LEVEL 3

# Make the image HTTPS/SSL compatible for file ingest
RUN apt-get -y update && \
	apt-get -y upgrade && \
	apt-get -y install libffi-dev libssl-dev && \
	rm -rf /var/lib/apt/lists/*
	
ADD requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# 
COPY            model /tmp/imagenet
COPY            classify_image.py /root/classify_image.py
COPY 			runner.py /root/runner.py

WORKDIR /root

ENTRYPOINT /root/runner.py

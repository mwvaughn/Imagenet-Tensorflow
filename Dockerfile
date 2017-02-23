FROM            tensorflow/tensorflow:latest

MAINTAINER      Matthew Vaughn <vaughn@tacc.utexas.edu>

COPY            classify_image.py /root/classify_image.py

COPY            model /tmp/imagenet

COPY runner.sh /root/runner.sh

WORKDIR /root

ENTRYPOINT /root/runner.sh


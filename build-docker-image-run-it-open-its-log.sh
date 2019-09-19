#!/bin/bash
dockid=`docker container ps -all | awk '{ print $1}' | grep -v CONTAINER`
docker container rm $dockid
docker build --tag=nhs-solr:1.0 .
# docker run -d -p 8983:8983 --name solr-docker-p nhs-solr:1.0 
docker run -d --name solr-docker-p nhs-solr:1.0 
docker container ps -all
dockid=`docker container ps -all | awk '{ print $1}' | grep -v CONTAINER`
docker container logs -f $dockid


#!/bin/bash

#
# minikube_certs.sh
#

# minikube_ip=$(minikube ip)
# ssh minikube@$minikube_ip mkdir -p /etc/docker/certs.d/pjmd-ubuntu.com/
minikube ssh 'sudo mkdir -p /etc/docker/certs.d/pjmd-ubuntu.com/; \
cd /etc/docker/certs.d/pjmd-ubuntu.com/; \
sudo scp pjmd@pjmd-ubuntu.com:/etc/docker/certs.d/pjmd-ubuntu.com/domain.crt .'



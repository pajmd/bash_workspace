#!/bin/bash 

#
# This script is kind of aliasing "docker" in the same fashion 
# as k is aliasing kubectrl but mainly it is more a convenient way
# for me to list my private repo without having to remember an another
# set of scripts or commands
# The "hub" is defined in the HUB env variable
#
# https://forums.docker.com/t/registry-v2-catalog/45368/3
#
hub=${HUB:-"pjmd-ubuntu.com"}

function usage() {
cat << EOF

$(basename $0) is a alias for docker

Usage: $(basename $0) [OPTIONS] COMMAND

COMMANDS:
	repo [option]			list private repos
	repo [option] image 	list all images for repo

	option: -e to get official docker registry images

Or docker native commands:

  $(>/tmp/temp docker --help; tail -n +4 /tmp/temp)
EOF
exit 0
}

function get_docker_hub() {
	TOKEN=`curl "https://auth.docker.io/token?service=registry.docker.io&scope=repository:pajmd/nhs_piper:pull" | jq .token | tr -d \"`
	curl  -H "Authorization: Bearer $TOKEN" https://registry-1.docker.io/v2/pajmd/nhs_piper/tags/list
{"name":"pajmd/nhs_piper","tags":["v0.0.1-7-g07f9040","v0.0.2"]}
}

function get_docker_hub_images() {
	TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_UNAME}'", "password": "'${DOCKER_UPASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)
	# To get all the name spaces for the user
	# curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/namespaces/ | jq -r '.namespaces|.[]'
	repos=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${DOCKER_UNAME}/?page_size=10000 | jq -r '.results|.[]|.name')
	for r in $repos; do
		tags=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${DOCKER_UNAME}/$r/tags/?page_size=10000 | jq -r '.results|.[]|.name')
		for t in $tags; do
			printf "$DOCKER_UNAME/$r:$t\n"
		done
		printf "\n"
	done
}

function get_images() {
	repo=$1
	images=$(curl --silent -X GET https://$hub/v2/$repo/tags/list | jq '.tags[]')
	for image in $images; do
		image=${image#*\"}
		image=$repo":"${image%*\"}
		echo $hub"/"$image
	done;
	printf "\n"
}

if [[ -z $1 || $1 == '--help' ]]; then
	usage
elif [[ $1 == repo* ]]; then
	if [[ ! -z $2 ]]; then
		if [[ $2 == '-e' ]]; then
			if [[ -z $DOCKER_UNAME || -z $DOCKER_UPASS ]]; then
				printf "\nError: Browsinging trough Docker Hub but DOCKER_DOCKER_UPASS or DOCKER_UPASS not set\n\n"
				# usage
			else
				get_docker_hub_images
			fi
		else
			get_images $2
		fi
	else
	  repos=$(curl --silent -X GET https://$hub/v2/_catalog | jq '.repositories[]')
	  for r in $repos;
	  do
	  	r=${r#*\"}
	  	r=${r%*\"}
	  	get_images $r
	  done;
	fi
else
  docker $@
fi

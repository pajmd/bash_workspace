#!/bin/bash

# apt-get update
# apt-get install jq

if [[ -z username ]]; then
cat << EOF

Usage:
basename $0 <username> where username is the name of the github user.

EOF
exit 1
fi

username=$1
curl --silent https://api.github.com/users/$username/repos | jq '.[] | .name'

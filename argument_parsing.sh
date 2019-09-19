#!/bin/bash

function usage() {
	cat << EOM
	$0 -o option1 -b option2 ...
EOM
}

default_value="default value in case parameter is not set"

if [[ -z $1 && -z $default_value ]]; then
	usage
fi

p1=${1:-$default_value}
p2="${2:-}"

echo list of parameters $@
echo "p1: "$p1
echo "p2: "$p2

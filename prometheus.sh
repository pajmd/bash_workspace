#!/bin/bash

# this scruipt starts or stops prometheus
# https://prometheus.io/docs/prometheus/latest/getting_started/

function usage() {
	cat << EOF

This script starts prometheus on port 9090.
The script assumes prometheus is installed in $HOME/prometheus.

Usage: $0 [start|stop]

EOF
}

if [[ -z "$1" ]]; then
	usage
elif [[ $1 == "start" || $1 == "stop" ]]; then
	if [[ $1 == "start" ]]; then
		echo "Starting prometheus"
		cd $HOME/prometheus
		./prometheus --config.file="prometheus.yml" &
		echo $! > /tmp/prometheus.pid
	else
		echo "Stopping prometheus"
		pid=$(cat /tmp/prometheus.pid)
		kill -9 $pid
	fi
else
	echo "Error - Unknown option: $1"
	usage
fi
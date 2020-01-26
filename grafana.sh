#!/bin/bash

# this scruipt starts or stops grafana
# https://grafana.com/docs/grafana/latest/installation/debian/

function usage() {
	cat << EOF

This script starts grafana on port 3000 (see default.ini).
The script assumes grafana is installed in $HOME/grafana.
Default login admin/admin

Usage: $0 [start|stop]

EOF
}

if [[ -z "$1" ]]; then
	usage
elif [[ $1 == "start" || $1 == "stop" ]]; then
	if [[ $1 == "start" ]]; then
		echo "Starting Grafana"
		cd $HOME/grafana
		./bin/grafana-server web &
		echo $! > /tmp/grafana.pid
	else
		echo "Stopping grafana"
		pid=$(cat /tmp/grafana.pid)
		kill -9 $pid
	fi
else
	echo "Error - Unknown option: $1"
	usage
fi
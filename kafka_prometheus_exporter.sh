#!/bin/bash 

# kafka_prometheus_exporter
# https://github.com/danielqsj/kafka_exporter

function usage() {
	cat << EOF

This script assumes:
- there is only one instance of kafka running on localhost:9092
- the kafka exporter is in $HOME/kafka_exporter

Usage: $0 [start|stop]

EOF
}

if [[ -z "$1" ]]; then
	usage
elif [[ $1 == "start" || $1 == "stop" ]]; then
	if [[ $1 == "start" ]]; then
		echo "Starting Kafka prometheus exporter"
		$HOME/kafka_exporter/kafka_exporter --kafka.server=localhost:9092 &
		echo $! > /tmp/kafka_exporter.pid
	else
		echo "Stopping Kafka prometheus exporter"
		pid=$(cat /tmp/kafka_exporter.pid)
		kill -9 $pid
	fi
else
	echo "Error - Unknown option: $1"
	usage
fi
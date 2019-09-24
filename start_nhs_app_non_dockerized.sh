#!/bin/bash

#
# the roor folder of all the script can be passed in as arg 1
#
# This script: 
# starts on localhost (not docker!)
# - zookeeper
# - solr
# copies
# the solr configs to the keeper


if [[ $(hostname) == "pjmd-ubuntu16" ]]; then
	PYCHARM_PROJECT="PycharmProjects"
else
	PYCHARM_PROJECT="PychramProjects"
fi
echo $PYCHARM_PROJECT
root_dir=${2:-"/home/pjmd"}
zoo_root=$root_dir"/apache-zookeeper-3.5.5-bin"
solr_root=$root_dir"/solr-7.7.2"
project_root=$root_dir/python_workspace/$PYCHARM_PROJECT
echo "User home folder: $root_dir"
echo "Zoo Root folder: $zoo_root"
echo "Solr Root: $solr_root"
echo "Project root: $project_root"


usage() {
	cat << EOF
To start the nhs app:

usage: $0 [start|stop|restart|cleanstart] [user home folder]

EOF
	exit 0
}


function start_zookeeper() {
	# zookeeper on 2181, 2182, 2183
	$zoo_root/bin/zoo-ensemble.sh start

	# creates zknode for solr conf
	$solr_root/bin/solr zk mkroot /my_solr_conf -z localhost:2181,localhost:2182,localhost:2183 
	# upload solr configset (ther ref one) to zookeeper
	$solr_root/server/scripts/cloud-scripts/zkcli.sh -z localhost:2181,localhost:2182,localhost:2183/my_solr_conf -cmd upconfig \
													-confname mongoConnectorBaseConfig \
													-confdir /home/pjmd/python_workspace/$PYCHARM_PROJECT/scrapy_nhs/nhs/resources/solr/configsets/mongoConnectorConfig/conf
}

function start_solr() {
	# start 2 instances solr
	$solr_root/bin/solr start -c -p 8983 -s $project_root/scrapy_nhs/nhs/resources/solr/solr_homes/node1 \
											-z localhost:2181,localhost:2182,localhost:2183/my_solr_conf && \
	$solr_root/bin/solr start -c -p 7574 -s $project_root/scrapy_nhs/nhs/resources/solr/solr_homes/node2 \
											-z localhost:2181,localhost:2182,localhost:2183/my_solr_conf	 
}

function create_solr_collection() {

	####### create config set and collection #########
	# copy configset the one that will mutate as we feed the collections
	curl "http://localhost:8983/solr/admin/configs?action=CREATE&name=mongoConnectorConfig&baseConfigSet=mongoConnectorBaseConfig&configSetProp.immutable=false&wt=json&omitHeader=true"

	# create the collection
	curl "http://localhost:8983/solr/admin/collections?action=CREATE&name=nhsCollection&collection.configName=mongoConnectorConfig&numShards=2&replicationFactor=2&maxShardsPerNode=2&wt=json"

	# add mongo fields to the collection
	curl -X POST -H 'Content-type:application/json' --data-binary @$project_root/scrapy_nhs/nhs/resources/solr/solr_fields/mongo_fields.json  http://localhost:8983/solr/nhsCollection/schema

}

function delete_collection() {

	####### delete #########
	# delete previous collection
	curl "http://localhost:8983/solr/admin/collections?action=DELETE&name=nhsCollection&wt=json"
	# delete prevous mutated config set
	curl "http://localhost:8983/solr/admin/configs?action=DELETE&name=mongoConnectorConfig"
}

function start_from_clean_slate() {
	start_zookeeper
	start_solr
	sleep 2
	delete_collection
	sleep 2
	create_solr_collection
}

function start_app() {
	start_zookeeper
	# bin/solr cp file:local/file/path/to/solr.xml zk:/znode/solr.xml -z localhost:2181

	start_solr
	create_solr_collection
}

function stop_app() {
	# stop all solr
	$solr_root/bin/solr stop -all && \
	$zoo_root/bin/zoo-ensemble.sh stop
}


runCommand() {
	if [ $1 = "start" ]; 
	then
		start_app
	elif [ $1 = "stop" ]; then
		stop_app
	elif [ $1 = "cleanstart" ]; then
	 	start_from_clean_slate
	else  [ $1 = "restart" ]
		echo " restart not yet implemented"
	fi
}


if [ -z "$1" ]
then
	usage
elif [ $1 = "start" ]; then
	cmd="start"
elif [ $1 = "stop" ]; then
		cmd="stop"
elif [ $1 = "cleanstart" ]; then
	cmd="cleanstart"
elif [ $1 = "restart" ]; then
		cmd=`echo "stop" "start"`
else
	echo $1: wrong command
	usage
fi

runCommand $cmd

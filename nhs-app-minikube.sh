#!/bin/bash

#
# Start all k8s manifest for nhs app
#

CHARTS=~/HelmWorkspace
APP=$CHARTS/nhs-app-helm-chart
KAFKA=$CHARTS/nhs-kafka-helm-chart

function usage() {
	cat << EOF

	$(basename $0) [sart | stop]

EOF
}
function start() {

	# make sure cert exists
	read -p "Do you want to transfer the cert [Y/N]: " res
	if [[ $res == 'Y' ]]; then
		$HOME/bin/minikube_certs.sh
	fi

	echo Starting zookeeper and solr .......................................................
	kubectl apply -f $APP/solr_schema_configmap.yaml
	kubectl apply -f $APP/solr.yaml

	echo Starting kafka ....................................................................
	kubectl apply -f $KAFKA/kafka-config.yaml
	kubectl apply -f $KAFKA/kafka-ss.yaml

	echo Starting mongo ....................................................................
	kubectl apply -f $APP/mongo.yaml

	echo Starting nhs server ...............................................................
	kubectl apply -f $APP/nhs_server_service_deployment.yaml

	echo Starting pipers ...................................................................
	kubectl apply -f $APP/nhs_pipers_deployment.yaml

	echo Starting scraper ..................................................................
	kubectl apply -f $APP/nhs_scrapy_job.yaml

}

delete_resources() {
	resources_type=$1
	shift
	resource_list=$@
	echo "********** list: $resource_list"
	for resource in $resource_list; do
		echo "============ delete $resources_type: $resource"
		kubectl delete $resources_type $resource --cascade=true
	done
}

function stop() {
	resources="jobs services statefulsets deployments configmaps pvc"

	declare -A resources_map

	resources_map["jobs"]="nhs-scrapy solr-collection"
	resources_map["services"]="kafka-broker kafka-svc kubernetes mongo nhsserver-service solr-headless solr-svc solr-svc-ext solr-zookeeper solr-zookeeper-headless"
	resources_map["statefulsets"]="kafka mongo solr solr-zookeeper"
	resources_map["deployments"]="nhs-mongo-piper-deployment nhs-server-deployment nhs-solr-piper-deployment"
	resources_map["configmaps"]="broker-config solr-config-map"
	resources_map["pvc"]="data-kafka-0 data-solr-zookeeper-0 data-solr-zookeeper-1 data-solr-zookeeper-2 mongo-persistent-storage-mongo-0 mongo-persistent-storage-mongo-1 mongo-persistent-storage-mongo-2 solr-pvc-solr-0 solr-pvc-solr-1 solr-pvc-solr-2"
	# resources_map[""]=""

	for a in $resources; do
		delete_resources $a ${resources_map[$a]}
		# typ=${resources_map[$a]}
	done
}

if [[ $1 == "start" ]]; then
	start
elif [[ $1 == "stop" ]]; then
	stop
else
	usage
fi
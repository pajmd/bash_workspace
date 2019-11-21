#!/bin/bash -xv

function wait-for() {
  cmd="$1"
  event="$2"
  COUNTER=0
  SLEEP_TIME=${DELAY:-2}
  MAX_COUNT=${MAX_LOOP:-20}
  echo "Executing: $cmd"

  while [  $COUNTER -lt 20 ]; do
    if $cmd; then
      echo "$event succeeded"
      break;
    else
      COUNTER=$(($COUNTER + 1))
      echo "Waiting $SLEEP_TIME sec for $event to succeed another $(($MAX_COUNT - $COUNTER)) times"
      sleep $SLEEP_TIME
    fi
  done
  if [ $COUNTER -eq $MAX_COUNT ]; then
    echo "Giving up on $event ..........."
    return 1
  fi
}

function is-solr-running() {
  wget -q -O - "$solr_url" | grep -q -i solr
}

function is-solr-cluster-number_reached() {
  [ $(curl "$solr_url"/solr/admin/collections?action=clusterstatus | jq '.cluster.live_nodes[]' | wc -l) -gt 2 ]
}

function is-solr-collection-creation-status-completed() {
  curl "$solr_url/solr/admin/collections?action=REQUESTSTATUS&requestid=5555&wt=json" | jq '.status.state' | grep -q 'completed'
}

function create-config() {
  config_name="$1"
  if curl "$solr_url/solr/admin/configs?action=CREATE&name=$config_name&baseConfigSet=mongoConnectorBaseConfig&configSetProp.immutable=false&wt=json&omitHeader=true" | jq ".error != null" | grep -q true; then
    echo "Failed creating $config_name, Exiting ..."
    exit 1
  fi
}

function create-collection() {
  collection_name="$1"
  config_name="$2"
  curl "$solr_url/solr/admin/collections?action=CREATE&name=$collection_name&async=5555&collection.configName=$config_name&numShards=2&replicationFactor=2&maxShardsPerNode=2&wt=json"
}

function clear-async-create-collection-request-id() {
  curl "$solr_url/solr/admin/collections?action=DELETESTATUS&requestid=5555"
}

function upload-mongo-fields() {
  collection_name="$1"
  curl -X POST -H "Content-type:application/json" --data-binary @/solr_mongo_fields/fields.json  "$solr_url"/solr/$collection_name/schema;
}


solr_url="$1"

event="solr running"
if wait-for is-solr-running "$event" ; then
  echo "Successssss.........."
  #  check enough node are running in the solr cluster
  event="Enough active solr nodes"
  if wait-for is-solr-cluster-number_reached "$event" ; then
    echo "Yessss........."
    # create config mongoConnectorConfig
    create-config "stuffConfig" 
    # create collection nhsCollection
    create-collection "stuffCollection" "stuffConfig" 
    # wait on status
    event="Status create collection completed"
    if wait-for is-solr-collection-creation-status-completed "$event" ; then
      echo "UPLOAD mongo fileds";
      upload-mongo-fields "stuffCollection"
   fi
   clear-async-create-collection-request-id
  fi  
fi

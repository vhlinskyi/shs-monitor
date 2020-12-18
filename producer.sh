#!/bin/bash

# Application ID. Matches event log file name
TEMPLATE_APP_ID=local-1608304925101

# s3 location of event log directory, omiting protocol(e.g. "shs-reproduce-bucket/eventlog") 
s3_location=$1
if [ -z ${s3_location} ]; then
	echo "Usage: ./producer.sh <s3-location>"
	exit 1
fi

RUN=true
stop() {
  echo "Stop producing event logs ..."
  RUN=false
}

trap 'stop' SIGTERM SIGINT

total_produced=0
while $RUN; do
	uuid=$(uuidgen)
	app_id=${uuid//-}

	mkdir -p .eventlog/eventlog_v2_$app_id/
	touch .eventlog/eventlog_v2_$app_id/appstatus_$app_id
	cp history/eventlog_v2_${TEMPLATE_APP_ID}/events_1_${TEMPLATE_APP_ID} .eventlog/eventlog_v2_$app_id/events_1_$app_id

	sed -i "s/$TEMPLATE_APP_ID/$app_id/g" .eventlog/eventlog_v2_$app_id/events_1_$app_id
	
	# Preserve the order to avoid SHS issues
	aws s3 cp .eventlog/eventlog_v2_$app_id/appstatus_$app_id s3://${s3_location}/eventlog_v2_$app_id/appstatus_$app_id >> out.log
	aws s3 cp .eventlog/eventlog_v2_$app_id/events_1_$app_id s3://${s3_location}/eventlog_v2_$app_id/events_1_$app_id >> out.log
	total_produced=$(( $total_produced + 1 ))
	
	info="$(date '+%d/%m/%Y %H:%M:%S'),$total_produced"
	echo $info
	rm -rf .eventlog/eventlog_v2_$app_id
done

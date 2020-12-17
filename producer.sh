#!/bin/bash

# Application ID. Matches event log file name
TEMPLATE_APP_ID=local-1608227687233

# s3 location of event log directory, omiting protocol(e.g. "shs-reproduce-bucket/eventlog") 
s3_location=$1
if [ -z ${s3_location} ]; then
	echo "Usage: ./producer.sh <s3-location>"
	exit 1
fi

total_produced=0
while true; do
	uuid=$(uuidgen)
	app_id=${uuid//-}

	mkdir -p .eventlog/
	cp history/${TEMPLATE_APP_ID} .eventlog/local-$app_id

	sed -i "s/$TEMPLATE_APP_ID/$app_id/g" .eventlog/local-$app_id
	
	# Preserve the order to avoid SHS issues
	aws s3 cp .eventlog/local-$app_id s3://${s3_location}/local-$app_id >> out.log
	total_produced=$(( $total_produced + 1 ))
	
	info="$(date '+%d/%m/%Y %H:%M:%S'),$total_produced"
	echo $info
	rm -rf .eventlog/local-$app_id
done

#!/bin/bash

# SHS location(e.g. "http://192.168.31.189:18080")
shs_location=$1
if [ -z ${shs_location} ]; then
	echo "Usage: ./monitor.sh <shs-location>"
	exit 1
fi
echo "epoch_sec,loaded_apps" > report.csv
while true; do
	loaded_apps=$(curl -s ${shs_location}/api/v1/applications | grep '"id" :' | wc -l)
	echo "[$(date '+%d/%m/%Y %H:%M:%S')] Loaded: $loaded_apps"

	# epoch_seconds,loaded_apps
	echo "$(date +%s),${loaded_apps}" >> report.csv
	sleep 60
done

#!/bin/bash

function create_zigbee2mqtt_config {
	echo "Zigbee2Mqtt configuration is missing. creating it"
	cat > data/zigbee/configuration.yaml <<EOF
homeassistant: false
permit_join: true
mqtt:
  base_topic: zigbee2mqtt
  server: 'mqtt://mqtt'
serial:
  port: /dev/ttyACM0
EOF
}

function build_data_structure {
	echo "data folder is missing. creating it"
	mkdir -p data/mqtt/config
	mkdir -p data/zigbee/
	mkdir -p data/nodered/

	touch data/mqtt/config/mosquitto.conf

	if [ ! -f data/zigbee/configuration.yaml ]; then
		create_zigbee2mqtt_config
	fi

	chown 1883:1883 data/mqtt
	chown -R 1883:1883 data/mqtt/*
	chown 1000:1000 data/nodered
	chown -Rf 1000:1000 data/nodered/*
}

function detect_arch {
	uname_arch=$(uname -m)
	if [[ $uname_arch == *"amd64"* ]]; then
		echo "amd64"
	elif [[ $uname_arch == *"arm"* ]]; then
		echo "arm"
	else
		echo "unknown"
	fi
}

function check_dependencies {
	if ! [ -x "$(command -v docker-compose)" ]; then
		echo 'Error: docker-compose is not installed.' >&2
		exit 1
	fi
	
	if ! [ -x "$(command -v git)" ]; then
		echo 'Error: git is not installed.' >&2
		exit 1
	fi
}


function start {

	if [ ! -f data ]; then
		build_data_structure    
	fi

	echo "Starting all containers"
	architecture=$(detect_arch)

	echo "CPU architecture is: "$architecture
	echo "Using corresponding compose files"
	if [ $architecture == "arm" ]; then
		docker-compose -f docker-compose.yml -f docker-compose.arm.yml up -d
	elif [ $architecture == "amd64" ]; then
		docker-compose up -d
	else
	       echo 'Error: Only amd64 and arm are supported'
	       exit 1
	fi
}

function stop {
	echo "Stopping all containers"
	docker-compose stop
}

function update {
	echo "Shutting down all running containers and removing them."
	docker-compose down
	echo "Pulling current version via git."
	git pull
	if [ ! $? -eq 0 ]; then
	    echo "Updating failed. Please check the repository on GitHub."
	fi	    
	start
}

check_dependencies

case "$1" in
	"start")
		start
	;;
	"stop")
		stop
	;;
	"update")
		update
	;;
	"data")
		build_data_structure
	;;
	* )
		echo "c't-Smart-Home – setup script"
		echo "============================="
		echo "Usage:"
		echo "setup.sh update – to update to this copy of the repo"
		echo "setup.sh start – run all containers"
		echo "setup.sh stop – stop all containers"
		echo "setup.sh data – set up the data folder needed for the containers, but run none of them. Useful for personalized setups."
	;;
esac

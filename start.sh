#!/bin/bash

function detect_zigbee_device {
	if usb_dev=$(lsusb -d 0451:); then
		usb_dev_count=$(ls -1 /dev/ttyACM* 2>/dev/null | wc -l)
		if [ "$usb_dev_count" -gt 1 ]; then
			>&2 echo "There are multiple devices connected, that could be Zigbee USB adaptors. Please check data/zigbee/configuration.yml, if the device is wrong. /dev/ttyACM0 is used as the default."

			echo "/dev/ttyACM0"
		fi

		if [ -c /dev/ttyACM0 ]; then
			echo "/dev/ttyACM0"
		else
			>&2 echo "I could not find /dev/ttyACM0. Please check your hardware."
		fi
	else
		>&2 echo No Texas Instruments USB device found.

		echo "False"
	fi
}

function create_zigbee2mqtt_config {
	cat > data/zigbee/configuration.yaml <<EOF
# Home Assistant integration (MQTT discovery)
homeassistant: true 

# allow new devices to join
permit_join: true

# enable frontend
frontend:
  port: 8080
experimental:
  new_api: true

# MQTT settings
mqtt:
  # MQTT base topic for zigbee2mqtt MQTT messages
  base_topic: zigbee2mqtt
  # MQTT server URL
  server: 'mqtt://mqtt'
  # MQTT server authentication, uncomment if required:
  # user: my_user
  # password: my_password

advanced:
  channel: 25
  network_key: GENERATE

EOF

echo "Disable permit_join in data/zigbee/configuration.yaml after you have paired all of your devices!"

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

	sudo chown 1883:1883 data/mqtt
	sudo chown -R 1883:1883 data/mqtt/*
	sudo chown 1000:1000 data/nodered
	sudo chown -Rf 1000:1000 data/nodered/*
	sudo chown 0:0 data/mqtt
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

	device=$(detect_zigbee_device)
	if [ $device == "False" ]; then
		echo "No Zigbee adaptor found. Not starting Zigbee2MQTT."
		container="nodered mqtt"
	fi

	if [ ! -d data ]; then
		build_data_structure    
	fi

	echo "Starting the containers"
	docker-compose up -d $container
}

function stop {
	echo "Stopping all containers"
	docker-compose stop
}

function update {
	echo "Shutting down all running containers and removing them."
	docker-compose down
	if [ ! $? -eq 0 ]; then
		echo "Updating failed. Please check the repository on GitHub."
	fi	    
	echo "Pulling latest release via git."
	git fetch --tags
	latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
	git checkout $latestTag
	if [ ! $? -eq 0 ]; then
		echo "Updating failed. Please check the repository on GitHub."
	fi	    
	echo "Pulling docker images."
	docker-compose pull
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
		echo "start.sh update – to update this copy of the repo"
		echo "start.sh start – run all containers"
		echo "start.sh stop – stop all containers"
		echo "start.sh data – set up the data folder needed for the containers, but run none of them. Useful for personalized setups."
		;;
esac

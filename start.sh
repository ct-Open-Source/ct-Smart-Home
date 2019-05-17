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
	key=$(dd if=/dev/urandom bs=1 count=16 2>/dev/null | od -A n -t x1 | awk '{printf "["} {for(i = 1; i< NF; i++) {printf "0x%s, ", $i}} {printf "0x%s]\n", $NF}')
	echo "Zigbee2Mqtt configuration is missing. creating it."
	echo
	echo
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "This is your random Zigbee encryption key:" 
	echo
	echo $key
	echo
	echo "Store it safely or you will have to repair all of your devices."
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo
	echo
	cat > data/zigbee/configuration.yaml <<EOF
# Home Assistant integration (MQTT discovery)
homeassistant: false

# allow new devices to join
permit_join: true

# MQTT settings
mqtt:
  # MQTT base topic for zigbee2mqtt MQTT messages
  base_topic: zigbee2mqtt
  # MQTT server URL
  server: 'mqtt://mqtt'
  # MQTT server authentication, uncomment if required:
  # user: my_user
  # password: my_password

# Serial settings
serial:
  # Location of CC2531 USB sniffer
  port: /dev/ttyACM0
  disable_led: false

advanced:
  channel: 25
  network_key: $key

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
	sudo chown 1001:1001 data/nodered
	sudo chown -Rf 1001:1001 data/nodered/*
}

function detect_arch {
	uname_arch=$(uname -m)
	if [[ $uname_arch == *"x86_64"* ]]; then
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

	device=$(detect_zigbee_device)
	if [ $device == "False" ]; then
		echo "No Zigbee adaptor found. Not starting Zigbee2MQTT."
		container="nodered"
	fi

	if [ ! -d data ]; then
		build_data_structure    
	fi
	echo $container
	echo	
	echo "Starting the containers"
	architecture=$(detect_arch)	
	echo "CPU architecture is: "$architecture
	if [ $architecture == "unknown" ]; then
		echo 'Error: Only amd64 and arm are supported'
		exit 1
	fi
	docker-compose up -d $container
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
	echo "Pulling current images."
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
		echo "setup.sh update – to update to this copy of the repo"
		echo "setup.sh start – run all containers"
		echo "setup.sh stop – stop all containers"
		echo "setup.sh data – set up the data folder needed for the containers, but run none of them. Useful for personalized setups."
		;;
esac

#!/bin/bash

function detect_zigbee_device {
	usb_dev_count=0
	usb_dev_found="FALSE"
	for device in /dev/ttyUSB* /dev/ttyACM* 
	do 
		if [ ! -c $device ]; then
			continue
		fi
		
		VENDOR_PRODUCT=$(udevadm info --name=$device | egrep -i "ID_VENDOR_ID|ID_MODEL_ID" | cut -d'=' -f2 | tr '\n' ':') 
		# Texas Instruments USB device - Vendor: 0451
		# slaesh’s CC2652RB stick - Vendor: 10c4
		if [ "$(echo ${VENDOR_PRODUCT} | egrep '^0451:|^10c4:')" != "" ]
		then	
			((usb_dev_count=usb_dev_count+1))
			usb_dev_found="$device"
		 	>&2 echo "📄 Found Device #$usb_dev_count $device (vendor:product=${VENDOR_PRODUCT}) that could be Zigbee USB adaptor"  
		fi
	done

	if [ "$usb_dev_count" -gt 1 ]; then
		>&2 echo "⚠️  There are multiple devices connected, that could be Zigbee USB adaptors. Please check data/zigbee/configuration.yml, if the device is wrong. $usb_dev_found is used as the default."
	fi

	if [ "$usb_dev_count" -eq 0 ]; then
		>&2 echo "⚠️  No Texas Instruments USB device nor slaesh’s CC2652RB stick found for zigbee2mqtt"
	fi
	echo "$usb_dev_found"
}

function create_mosquitto_config {
	cat > data/mqtt/config/mosquitto.conf <<EOF

log_type all

listener 1883
listener 9001 
protocol websockets

# Uncomment the following lines and create a passwd file using mosquitto_passwd to enable authentication.
#password_file /mosquitto/config/passwd
# Set this to false, to enable authentication
allow_anonymous true
EOF

touch data/mqtt/config/passwd

}

function create_zigbee2mqtt_config {
	# zigbee2mqtt device
	device="$1"
	
	cat > data/zigbee/configuration.yaml <<EOF
# Home Assistant integration (MQTT discovery)
homeassistant: true 

# allow new devices to join
permit_join: true

serial:
  port: $device

# enable frontend
frontend:
  port: 1881 
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

echo '⚠️  Disable permit_join in data/zigbee/configuration.yaml or the Zigbee2MQTT webinterface on port 1881, after you have paired all of your devices!'

}

function create_compose_env {
	# zigbee2mqtt device
	device="$1"
	
	cat > .env <<EOF
# Container-Tag listed in README.md (e.g.: latest-14, devel, devel-14, ...)
# Default = latest
CONTAINER_TAG=latest

#
# MQTT Ports for mosquitto
# Default:
#  - 1883 insecure
#  - 9001 websocket
#  - 8883 secure (must be configured)
MQTT_PORT=1883
MQTT_WEBSOCKET_PORT=9001
MQTT_SECURE_PORT=8883

# Port for access to zigbee2mqtt Frontend
ZIGBEE_FRONTEND_PORT=1881

EOF
	if [ "$device" != "FALSE" ] ; then
		cat >> .env <<EOF
# Device mounted into zigbee2mqtt container
ZIGBEE_DEVICE=$device
EOF
	else
		cat >> .env <<EOF
# Device mounted into zigbee2mqtt container
# ZIGBEE_DEVICE=$device
# Uncomment line ZIGBEE_DEVICE and replace $device with device path like /dev/ttyXXX
# also edit data/zigbee/configuration.yaml to set the same device!
EOF

	fi
	echo '⚠️  Check .env for correct versions, ports and zigbee2mqtt-device'
}



function fix_permissions {
	echo '📄 Setting the permissions of the configurations in the data folder.'
	sudo chown 1883:1883 data/mqtt
	sudo chown -Rf 1883:1883 data/mqtt/*
	sudo chown 1000:1000 data/nodered
	sudo chown -Rf 1000:1000 data/nodered/*
}


function build_data_structure {
	mkdir -p data/mqtt/config
	mkdir -p data/zigbee/
	mkdir -p data/nodered/

	# zigbee2mqtt device
	device="$1"

	if [ ! -f data/mqtt/config/mosquitto.conf ]; then
		echo '📄 Configuration file data/mqtt/config/mosquitto.conf is missing. Creating it from scratch.'
		create_mosquitto_config
	fi

	if [[ ! -f data/zigbee/configuration.yaml && "$device" != "FALSE" ]]; then
		echo '📄 Configuration file data/zigbee/configuration.yaml is missing. Creating it from scratch.'
		create_zigbee2mqtt_config "$device"
	fi
	
	if [ ! -f .env ]; then
		echo '📄 Configuration file .env is missing. Creating it from scratch.'
		create_compose_env "$device"
	fi

	fix_permissions
}

function check_dependencies {
	if ! [ -x "$(command -v docker-compose)" ]; then
		echo '⚠️  Error: docker-compose is not installed.' >&2
		exit 1
	fi

	if ! [ -x "$(command -v git)" ]; then
		echo '⚠️  Error: git is not installed.' >&2
		exit 1
	fi

        if ! [ -x "$(command -v udevadm)" ]; then
                echo '⚠️  Error: udevadm is not installed.' >&2
                exit 1
        fi


}

function start {

	device=$(detect_zigbee_device)
	if [ $device == "False" ]; then
		echo '⚠️  No Zigbee adaptor found. Not starting Zigbee2MQTT.'
		container="nodered mqtt"
	fi

	# Build data structure with default file if not existing
	build_data_structure "$device"
	
	echo '🏃 Starting the containers'
	docker-compose up -d $container
	echo '⚠️  After you made yourself familiar with the setup, it'"'"'s strongly suggested to secure the services. Read the "Security" section in the README!'
}

function stop {
	echo '🛑 Stopping all containers'
	docker-compose stop
}

function update {

	if [[ ! -d ".git" ]]
	then
		echo "🛑You have manually downloaded the release version of c't-Smart-Home.
The automatic update only works with a cloned Git repository.
Try backing up your settings shutting down all containers with 

docker-compose down --remove orphans

Then copy the current version from GitHub to this folder and run

./start.sh start.

Alternatively create a Git clone of the repository."
		exit 1
	fi
	echo '☠️  Shutting down all running containers and removing them.'
	docker-compose down --remove-orphans
	if [ ! $? -eq 0 ]; then
		echo '⚠️  Updating failed. Please check the repository on GitHub.'
	fi	    
	echo '⬇️  Pulling latest release via git.'
	git fetch --tags
	latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
	git checkout $latestTag
	if [ ! $? -eq 0 ]; then
		echo '⚠️  Updating failed. Please check the repository on GitHub.'
	fi	    
	echo '⬇️  Pulling docker images.'
	docker-compose pull
	if [ ! $? -eq 0 ]; then
		echo '⚠️  Updating failed. Please check the repository on GitHub.'
	fi	    
	start
	fix_permissions
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
	"fix")
		fix_permissions	
		;;
	"data")
		device=$(detect_zigbee_device)
		build_data_structure "$device"
		;;
	* )
		cat << EOF
🏡 c't-Smart-Home – setup script
—————————————————————————————
Usage:
start.sh update – update to the latest release version
start.sh fix – correct the permissions in the data folder 
start.sh start – run all containers
start.sh stop – stop all containers
start.sh data – set up the data folder needed for the containers, but run none of them. Useful for personalized setups.

Check https://github.com/ct-Open-Source/ct-Smart-Home/ for updates.
EOF
		;;
esac

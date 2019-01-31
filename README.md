# c't-Smart-Home
Docker-environment for Node-Red with MQTT, Zigbee2MQTT, HomeKit and Bluetooth-LE-Support

![](https://img.shields.io/docker/pulls/ctmagazin/ctnodered.svg)
![](https://img.shields.io/docker/stars/ctmagazin/ctnodered.svg)

## Containers
Uses mqtt, node-red and zigbee2mqtt

## Getting started
* Install docker and docker-compose
* Clone/Download this repository
* `cd` into the folder containing this repos data
* run `./start.sh start` to setup the data folder needed for the containers and run them.

## Manual start
* run `./start.sh data` to create the necessary folders
* On a AMD64-System use `docker-compose -f up -d`
* On a Raspberry Pi/ARM-based systems use `docker-compose -f docker-compose.yml -f docker-compose.raspi.yml up -d`
* If you do not want to start zigbee2mqtt, add the name of the nodered-container: `docker-compose -f docker-compose.yml -f docker-compose.raspi.yml up -d nodered`

## start.sh options
```
c't-Smart-Home – setup script                                                                                                                             
=============================
Usage:
setup.sh update – to update to this copy of the repo
setup.sh start – run all containers
setup.sh stop – stop all containers
setup.sh data – set up the data folder needed for the containers, but run none of them. Useful for personalized setups.   
```

# Further information
This project is described in the German computer magazine c't: [https:/ct.de/smarthome](https:/ct.de/smarthome)

zigbee2mqtt is described here: [https://ct.de/ygdp](https://ct.de/ygdp)

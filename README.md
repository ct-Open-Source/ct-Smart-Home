# c't-Smart-Home
Docker-environment for Node-Red with MQTT, Zigbee2MQTT, HomeKit and Bluetooth-LE-Support

![](https://img.shields.io/github/release/ct-Open-Source/ct-Smart-Home.svg)
![](https://img.shields.io/github/license/ct-Open-Source/ct-Smart-Home.svg)
![](https://img.shields.io/docker/pulls/ctmagazin/ctnodered.svg)
![](https://img.shields.io/docker/stars/ctmagazin/ctnodered.svg)
![](https://img.shields.io/docker/cloud/automated/ctmagazin/ctnodered.svg)
![](https://img.shields.io/docker/cloud/build/ctmagazin/ctnodered.svg)

## Requirements

To get this going you need a working [Docker 18.02.0+ setup](https://docs.docker.com/install/) on an AMD64 or ARM32v7 machine. This includes virtually any PC or a Raspberry Pi 3 or newer. Other ARM boards and some NAS might work too, but have not been tested.

You'll also need [docker-compose](https://docs.docker.com/compose/install/) on your machine.

If you want to controll Zigbee devices you also will need a Zigbee-Stick. Have a look at [Zigbee2MQTT's documentation](https://www.zigbee2mqtt.io/getting_started/what_do_i_need.html) for that.

## Containers
Uses [Eclipse Mosquitto](https://hub.docker.com/_/eclipse-mosquitto), a custom built Node-Red container and [zigbee2mqtt](https://github.com/Koenkk/zigbee2mqtt.io)

## Getting started
* Install docker and docker-compose
* Clone/Download this repository
* `cd` into the folder containing this repos data
* run `./start.sh start` to setup the data folder needed for the containers and run them.

## Manual start
* run `./start.sh data` to create the necessary folders
* Use `docker-compose up -d` to start the containers
* If you do not want to start zigbee2mqtt, add the name of the nodered-container: `docker-compose up -d nodered`. The mqtt container will always be started, because it's a dependency of Node-Red.

## start.sh options
```
c't-Smart-Home – setup script                                                                                                                             
=============================
Usage:
start.sh update – to update to this copy of the repo
start.sh start – run all containers
start.sh stop – stop all containers
start.sh data – set up the data folder needed for the containers, but run none of them. Useful for personalized setups.   
```

# Further information
This project is described in the German computer magazine c't: [https://ct.de/smarthome](https://ct.de/smarthome)

zigbee2mqtt is described here: [https://ct.de/ygdp](https://ct.de/ygdp)

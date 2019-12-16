# c't-Smart-Home

A ready-to-use Node-RED setup for home automation maintained by [german computer magazine c't](https://www.ct.de/smarthome).

It includes Node-RED, MQTT (provided by [Eclipse Mosquitto](https://mosquitto.org/)), Zigbee-Support (provided by [zigbee2mqtt](https://www.zigbee2mqtt.io/)). We also added Node-RED-Nodes for [HomeKit](https://github.com/NRCHKB/node-red-contrib-homekit-bridged),  [FritzBox](https://github.com/bashgroup/node-red-contrib-fritz), [Tado](https://github.com/mattdavis90/node-red-contrib-tado-client), [Bluetooth-LE-Support](https://github.com/kmi/node-red-contrib-noble) and a [Dashboard](https://github.com/node-red/node-red-dashboard).

![](https://img.shields.io/github/stars/ct-Open-Source/ct-Smart-Home.svg)
![](https://img.shields.io/github/release/ct-Open-Source/ct-Smart-Home.svg)
![](https://img.shields.io/github/license/ct-Open-Source/ct-Smart-Home.svg)
![](https://img.shields.io/badge/GitHub-Actions-blueviolet)
![](https://img.shields.io/docker/pulls/ctmagazin/ctnodered.svg)
![](https://img.shields.io/docker/stars/ctmagazin/ctnodered.svg)

## Requirements

To get this going you need a working [Docker 18.02.0+ setup](https://docs.docker.com/install/) and [docker-compose](https://docs.docker.com/compose/install/). 

This setup will run on any  AMD64 or ARM32v7 machine. This includes virtually any PC or a Raspberry Pi 3 or newer. We also build containers for ARM64v8, ARM32v6 and S390X but they are untested.

If you want to control Zigbee devices you also will need a Zigbee controller stick. Have a look at [Zigbee2MQTT's documentation](https://www.zigbee2mqtt.io/getting_started/what_do_i_need.html) for that.

## Getting started
* Install docker and docker-compose: [german article on installation process](https://www.heise.de/ct/artikel/Docker-einrichten-unter-Linux-Windows-macOS-4309355.html?hg=1&hgi=3&hgf=false)
* Clone/Download this repository
* `cd` into the folder containing this repos files
* run `./start.sh start` to setup the data folder needed for the containers and run them.
* Note: The Zigbee2mqtt container will only start if a Zigbee-Controller is connected. Make sure to [use the newest firmware](https://www.zigbee2mqtt.io/getting_started/flashing_the_cc2531.html) on the stick!
* Backup the `data` folder regularly it contains all your data and configuration files

### `start.sh` options
```
c't-Smart-Home – setup script                                                                                                                             
=============================
Usage:
start.sh update – to update this copy of the repo
start.sh start – run all containers
start.sh stop – stop all containers
start.sh data – set up the data folder needed for the containers, but run none of them. Useful for personalized setups.
```

### Manual start

* run `./start.sh data` to create the necessary folders
* Use `docker-compose up -d` to start the containers
* If you do not want to start Zigbee2mqtt, add the name of the Node-RED-container to the docker-compose command: `docker-compose up -d nodered`. The MQTT container will always be started, because it's a dependency of Node-Red.

## Containers and Versions

The Node-RED container is based on [the official one](https://hub.docker.com/r/nodered/node-red) provided by the Node-RED project. We provide variations based on Node.js versions 8 (legacy), 10 (LTS) and 12. See Node.js [releases page](https://nodejs.org/en/about/releases/) for support cycles. The container based on LTS will always be the default. You can always modify your copy of the compose file to use a different container version.

| Container-Tag         | Node-RED version       | Node.js version | Notes                     | Arch    |
| --------------------- | ---------------------- | --------------- | ------------------------- | ------- |
| latest                | latest release version | LTS             | latest release version    | all     |
| latest-10             | 1.x                    | 10              | latest release version    | all     |
| latest-12             | 1.x                    | 12              | latest release version    | all     |
| devel                 | latest release version | 10              | build from current master | all     |
| devel-10              | 1.x                    | 10              | build from current master | all     |
| devel-12              | 1.x                    | 12              | build from current master | all     |
| release-1.1.1-amd64   | 0.20.5                 | 8               | legacy                    | amd64   |
| release-1.1.1-arm32v7 | 0.20.5                 | 8               | legacy                    | arm32v7 |

We also use the `:latest` versions of [Eclipse Mosquitto](https://hub.docker.com/_/eclipse-mosquitto) and [Zigbee2mqtt](https://github.com/Koenkk/zigbee2mqtt.io).

## Further information

### Articles in c't

This project is described in the German computer magazine c't: [https://ct.de/smarthome](https://ct.de/smarthome)

Zigbee2mqtt is described here: [https://ct.de/ygdp](https://ct.de/ygdp)

### Documentation

[Node-RED documentation](https://nodered.org/docs/) 

[Zigbee2MQTT documentation](https://www.zigbee2mqtt.io/) (Note: If you use and enjoy the Zigbee service consider sponsoring Koen Kanters great work!)

[Mosquitto documentation](https://mosquitto.org/man/mosquitto-8.html)


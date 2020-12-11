# c't-Smart-Home

A ready-to-use Node-RED setup for home automation maintained by [german computer magazine c't](https://www.ct.de/smarthome).

It includes [Node-RED](https://nodered.org/), MQTT (provided by [Eclipse Mosquitto](https://mosquitto.org/)), Zigbee-Support (provided by [zigbee2mqtt](https://www.zigbee2mqtt.io/)).

We also added Node-RED-Nodes for [HomeKit](https://github.com/NRCHKB/node-red-contrib-homekit-bridged),  [FritzBox](https://github.com/bashgroup/node-red-contrib-fritz), [Tado](https://github.com/mattdavis90/node-red-contrib-tado-client), [Bluetooth-LE-Support](https://github.com/clausbroch/node-red-contrib-noble-bluetooth), [Zigbee2Mqtt-Support](https://flows.nodered.org/node/node-red-contrib-zigbee2mqtt) and a [Dashboard](https://github.com/node-red/node-red-dashboard).

![-](https://img.shields.io/github/stars/ct-Open-Source/ct-Smart-Home.svg)
![-](https://img.shields.io/github/release/ct-Open-Source/ct-Smart-Home.svg)
![-](https://img.shields.io/docker/pulls/ctmagazin/ctnodered.svg)
![-](https://img.shields.io/docker/stars/ctmagazin/ctnodered.svg)
![-](https://img.shields.io/github/license/ct-Open-Source/ct-Smart-Home.svg)
![-](https://img.shields.io/badge/GitHub-Actions-blueviolet)
![-](https://github.com/ct-Open-Source/ct-Smart-Home/workflows/release/badge.svg)

## Requirements

To get this going you need a working [Docker 18.02.0+ setup](https://docs.docker.com/install/) and [docker-compose](https://docs.docker.com/compose/install/).

This setup will run on any  AMD64 or ARM32v7 Linux machine. This includes virtually any PC or a Raspberry Pi 3 or newer. We also build containers for ARM64v8, ARM32v6 but they are untested. If you want to run the containers on macOS, try running `start.sh` as root.

If you want to control Zigbee devices you also will need a Zigbee controller stick. Have a look at [Zigbee2MQTT's documentation](https://www.zigbee2mqtt.io/getting_started/what_do_i_need.html) for that.

## Getting started

* Install docker and docker-compose: [german article on installation process](https://www.heise.de/ct/artikel/Docker-einrichten-unter-Linux-Windows-macOS-4309355.html?hg=1&hgi=3&hgf=false)
* Clone/Download this repository
* `cd` into the folder containing this repos files
* Run `./start.sh start` to setup the data folder needed to run the containers and start them up.  
*Note: The Zigbee2mqtt container will only start if a [Zigbee-Controller](https://www.zigbee2mqtt.io/information/supported_adapters.html) is connected. Make sure to update the adapter to the newest firmware!*  
**Backup the `data` folder regularly, as it contains all your data and configuration files**

### Updating

An update via `start.sh update` will pull the latest release of this repository. This will work for most use cases.

If you made changes to files provided in the repository, you'll have to undo those changes and reapply them. If you're familiar with `git` use `git stash` and `git stash apply`. If you want a specially customized version of this repo, think about forking it.

### Configuration

To change configuration of the provided services, either use the corresponding web interfaces or have a look in the `./data` folder. There you'll find all the necessary configurations to modify your setup.

### How to access the services

After starting the containers you'll reach Node-RED [http://docker-host:1880](http://docker-host:1880) and the Zigbee administrative interface at [http://docker-host:1881](http://docker-host:1881). Mosquitto is available on Port 1883 (and 9001 for websockets). You can see more details of the processes output in the container logs with the command `docker-compose logs`.

## Security

None of the services are protected by authorization mechanisms by default. This is not optimal, but a compromise to make it easier for beginners. To secure Node-RRD have a look at their [documentation about "Securing Node-RED"](https://nodered.org/docs/user-guide/runtime/securing-node-red). It will show you how to enable a mandatory login.

Zigbee2Mqtts web frontend also provides an authentication mechanism. It's described in their [documentation of the frontend](https://www.zigbee2mqtt.io/information/frontend.htm).

Mosquitto won't demand a authentication either, but you can enable it in the config file. Just enable the last two lines and run the following command. Be sure to replace `USERNAME` with your preferred name.

`docker run -it -v ${PWD}/data/mqtt/config/passwd:/passwd eclipse-mosquitto mosquitto_passwd /passwd USERNAME`

Now restart mosquitto with `docker-compose restart mqtt`. Your mosquitto server should require authentication via the username/password combination you provided. Don't forget to modify the Zigbee2MQTT configuration and the Node-RED setup. To add more mosquitto users just run the command again.

## `start.sh` options

```plaintext
🏡 c't-Smart-Home – setup script
—————————————————————————————
Usage:
start.sh update – to update this copy of the repo
start.sh start – run all containers
start.sh stop – stop all containers
start.sh data – set up the data folder needed for the containers, but run none of them. Useful for personalized setups.

Check https://github.com/ct-Open-Source/ct-Smart-Home/ for updates.
```

## Manual start

* run `./start.sh data` to create the necessary folders
* Use `docker-compose up -d` to start the containers
* If you do not want to start Zigbee2mqtt, add the name of the Node-RED container to the docker-compose command: `docker-compose up -d nodered`. The MQTT container will always be started, because it's a dependency of Node-RED.

## Containers and Versions

The Node-RED container is based on [the official one](https://hub.docker.com/r/nodered/node-red) provided by the Node-RED project. We provide variations based on Node.js versions 8 (legacy), 10 (LTS) and 12. See Node.js [releases page](https://nodejs.org/en/about/releases/) for support cycles. The container based on LTS will always be the default. You can always modify your copy of the compose file to use a different container version.

| Container-Tag | Node-RED version | Node.js version | Notes | Arch |
| - | - | - | - | - |
| **Release versions**
| **latest** | **latest release version** | **12** | latest release version | all |
| latest-10 | 1.x | 10 | latest release version | all |
| latest-12 | 1.x | 12 | latest release version | all |
| latest-14 | 1.x | 14 | latest release version | all |
| **Development versions** |
| **devel** | **latest devel version** | **14** | **build from current devel** | all |
| devel-10 | 1.x | 10 | build from current devel  | all |
| devel-12 | 1.x | 12 | build from current devel  | all |
| devel-14 | 1.x | 14 | build from current devel  | all |
| **Deprecated relases** |
| release-1.1.1-amd64 | 0.20.5 | 8 | deprecated | amd64 |
| release-1.1.1-arm32v7 | 0.20.5 | 8 | deprecated | arm32v7 |

We also use the `:latest` versions of [Eclipse Mosquitto](https://hub.docker.com/_/eclipse-mosquitto) and [Zigbee2mqtt](https://github.com/Koenkk/zigbee2mqtt.io).

## Further information

### Articles in c't

This project is described in the German computer magazine c't: [https://ct.de/smarthome](https://ct.de/smarthome)

Zigbee2mqtt is described here: [https://ct.de/ygdp](https://ct.de/ygdp)

### Documentation

[Node-RED documentation](https://nodered.org/docs/)

[Zigbee2MQTT documentation](https://www.zigbee2mqtt.io/)  
(Note: If you use and enjoy the Zigbee service, consider [sponsoring Koen Kanters](https://www.paypal.com/paypalme/koenkk) great work!)

[Mosquitto documentation](https://mosquitto.org/man/mosquitto-8.html)

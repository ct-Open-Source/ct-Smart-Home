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

## Requirements

To get this going you need a working [Docker 18.02.0+ setup](https://docs.docker.com/install/) and [docker-compose](https://docs.docker.com/compose/install/).

This setup will run on any  AMD64 or ARM32v7 Linux machine. This includes virtually any PC or a Raspberry Pi 3 or newer. We also build containers for ARM64v8, ARM32v6 but they are untested. If you want to run the containers on macOS, try running `start.sh` as root.

If you want to control Zigbee devices you also will need a Zigbee controller stick. Have a look at [Zigbee2MQTT's documentation](https://www.zigbee2mqtt.io/getting_started/what_do_i_need.html) for that.

## Getting started

* Install docker and docker-compose: [german article on installation process](https://www.heise.de/ct/artikel/Docker-einrichten-unter-Linux-Windows-macOS-4309355.html?hg=1&hgi=3&hgf=false)

* Clone this repository  
*Note: It's also possible to download the latest release from the release tab, but it's not recommended, because then the update mechanism won't work.*

* `cd` into the folder containing this repos files

* Run `./start.sh start` to setup the data folder needed to run the containers and start them up.  
*Note: The Zigbee2mqtt container will only start if a [Zigbee-Controller](https://www.zigbee2mqtt.io/information/supported_adapters.html) is connected. Make sure to update the adapter to the newest firmware!*  
**Backup the `./data` folder regularly, as it contains all your data and configuration files**

* When you've got "the hang of it" follow the steps listed in the *Security* section to get a properly secured setup.

### Updating

You should make a backup of all files in the `./data` folder. If you made changes to files outside of `./data` it is imperative to backup those too.

An update via `start.sh update` will pull the latest release of this repository. This will work for most use cases.

If you made changes to files provided in the repository, you'll have to undo those changes and reapply them. If you're familiar with `git` use `git stash` and `git stash apply`. If you want a specially customized version of this repo, think about forking it.

If you manually downloaded the files from the release tab, you'll have to do the update manually. This takes three steps:

* Backup your installation

* Run `docker-compose down --remove-orphans`

* Download the new release and overwrite the files in your installation. Or even better: switch to a cloned repository.

* Run `./start.sh start` to start c't-Smart-Home

### Configuration

To change configuration of the provided services, either use the corresponding web interfaces or have a look in the `./data` folder. There you'll find all the necessary configurations to modify your setup.

### How to access the services

After starting the containers you'll reach Node-RED [http://docker-host:1880](http://docker-host:1880) and the Zigbee administrative interface at [http://docker-host:1881](http://docker-host:1881). Mosquitto is available on Port 1883 (and 9001 for websockets). You can see more details of the processes output in the container logs with the command `docker-compose logs`.

## Security

**Never** make c't-Smart-Home available from outside of your network without following these following steps. In any case you should limit the access by enabling password protection!

None of the services are protected by authorization mechanisms by default. This is not optimal, but a compromise to make it easier for beginners. To secure Node-RED have a look at their [documentation about "Securing Node-RED"](https://nodered.org/docs/user-guide/runtime/securing-node-red). It will show you how to enable a mandatory login.

Zigbee2Mqtts web frontend also provides an authentication mechanism. It's described in their [documentation of the frontend](https://www.zigbee2mqtt.io/information/frontend.htm).

Mosquitto won't demand a authentication either, but you can enable it in the config file. Just enable the last two lines and run the following command. Be sure to replace `USERNAME` with your preferred name.

`docker run -it -v ${PWD}/data/mqtt/config/passwd:/passwd eclipse-mosquitto mosquitto_passwd /passwd USERNAME`

Now restart mosquitto with `docker-compose restart mqtt`. Your mosquitto server should require authentication via the username/password combination you provided. Don't forget to modify the Zigbee2MQTT configuration and the Node-RED setup. To add more mosquitto users just run the command again.

Additionally you should run c't-Smart-Home behind a reverse proxy like [Traefik](https://traefik.io/) to ensure all connections are encrypted. Traefik is able to secure not only HTTP, but also generic TCP and UDP connections.

## `start.sh` options

```plaintext
🏡 c't-Smart-Home – setup script
—————————————————————————————
Usage:
start.sh update – to update this copy of the repo
start.sh fix – correct the permissions in the data folder 
start.sh start – run all containers
start.sh stop – stop all containers
start.sh data – set up the data folder needed for the containers, but run none of them. Useful for personalized setups.

Check https://github.com/ct-Open-Source/ct-Smart-Home/ for updates.
```

## Manual start

* run `./start.sh data` to create the necessary folders
* Use `docker-compose up -d` to start the containers
* If you do not want to start Zigbee2mqtt, add the name of the Node-RED container to the docker-compose command: `docker-compose up -d nodered`. The MQTT container will always be started, because it's a dependency of Node-RED.

## Troubleshooting

### I've made an update to the system, but now I get errors about "orphaned containers". How do I fix this?

This happens when there are containers running that haven't been defined in the `docker-compose.yml`. The cause for this might be a failed deployment or that a container was added to or removed from the c't-Smart-Home setup. You can fix this by running `docker-compose down --remove-orphans`, followed by `./start.sh start`.

### After the latest update Mosquitto won't accept connections. What is happening?

From version 2.x onward Mosquitto explicitly requires a option to enable anonymous logins. While it is highly recommended to require authentication for Mosquitto, it's okay for a beginner setup and for testing to have no authentication. To reactivate anonymous logins open the file `./data/mqtt/conf/mosquitto.conf` and add the line `allow_anonymous true`. Then run `docker-compose restart mqtt`.

### I can't see any devices in the Zigbee2Mqtt nodes provided by node-red-contrib-zigbee2mqtt. 

If you upgrade from an existing installation, you must add `homeassistant: true` to `./data/zigbee/configuration.yaml`.

### The Zigbee2Mqtt web-frontend doesn't work for me, but the service is running just fine. Did I miss something?

You probably did an update from an earlier version of c't-Smart-Home to a recent one. You must add a few lines to `./data/zigbee/configuration.yaml`. Have a look at their [documentation of the frontend](https://www.zigbee2mqtt.io/information/frontend.htm). Make sure to set the option `port` to `1881`.

### Why doesn't c't-Smart-Home provide a complete setup with HTTPS support for the services. What's the issue?

There is no technical issue. Using a reverse proxy like [Traefik](https://traefik.io/) works just fine. But this will add an additional level of complexity to the system, and might encourage inexperienced users to put the setup on the open internet for convenience. This is *absolutely not recommended*.

An experienced user is able to setup Traefik in a short amount of time and will be able to secure the services in a proper way.

### I'm trying to use the setup on my NAS, but I can't run the containers

Sadly most NAS vendors use modified versions of Docker that miss some features. You'll possibly have to run the containers manually oder change some options in the `docker-compose.yml`. We sadly can't provide support for NAS setups due to the varying featureset of their Docker support.

### Can I run c't-Smart-Home on a Mac?

You could try, but we don't support it on a Mac.

### I'm missing some nodes after an update. What happended?

We probably removed some unnecessary or outdated nodes. Check which are missing and look in the palette for them. Most likely you can reinstall them from there.

### Node-RED won't start after an update. The logs show permission errors. How do I fix this?

For security reasons the Node-RED service won't run as root anymore. It now runs with the GID and UID 1000. To fix this issue you must set the GID and UID of data/nodered and all of its content to 1000. You can use `start.sh fix` to correct those issues.

## Container images and Versions

The Node-RED container image is a variation on [the official one](https://hub.docker.com/r/nodered/node-red) provided by the Node-RED project. We provide versions based on Node.js versions 10 (Maintenance LTS), 12 (Maintenance LTS) and 14 (Active LTS). See Node.js [releases page](https://nodejs.org/en/about/releases/) for support cycles. The container image based on Active LTS will always be the default. You can freely modify your copy of the compose file to use a different container image or even create your own image.

The `:latest` image is rebuild upon new releases and updated weekly to include updates to Node-RED and the underlying libraries. The `:devel` images are being rebuilt every night.

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

The Docker images are hosted on the [Docker Hub](https://hub.docker.com/repository/docker/ctmagazin/ctnodered) and on [GitHubs Container Registry ghcr.io](https://github.com/orgs/ct-Open-Source/packages/container/package/ctnodered). The default is to use GitHubs Container Registry, since the rate limits and retention policies of the Docker Hub are possible causes for future issues.

## Further information

### Articles in c't

This project is described in the German computer magazine c't: [https://ct.de/smarthome](https://ct.de/smarthome)

Zigbee2mqtt is described here: [https://ct.de/ygdp](https://ct.de/ygdp)

### Documentation

[Node-RED documentation](https://nodered.org/docs/)

[Zigbee2MQTT documentation](https://www.zigbee2mqtt.io/)  
(Note: If you use and enjoy the Zigbee service, consider [sponsoring Koen Kanters](https://www.paypal.com/paypalme/koenkk) great work!)

[Mosquitto documentation](https://mosquitto.org/man/mosquitto-8.html)

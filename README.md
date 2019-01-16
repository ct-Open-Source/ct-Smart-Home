
# node-red-pack
Docker-environment for Node-Red with MQTT, Zigbee2MQTT, HomeKit and Bluetooth-LE-Support

## Containers

Uses mqtt, node-red and zigbee2mqtt

## Getting started
* Install docker and docker-compose
* clone this repository
* `cd` into folder node-red-pack
* on Desktop use `docker-compose -f up -d`
* on Raspberry Pi use `docker-compose -f docker-compose.yml -f docker-compose.raspi.yml up -d`
* if you do not want to start zigbee2mqtt (CC2531-USB-Device needed), add name of nodered-container: `docker-compose -f docker-compose.yml -f docker-compose.raspi.yml up -d nodered`

# Further information
This project is described in German magazine c't: [ct.de/smarthome](ct.de/smarthome)
Zigbee2Mqtt is described here: [ct.de/smarthome](ct.de/smarthome)

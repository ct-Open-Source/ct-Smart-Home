
# node-red-pack
Docker-environment for Node-Red with MQTT, Zigbee2MQTT, HomeKit and Bluetooth-LE-Support

## Containers
Uses mqtt, node-red and zigbee2mqtt

## Getting started
* Install docker and docker-compose
* Clone/Download this repository
* `cd` into the folder containing this repos data
* On a AMD64-System use `docker-compose -f up -d`
* On a Raspberry Pi use `docker-compose -f docker-compose.yml -f docker-compose.raspi.yml up -d`
* If you do not want to start zigbee2mqtt, add the name of the nodered-container: `docker-compose -f docker-compose.yml -f docker-compose.raspi.yml up -d nodered`

# Further information
This project is described in the German computer magazine c't: [ct.de/smarthome](ct.de/smarthome)

zigbee2mqtt is described here: [https://ct.de/ygdp](https://ct.de/ygdp)

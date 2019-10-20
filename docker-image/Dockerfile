FROM nodered/node-red:latest-minimal

COPY entrypoint.sh /usr/src/node-red/entrypoint.sh

WORKDIR /usr/src/node-red

USER root

RUN set -ex \
	&& apk add --no-cache \
	  avahi-compat-libdns_sd \
	  dbus \
	  libcap \
	  python \
	&& apk add --no-cache --virtual dev-packages \
	  make \	  
	  g++ \
	  avahi-dev \
	  eudev \
	  eudev-dev \
	  bluez-dev \
	  build-base \
	  linux-headers \
	  udev \
	&& setcap cap_net_raw+eip $(eval readlink -f `which node`) \
	&& chown messagebus:messagebus /var/run/dbus \
	&& chown avahi:avahi /var/run/avahi-daemon \
	&& sed -i "s/#enable-dbus=yes/enable-dbus=yes/g" /etc/avahi/avahi-daemon.conf \
	&& dbus-uuidgen --ensure \
	&& npm install node-red-contrib-fritz node-red-contrib-homekit-bridged node-red-contrib-tado-client node-red-dashboard node-red-node-base64 node-red-node-msgpack node-red-node-random node-red-node-suncalc @rdmtc/node-red-contrib-noble --unsafe-perm \
	&& apk del dev-packages \
	&& npm dedupe \
	&& npm cache clean --force 
RUN	sed -ie "s/'noble'/'@abandonware\/noble'/" node_modules/@rdmtc/node-red-contrib-noble/noble/node-red-contrib-noble.js

VOLUME /data

EXPOSE 1880

CMD ["/bin/sh", "/usr/src/node-red/entrypoint.sh" ]

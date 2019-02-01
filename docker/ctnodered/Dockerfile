FROM node:8-slim

RUN set -ex \
	&& mkdir -p /usr/src/node-red \
	&& mkdir /data \
	&& useradd --home-dir /usr/src/node-red --no-create-home node-red \
	&& chown -R node-red:node-red /data \
	&& apt-get update \
	&& chown -R node-red:node-red /usr/src/node-red \
	&& apt-get install -y --no-install-recommends \
	build-essential \
	git \
	openssh-client \
	make \
	g++ \
	avahi-daemon \
	avahi-discover \
	libnss-mdns \
	libudev-dev \
	supervisor \
	libcap2-bin \
	&& sed -i "s/#enable-dbus=yes/enable-dbus=yes/g" /etc/avahi/avahi-daemon.conf \
	&& sed -i "s/rlimit-nproc/#rlimit-nproc/g" /etc/avahi/avahi-daemon.conf \
	&& setcap cap_net_raw+eip $(eval readlink -f `which node`) \
	&& mkdir /var/run/dbus

COPY supervisord.conf /etc/supervisord.conf

USER node-red

COPY package.json /usr/src/node-red/
WORKDIR /usr/src/node-red
RUN npm install

EXPOSE 1880

# Environment variable holding file path for flows configuration
ENV FLOWS=flows.json
ENV NODE_PATH=/usr/src/node-red/node_modules:/data/node_modules
ENV NPM_CONFIG_PREFIX=/data
ENV NPM_CONFIG_CACHE=/usr/src/node-red

USER root
RUN set -ex \
	&& apt-get remove -y libudev-dev build-essential make g++ \
	&& apt-get autoremove -y \
	&& AUTO_ADDED_PACKAGES=`apt-mark showauto` \
	&& apt-get remove --purge -y $BUILD_PACKAGES $AUTO_ADDED_PACKAGES \
	&& rm -rf /var/cache/apt \
	&& rm -rf /var/lib/apt/lists/* \
	
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]

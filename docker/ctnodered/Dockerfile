FROM node:8-slim
COPY supervisord.conf /etc/supervisord.conf
COPY package.json /usr/src/node-red/

WORKDIR /usr/src/node-red

RUN set -ex \
	&& mkdir -p /usr/src/node-red \
	&& mkdir /data \
	&& useradd --home-dir /usr/src/node-red --no-create-home node-red \
	&& mkdir /var/run/dbus \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
	build-essential \
	git \
	openssh-client \
	avahi-daemon \
	avahi-discover \
	libnss-mdns \
	libudev-dev \
	supervisor \
	libcap2-bin \
	&& sed -i "s/#enable-dbus=yes/enable-dbus=yes/g" /etc/avahi/avahi-daemon.conf \
	&& sed -i "s/rlimit-nproc/#rlimit-nproc/g" /etc/avahi/avahi-daemon.conf \
	&& setcap cap_net_raw+eip $(eval readlink -f `which node`) \
	&& npm install \
	&& npm dedupe \
	&& npm cache clean --force \
	&& chown -R node-red:node-red /usr/src/node-red \
	&& chown -R node-red:node-red /data \
	&& apt-get remove -y libudev-dev build-essential make g++ \
	&& apt-get autoremove -y \
	&& rm -rf /var/cache/apt \
	&& rm -rf /var/lib/apt/lists/* 

EXPOSE 1880

# Environment variable holding file path for flows configuration
ENV FLOWS=flows.json
ENV NODE_PATH=/usr/src/node-red/node_modules:/data/node_modules
ENV NPM_CONFIG_PREFIX=/data
ENV NPM_CONFIG_CACHE=/usr/src/node-red
	
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]

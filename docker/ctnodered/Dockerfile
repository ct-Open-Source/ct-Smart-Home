FROM nodered/node-red-docker:slim-v8
USER root
COPY supervisord.conf /etc/supervisord.conf 
RUN set -ex \
	&& apk add --no-cache --virtual .run-deps \
		make \
		g++ \
		python \
		avahi-compat-libdns_sd \
		avahi-dev \
		dbus \
		su-exec \
		linux-headers\
		eudev-dev \
		eudev \
		supervisor \
	&& rm -rf /var/cache/apk/* \
	&& sed -i "s/#enable-dbus=yes/enable-dbus=yes/g" /etc/avahi/avahi-daemon.conf \
	&& setcap cap_net_raw+eip $(eval readlink -f `which node`)
USER node-red
RUN npm install node-red-contrib-homekit-bridged node-red-contrib-noble node-red-contrib-fritz node-red-contrib-tado-client node-red-dashboard
USER root
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]

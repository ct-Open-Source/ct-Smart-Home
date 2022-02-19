#!/bin/sh
[[ -e /var/run/dbus.pid ]] && su-exec root rm -f /var/run/dbus.pid
[[ -e /run/dbus/dbus.pid ]] && su-exec root rm -f /run/dbus/dbus.pid
[[ -e /var/run/avahi-daemon/pid ]] && su-exec root rm -f /var/run/avahi-daemon/pid
[[ -e /var/run/dbus/system_bus_socket ]] && su-exec root rm -f /var/run/dbus/system_bus_socket

echo "Starting dbus daemon"
su-exec root dbus-daemon --system --fork

until [ -e /var/run/dbus/system_bus_socket ]; do
  sleep 1s
done

echo "Starting Avahi daemon"
su-exec root avahi-daemon -D --no-chroot -f /etc/avahi/avahi-daemon.conf

echo "Starting Node-Red"
su-exec node-red npm start --cache /data/.npm -- --userDir /data

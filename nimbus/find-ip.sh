#!/bin/sh
IP_ADDRESS=$(wget -qO- ifconfig.me/ip)
exec "$@" "--nat=extip:${IP_ADDRESS}"

#!/bin/sh
IP_ADDRESS=$(wget -qO- ifconfig.me/ip)
exec "$@" "--p2p-advertised-ip=${IP_ADDRESS}"

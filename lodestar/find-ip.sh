#!/bin/sh
IP_ADDRESS=$(wget -qO- ifconfig.me/ip)
exec "$@" "--enr.ip=${IP_ADDRESS}"

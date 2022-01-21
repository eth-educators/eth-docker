#!/bin/sh
IP_ADDRESS=$(wget -qO- ifconfig.me/ip)
exec "$@" "--enr-address=${IP_ADDRESS}"

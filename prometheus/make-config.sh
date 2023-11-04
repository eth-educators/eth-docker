#!/bin/sh
# Combine global with custom config
# Expects a full prometheus command with parameters as argument(s)

# Start fresh every time
cp /etc/prometheus/global-prom.yml /etc/prometheus/prometheus.yml
if [ -f "/etc/prometheus/custom-prom.yml" ]; then
    cat /etc/prometheus/custom-prom.yml >> /etc/prometheus/prometheus.yml
fi

exec "$@" --config.file=/etc/prometheus/prometheus.yml

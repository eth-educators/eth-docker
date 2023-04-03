#!/usr/bin/env bash

APP_NAME=$1
TIMEOUT=${2:-60}  # Default timeout is 60 seconds if not provided
INTERVAL=5

while [ "${TIMEOUT}" -gt 0 ]; do
    STATUS=$(docker-compose ps --services --filter "status=running" | grep "${APP_NAME}")

    if [ -n "$STATUS" ]; then
        echo "$APP_NAME is running."
        exit 0
    fi

    sleep "${INTERVAL}"
    TIMEOUT=$((TIMEOUT - INTERVAL))
done

echo "Timed out waiting for $APP_NAME to start."
exit 1

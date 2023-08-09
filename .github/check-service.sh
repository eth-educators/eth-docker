#!/usr/bin/env bash

__service=$1

__containerID=$(docker-compose ps -q "${__service}")

__initial_restart_count=$(docker inspect --format '{{ .RestartCount }}' "$__containerID")
__is_running=$(docker inspect --format '{{ .State.Running }}' "$__containerID")
sleep 10
__final_restart_count=$(docker inspect --format '{{ .RestartCount }}' "$__containerID")

if [ "$__is_running" != "true" ] || [ "$__final_restart_count" -gt "$__initial_restart_count" ]; then
  echo "$__service is either not running or continuously restarting"
  docker-compose ps "${__service}"
  docker-compose logs "${__service}"
  exit 1
else
  echo "$__service is running"
  docker-compose ps "${__service}"
  exit 0
fi

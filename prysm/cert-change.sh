#!/bin/sh
chown -R cert:cert /letsencrypt/certs
docker restart $(docker ps -aqf name=.*consensus.*)

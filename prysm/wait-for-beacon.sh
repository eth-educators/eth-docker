#!/bin/bash
target="tcp://$1"
shift
dockerize -wait $target -timeout 60s "$@"

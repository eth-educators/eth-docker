#!/bin/bash

if [ ! -f /var/lib/lodestar/consensus/api-token.txt ]; then
    __token=api-token-0x$(echo $RANDOM | md5sum | head -c 32)$(echo $RANDOM | md5sum | head -c 32)
    echo $__token > /var/lib/lodestar/consensus/api-token.txt
fi

if [ -n "${RAPID_SYNC_URL:+x}" -a ! -f "/var/lib/lodestar/consensus/setupdone" ]; then
    touch /var/lib/lodestar/consensus/setupdone
    exec $@ --weakSubjectivitySyncLatest=true --weakSubjectivityServerUrl=${RAPID_SYNC_URL}
fi

exec $@

#!/bin/bash

if [ ! -f /var/lib/nimbus/api-token.txt ]; then
    __token=api-token-0x$(echo $RANDOM | md5sum | head -c 32)$(echo $RANDOM | md5sum | head -c 32)
    echo $__token > /var/lib/nimbus/api-token.txt
fi

if [ -n "${RAPID_SYNC_URL:+x}" -a ! -f "/var/lib/nimbus/setupdone" ]; then
    touch /var/lib/nimbus/setupdone
    exec /usr/local/bin/nimbus_beacon_node trustedNodeSync --backfill=false --network=${NETWORK} --data-dir=/var/lib/nimbus --trusted-node-url=${RAPID_SYNC_URL}
fi

exec $@

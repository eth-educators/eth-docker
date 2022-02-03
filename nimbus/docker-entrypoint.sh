#!/bin/bash

if [ ! -f /var/lib/nimbus/api-token.txt ]; then
    __token=api-token-0x$(echo $RANDOM | md5sum | head -c 32)$(echo $RANDOM | md5sum | head -c 32)
    echo $__token > /var/lib/nimbus/api-token.txt
fi

exec $@

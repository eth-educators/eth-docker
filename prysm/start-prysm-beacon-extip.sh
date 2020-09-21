#!/bin/bash
ClientIP=$(curl -s v4.ident.me)

# This will be passed arguments that start the beacon and reference $ClientIP
eval $@

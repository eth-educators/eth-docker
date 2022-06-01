#!/bin/bash
set -Eeuo pipefail

# Check whether we should flag override TTD in VC logs
if [ -n "${OVERRIDE_TTD}" ]; then
  __override_ttd="--terminal-total-difficulty-override=${OVERRIDE_TTD}"
else
  __override_ttd=""
fi

exec $@ ${__override_ttd}

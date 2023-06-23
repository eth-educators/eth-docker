#!/bin/bash

# Start fresh every time
cp /etc/promtail/global.yml /promtail-config.yml

# Set loki push url to one set in environment variable
cat >> /promtail-config.yml << EOF
clients:
  - url: $LOKI_PUSH_URL
EOF

# Add custom loki urls to config with indentation to make sure its valid yml
if [ -f "/etc/promtail/custom-lokiurl.yml" ]; then
  echo "/etc/promtail/custom-lokiurl.yml" | xargs sed 's/^/  /' >> /promtail-config.yml
fi

exec "$@" --config.file=/promtail-config.yml
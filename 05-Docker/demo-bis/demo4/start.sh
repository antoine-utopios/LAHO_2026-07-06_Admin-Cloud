#!/bin/sh

cat > /usr/share/nginx/html/config.js <<EOF
const CONFIG = {
    title: "${SITE_TITLE}",
    message: "${SITE_MESSAGE}",
    environment: "${SITE_ENVIRONMENT}"
};
EOF

exec nginx -g "daemon off;"
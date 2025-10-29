#!/bin/bash
DOMAIN=$(cat /root/domain)
~/.acme.sh/acme.sh --renew -d "$DOMAIN" --force
~/.acme.sh/acme.sh --install-cert -d "$DOMAIN" --ecc \
  --fullchain-file /etc/ssl/certs/${DOMAIN}.crt \
  --key-file /etc/ssl/private/${DOMAIN}.key
systemctl restart nginx >/dev/null 2>&1 || true
systemctl restart xray >/dev/null 2>&1 || true

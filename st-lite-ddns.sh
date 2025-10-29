#!/bin/bash
source /root/.cf/cf.conf
DOMAIN=$(cat /root/domain)
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${CF_ZONE}" \
  -H "Authorization: Bearer ${CF_API_TOKEN}" -H "Content-Type: application/json" | jq -r '.result[0].id')
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?name=${DOMAIN}" \
  -H "Authorization: Bearer ${CF_API_TOKEN}" -H "Content-Type: application/json" | jq -r '.result[0].id')
IP_NOW=$(curl -s ipv4.icanhazip.com)
if [ -n "$RECORD_ID" ]; then
  curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
    -H "Authorization: Bearer ${CF_API_TOKEN}" -H "Content-Type: application/json" \
    --data "{"type":"A","name":"${DOMAIN}","content":"${IP_NOW}","ttl":120,"proxied":false}" >/dev/null
fi

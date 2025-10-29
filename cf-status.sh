# ======================================================
# Project : ST-LITE Auto Setup
# Author  : Dark User
# GitHub  : https://github.com/karisnacell69
# ======================================================
#!/bin/bash
set -euo pipefail
DOMAIN_FILE="/root/domain"
LOG_FILE="/var/log/st-lite-cloudflare.log"

if [ ! -f "$DOMAIN_FILE" ]; then
  echo "No domain configured. Run cloudflare-auto.sh first."
  exit 1
fi

DOMAIN=$(cat "$DOMAIN_FILE")
IP=$(curl -s ipv4.icanhazip.com || echo "N/A")
CRT="/etc/ssl/certs/${DOMAIN}.crt"

echo "======== ST-LITE STATUS ========"
echo "Domain      : $DOMAIN"
echo "Public IP   : $IP"

if [ -f "$CRT" ]; then
  ENDDATE=$(openssl x509 -enddate -noout -in $CRT 2>/dev/null | cut -d= -f2)
  EXP_TS=$(date -d "$ENDDATE" +%s 2>/dev/null || echo 0)
  NOW_TS=$(date +%s)
  if [ "$EXP_TS" -gt 0 ]; then
    DIFF=$(( (EXP_TS - NOW_TS) / 86400 ))
    echo "SSL Expiry  : $ENDDATE ($DIFF days left)"
  else
    echo "SSL Expiry  : cannot parse"
  fi
else
  echo "SSL Expiry  : cert not found"
fi

echo "SSH Port    : 22"
echo "V2Ray TLS   : 443 (nginx -> xray)"
echo "V2Ray WS    : 80 (nginx -> xray)"
echo "UDP Ports   : 7100,7200,7300"
echo ""
if [ -f "$LOG_FILE" ]; then
  echo "Recent Log:"
  tail -n 6 "$LOG_FILE"
fi
echo "==============================="

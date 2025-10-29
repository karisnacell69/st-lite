# ======================================================
# Project : ST-LITE Auto Setup
# Author  : Dark User
# GitHub  : https://github.com/karisnacell69
# ======================================================
#!/bin/bash
set -euo pipefail
CF_CONF="/root/.cf/cf.conf"
DOMAIN_FILE="/root/domain"
LOG_FILE="/var/log/st-lite-cloudflare.log"

echo ""
echo "=== CLOUDFLARE AUTO DOMAIN & SSL (Dark User) - API TOKEN MODE ==="

apt update -y >/dev/null 2>&1 || true
apt install -y jq curl socat cron openssl ca-certificates >/dev/null 2>&1 || true

log(){ echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$LOG_FILE"; }

if [ -f "$CF_CONF" ]; then
  source "$CF_CONF"
  echo "Found existing Cloudflare config for $CF_ZONE"
  read -p "Use existing config? (y/n): " yn
  if [ "$yn" != "y" ]; then
    rm -f "$CF_CONF"
  fi
fi

if [ ! -f "$CF_CONF" ]; then
  echo "Create /root/.cf/cf.conf with your settings, example available at /root/st-lite/cf.conf.example"
  read -p "Proceed to create sample cf.conf now? (y/n): " create
  if [ "$create" = "y" ]; then
    mkdir -p "$(dirname "$CF_CONF")"
    cat > "$CF_CONF" <<'EOF'
# Cloudflare Configuration (ST-LITE v2)
# Replace values with your real token, email, zone and preferred subdomain prefix
CF_EMAIL="you@example.com"
CF_API_TOKEN="your_api_token_here"
CF_ZONE="example.com"
CF_RECORD_PREFIX="vpn"
EOF
    chmod 600 "$CF_CONF"
    echo "Sample $CF_CONF created. Edit it and run this script again."
    exit 0
  else
    echo "Aborting. Please create $CF_CONF and re-run."
    exit 1
  fi
fi

source "$CF_CONF"

# validate token by fetching zone id
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${CF_ZONE}" \
  -H "Authorization: Bearer ${CF_API_TOKEN}" -H "Content-Type: application/json" | jq -r '.result[0].id')

if [ -z "$ZONE_ID" ] || [ "$ZONE_ID" = "null" ]; then
  echo "Failed to get Zone ID. Check CF_ZONE and CF_API_TOKEN."
  log "Failed to get Zone ID for $CF_ZONE"
  exit 1
fi

# generate subdomain
RAND=$(tr -dc a-z0-9 </dev/urandom | head -c 6)
SUBDOMAIN="${CF_RECORD_PREFIX}-${RAND}.${CF_ZONE}"
MYIP=$(curl -s ipv4.icanhazip.com)

# create DNS A record via API Token
CREATE_DNS=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
  -H "Authorization: Bearer ${CF_API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data "{"type":"A","name":"${SUBDOMAIN}","content":"${MYIP}","ttl":120,"proxied":false}")

if echo "$CREATE_DNS" | jq -e '.success' >/dev/null 2>&1; then
  echo "Created subdomain: ${SUBDOMAIN}"
  log "Created subdomain ${SUBDOMAIN}"
else
  echo "Failed to create DNS record: $(echo $CREATE_DNS | jq -c '.')"
  log "Failed to create DNS record for ${SUBDOMAIN}"
  exit 1
fi

echo "$SUBDOMAIN" > "$DOMAIN_FILE"

# install acme.sh if needed
if [ ! -d "/root/.acme.sh" ]; then
  curl https://get.acme.sh | sh
fi

export CF_Token="${CF_API_TOKEN}"
export CF_Email="${CF_EMAIL}"

~/.acme.sh/acme.sh --issue --dns dns_cf -d "${SUBDOMAIN}" --keylength ec-256 --force
~/.acme.sh/acme.sh --install-cert -d "${SUBDOMAIN}" --ecc \
  --fullchain-file /etc/ssl/certs/${SUBDOMAIN}.crt \
  --key-file /etc/ssl/private/${SUBDOMAIN}.key

echo "Installed cert for ${SUBDOMAIN}"
log "Installed cert for ${SUBDOMAIN}"

# create ddns & renew scripts and cron
CRON_DDNS="/usr/local/bin/st-lite-ddns.sh"
with open("/dev/null","w") as f: pass

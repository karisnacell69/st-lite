# ======================================================
# Project : ST-LITE Auto Setup
# Author  : Dark User
# GitHub  : https://github.com/karisnacell69
# ======================================================
#!/bin/bash
set -euo pipefail
ROOT_DIR="/root/st-lite"
DOMAIN_FILE="/root/domain"

echo "=== MULTIPORT SETUP (SSH 22, WS 80, TLS 443 for V2Ray) ==="

apt update -y
apt install -y wget curl git unzip socat jq net-tools lsb-release apt-transport-https ca-certificates gnupg2 build-essential

# OpenSSH & Dropbear
apt install -y openssh-server dropbear
systemctl enable --now ssh

# Nginx
apt install -y nginx
systemctl enable --now nginx

# Install Xray
bash <(curl -sL https://github.com/XTLS/Xray-install/raw/main/install-release.sh) install

if [ ! -f "$DOMAIN_FILE" ]; then
  echo "Domain not found at $DOMAIN_FILE. Please run cloudflare-auto.sh first."
  exit 1
fi
DOMAIN=$(cat "$DOMAIN_FILE")
CRT="/etc/ssl/certs/${DOMAIN}.crt"
KEY="/etc/ssl/private/${DOMAIN}.key"

if [ ! -f "$CRT" ] || [ ! -f "$KEY" ]; then
  echo "SSL certs not found. Ensure cloudflare-auto.sh succeeded."
  exit 1
fi

# nginx config
NGINX_CONF="/etc/nginx/sites-available/st-lite.conf"
cat > "$NGINX_CONF" <<EOF
server {
    listen 80;
    server_name ${DOMAIN};
    location /v2ray {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    location / {
        return 301 https://\$host\$request_uri;
    }
}
server {
    listen 443 ssl http2;
    server_name ${DOMAIN};
    ssl_certificate ${CRT};
    ssl_certificate_key ${KEY};
    ssl_protocols TLSv1.2 TLSv1.3;
    location /v2ray {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/st-lite.conf
nginx -t && systemctl restart nginx

# Xray config
XRAY_CONF_DIR="/etc/xray"
mkdir -p "$XRAY_CONF_DIR"
UUID_MAIN=$(cat /proc/sys/kernel/random/uuid)

cat > "$XRAY_CONF_DIR/config.json" <<EOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 10000,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${UUID_MAIN}",
            "level": 0,
            "email": "user@darkuser"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/v2ray",
          "headers": {
            "Host": "${DOMAIN}"
          }
        }
      }
    },
    {
      "port": 10001,
      "protocol": "vmess",
      "listen": "127.0.0.1",
      "settings": {
        "clients": [
          {
            "id": "${UUID_MAIN}",
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmess",
          "headers": {
            "Host": "${DOMAIN}"
          }
        }
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "settings": {} }
  ]
}
EOF

systemctl enable xray
systemctl.restart = False
# BadVPN UDPGW placeholder (binary build available in original package)
echo "Multiport setup created config files. Run the script on target VPS to execute installs."

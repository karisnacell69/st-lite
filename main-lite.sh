# ======================================================
# Project : ST-LITE Auto Setup
# Author  : Dark User
# GitHub  : https://github.com/karisnacell69
# ======================================================
#!/bin/bash
set -euo pipefail
ROOT_DIR="/root/st-lite"

clear
cat <<'EOF'
========================================
   ST-LITE MANAGEMENT MENU - Dark User (v2)
========================================
EOF

echo "1) Install dependencies & initial setup (install-lite.sh)"
echo "2) Auto Domain & SSL (Cloudflare, API Token) - cloudflare-auto.sh"
echo "3) Multi-Port Setup (SSH, V2Ray, BadVPN) - multiport-setup.sh"
echo "4) Status (domain/ssl/ports) - cf-status.sh"
echo "5) Show sample Cloudflare config (/root/.cf/cf.conf)"
echo "6) Exit"
read -p "Choose [1-6]: " opt

case "$opt" in
  1) bash "$ROOT_DIR/install-lite.sh" ;;
  2) bash "$ROOT_DIR/cloudflare-auto.sh" ;;
  3) bash "$ROOT_DIR/multiport-setup.sh" ;;
  4) bash "$ROOT_DIR/cf-status.sh" ;;
  5) echo 'Sample CF config path: /root/.cf/cf.conf (edit values: CF_EMAIL, CF_API_TOKEN, CF_ZONE, CF_RECORD_PREFIX)'; cat /root/st-lite/cf.conf.example 2>/dev/null || true ;;
  6) echo "Bye"; exit 0 ;;
  *) echo "Invalid"; exit 1 ;;
esac

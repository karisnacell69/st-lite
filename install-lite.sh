# ======================================================
# Project : ST-LITE Auto Setup
# Author  : Dark User
# GitHub  : https://github.com/karisnacell69
# ======================================================
#!/bin/bash
set -euo pipefail
echo "Initial installer for ST-LITE (Dark User v2)"
apt update -y
apt install -y wget curl git jq unzip socat cron openssl ca-certificates build-essential
mkdir -p /root/st-lite
echo "Basic deps installed. Now run the menu: bash /root/st-lite/main-lite.sh"

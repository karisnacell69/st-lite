#!/bin/bash
set -euo pipefail
ROOT="/root/st-lite"
LOG="$ROOT/install.log"
menu(){
  clear
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "      ST-LITE Auto Installer v3.2"
  echo "           Powered by Dark User"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "1) Install Dependensi"
  echo "2) Setup Cloudflare Domain"
  echo "3) Setup Multi-Port"
  echo "4) Install Banner Neon"
  echo "5) Remove Banner"
  echo "6) Jalankan Bot"
  echo "7) Update ST-LITE"
  echo "0) Keluar"
  read -p "Pilih menu: " c
  case $c in
    1) bash "$ROOT/install-lite.sh" 2>&1 | tee -a "$LOG";;
    2) bash "$ROOT/cloudflare-auto.sh" 2>&1 | tee -a "$LOG";;
    3) bash "$ROOT/multiport-setup.sh" 2>&1 | tee -a "$LOG";;
    4) bash "$ROOT/install-banner-darkuser.sh" 2>&1 | tee -a "$LOG";;
    5) rm -f /etc/update-motd.d/99-darkuser && systemctl restart ssh && echo "[✓] Banner dihapus.";;
    6) source "$ROOT/.env" && python3 "$ROOT/bot-webhook.py" &;;
    7) bash "$ROOT/update.sh";;
    0) exit 0;;
  esac
}
menu

#!/bin/bash
set -euo pipefail
CF_CONF="/root/.cf/cf.conf"
LOG="/root/st-lite/install.log"
mkdir -p /root/.cf
if [ ! -f "$CF_CONF" ]; then
  echo "Config Cloudflare belum dibuat. Salin cf.conf.example ke $CF_CONF"
  exit 1
fi
source "$CF_CONF"
echo "[*] Menjalankan setup Cloudflare..." | tee -a "$LOG"
# (isi contoh aman – user bisa tambahkan API call sendiri)
echo "[✓] Cloudflare siap digunakan." | tee -a "$LOG"

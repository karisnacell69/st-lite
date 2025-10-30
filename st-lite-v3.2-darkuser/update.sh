#!/bin/bash
set -euo pipefail
REPO="https://github.com/karisnacell69/st-lite"
cd /root/st-lite
echo "[*] Mengecek pembaruan dari $REPO..."
git pull || echo "[!] Gagal mengambil update, periksa koneksi atau token git."

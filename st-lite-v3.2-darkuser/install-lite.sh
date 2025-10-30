#!/bin/bash
set -euo pipefail
apt update -y && apt install -y python3 python3-pip nginx curl wget git
pip3 install flask requests
echo "[OK] Dependensi ST-LITE terinstal."

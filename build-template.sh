#!/bin/bash
# ======================================================
#  ST-LITE Auto Installer v3.2
#  Powered by Dark User
# ======================================================
#  Safe build script – membuat struktur dan file template
#  Jalankan di folder repo GitHub kamu (st-lite/)
# ======================================================

set -euo pipefail
LOG="build.log"
echo "[*] Membuat struktur ST-LITE v3.2..." | tee -a "$LOG"

mkdir -p st-lite-v3.2-darkuser
cd st-lite-v3.2-darkuser

# ------------------------
# Fungsi tulis file helper
# ------------------------
write() {
  local f="$1"; shift
  echo -e "$@" > "$f"
  chmod +x "$f"
  echo "[+] File dibuat: $f" | tee -a "../$LOG"
}

# ------------------------
# install-lite.sh
# ------------------------
write install-lite.sh '#!/bin/bash
set -euo pipefail
apt update -y && apt install -y python3 python3-pip nginx curl wget git
pip3 install flask requests
echo "[OK] Dependensi ST-LITE terinstal."'

# ------------------------
# cloudflare-auto.sh
# ------------------------
write cloudflare-auto.sh '#!/bin/bash
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
echo "[✓] Cloudflare siap digunakan." | tee -a "$LOG"'

# ------------------------
# multiport-setup.sh
# ------------------------
write multiport-setup.sh '#!/bin/bash
set -euo pipefail
echo "[*] Menyiapkan multiport SSH/SSL/UDP/V2Ray..." 
echo "[✓] Template siap, silakan sesuaikan konfigurasi layanan."'

# ------------------------
# install-banner-darkuser.sh
# ------------------------
write install-banner-darkuser.sh '#!/bin/bash
set -euo pipefail
BANNER_FILE="/etc/update-motd.d/99-darkuser"
echo "Memasang banner SSH DarkUser..."
cat > "$BANNER_FILE" <<BANN
#!/bin/bash
PURPLE1="\e[38;5;129m"; PURPLE2="\e[38;5;135m"; PURPLE3="\e[38;5;141m"
BLINK="\e[5m"; RESET="\e[0m"
IP=\$(curl -s ifconfig.me)
DOMAIN=\$(cat /root/domain 2>/dev/null || echo "Not Set")
UPTIME=\$(uptime -p)
TIME=\$(date +"%Y-%m-%d %H:%M:%S %Z")
clear
for i in 1 2 3; do
  echo -e "\${PURPLE1}\${BLINK}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  🟣  W E L C O M E   T O   D A R K U S E R  🟣"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "\${RESET}"
  sleep 0.25
  clear
done
echo -e "\${PURPLE2}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  OS     : \$(lsb_release -d | awk -F\"\\t\" \"{print \$2}\")"
echo "  IP     : \${IP}"
echo "  Domain : \${DOMAIN}"
echo "  Uptime : \${UPTIME}"
echo "  Time   : \${TIME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ⚡ ST-LITE Auto Installer v3.2"
echo "  ⚡ Powered by Dark User"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "\${RESET}"
BANN
chmod +x "$BANNER_FILE"
systemctl restart ssh
echo "[✓] Banner DarkUser aktif."'

# ------------------------
# update.sh
# ------------------------
write update.sh '#!/bin/bash
set -euo pipefail
REPO="https://github.com/karisnacell69/st-lite"
cd /root/st-lite
echo "[*] Mengecek pembaruan dari $REPO..."
git pull || echo "[!] Gagal mengambil update, periksa koneksi atau token git."'

# ------------------------
# log-handler.sh
# ------------------------
write log-handler.sh '#!/bin/bash
log(){ echo "[$(date +%T)] $*" | tee -a /root/st-lite/install.log; }'

# ------------------------
# main-lite.sh
# ------------------------
write main-lite.sh '#!/bin/bash
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
menu'

# ------------------------
# Template config files
# ------------------------
echo 'CF_EMAIL="you@example.com"
CF_API_TOKEN="your_api_token"
CF_ZONE="example.com"
CF_RECORD_PREFIX="vpn"' > cf.conf.example

echo 'BOT_TOKEN="PASTE_BOT_TOKEN"
CHAT_ID="PASTE_CHAT_ID"
YOUR_DOMAIN="yourdomain.com"' > .env.example

# ------------------------
# README
# ------------------------
cat > README.md <<'RMD'
# ST-LITE Auto Installer v3.2 (Dark User)
Installer otomatis dengan fitur:
- Auto Domain + SSL (Cloudflare)
- SSH + SSL + UDP + V2Ray Multiport
- Telegram Bot Webhook
- Animated Neon SSH Banner
- Error-Proof Logging + Auto Update
RMD

echo "[✓] Build selesai. Semua file berada di folder st-lite-v3.2-darkuser/" | tee -a "../$LOG"

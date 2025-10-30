#!/bin/bash
set -euo pipefail
BANNER_FILE="/etc/update-motd.d/99-darkuser"
echo "Memasang banner SSH DarkUser..."
cat > "$BANNER_FILE" <<BANN
#!/bin/bash
PURPLE1="[38;5;129m"; PURPLE2="[38;5;135m"; PURPLE3="[38;5;141m"
BLINK="[5m"; RESET="[0m"
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
echo "  OS     : \$(lsb_release -d | awk -F\"\t\" \"{print \$2}\")"
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
echo "[✓] Banner DarkUser aktif."

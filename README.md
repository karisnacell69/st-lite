# ST-LITE Auto Setup v2 (Dark User)
Auto installer package for ST-LITE (SSH + V2Ray + Cloudflare Auto Domain + SSL) - API Token ready

## Files
- cloudflare-auto.sh : Create subdomain in Cloudflare using API Token + issue SSL via acme.sh + configure cron
- multiport-setup.sh : Install OpenSSH, nginx, Xray, BadVPN and configure multi-port routing (V2Ray on 80/443)
- cf-status.sh       : Show domain, IP, SSL expiry and ports
- main-lite.sh       : Menu to run tasks
- install-lite.sh    : Basic dependency installer
- cf.conf.example    : Sample Cloudflare config file (copy to /root/.cf/cf.conf and edit)

## Usage
1. Upload files to server `/root/st-lite`
2. chmod +x *.sh
3. Copy sample config:
   mkdir -p /root/.cf
   cp /root/st-lite/cf.conf.example /root/.cf/cf.conf
   nano /root/.cf/cf.conf
   - Fill CF_EMAIL, CF_API_TOKEN, CF_ZONE, CF_RECORD_PREFIX
4. Run menu:
   bash /root/st-lite/main-lite.sh

Recommended flow:
- Option 1: install deps
- Option 2: Auto Domain & SSL (will create subdomain + cert)
- Option 3: Multi-Port Setup

# Forgejo Complete Installation Guide for Ubuntu 22.04/24.04

**Self-hosted Git service - Community-driven, lightweight, and powerful**

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Initial Configuration](#initial-configuration)
5. [Nginx Reverse Proxy](#nginx-reverse-proxy)
6. [SSL with Let's Encrypt](#ssl-with-lets-encrypt)
7. [Database Setup (MySQL)](#database-setup-mysql)
8. [Administration](#administration)
9. [Backup & Restore](#backup--restore)
10. [Troubleshooting](#troubleshooting)

---

## Introduction

### What is Forgejo?

Forgejo is a self-hosted Git service that provides:

✅ Git repository hosting  
✅ Issue tracking and project management  
✅ CI/CD with Forgejo Actions  
✅ Package registry (npm, Docker, Maven, etc.)  
✅ Wiki documentation  
✅ Code review tools  
✅ Lightweight (<100MB RAM)  

---

## Prerequisites

### System Requirements

**Minimum:**
- Ubuntu 22.04 or 24.04
- 1 CPU core
- 512 MB RAM
- 10 GB disk

**Recommended:**
- 2 CPU cores
- 2 GB RAM
- 50 GB disk

### Verify System
```bash
# Check Ubuntu version
lsb_release -a

# Check resources
free -h
df -h

# Install Git
sudo apt update
sudo apt install -y git
```

---

## Installation

### Step 1: Create Forgejo User
```bash
# Create system user
sudo adduser --system --group --disabled-password \
  --shell /bin/bash --home /home/git \
  --gecos 'Git Version Control' git

# Verify
id git
```

### Step 2: Download Forgejo
```bash
# Get latest version from: https://codeberg.org/forgejo/forgejo/releases
FORGEJO_VERSION="7.0.0"

# Download binary
sudo wget -O /usr/local/bin/forgejo \
  https://codeberg.org/forgejo/forgejo/releases/download/v${FORGEJO_VERSION}/forgejo-${FORGEJO_VERSION}-linux-amd64

# Make executable
sudo chmod +x /usr/local/bin/forgejo

# Verify
forgejo --version
```

### Step 3: Create Directories
```bash
# Create working directories
sudo mkdir -p /var/lib/forgejo/{custom,data,log}
sudo chown -R git:git /var/lib/forgejo/
sudo chmod -R 750 /var/lib/forgejo/

# Create config directory
sudo mkdir -p /etc/forgejo
sudo chown root:git /etc/forgejo
sudo chmod 770 /etc/forgejo

# Create repositories directory
sudo mkdir -p /var/lib/forgejo/repositories
sudo chown git:git /var/lib/forgejo/repositories
```

### Step 4: Create Systemd Service
```bash
sudo nano /etc/systemd/system/forgejo.service
```

**Paste this:**
```ini
[Unit]
Description=Forgejo (Beyond coding. We forge.)
After=syslog.target network.target

[Service]
RestartSec=2s
Type=notify
User=git
Group=git
WorkingDirectory=/var/lib/forgejo/
ExecStart=/usr/local/bin/forgejo web --config /etc/forgejo/app.ini
Restart=always
Environment=USER=git HOME=/home/git FORGEJO_WORK_DIR=/var/lib/forgejo

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/forgejo /etc/forgejo
CapabilityBoundingSet=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
```

### Step 5: Start Forgejo
```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable and start
sudo systemctl enable forgejo
sudo systemctl start forgejo

# Check status
sudo systemctl status forgejo

# Verify listening
sudo ss -tulpn | grep 3000
```

---

## Initial Configuration

### Access Web Interface

Open browser: `http://your-server-ip:3000`

### Installation Settings

**Database Settings (SQLite for quick start):**
```
Database Type: SQLite3
Path: /var/lib/forgejo/data/forgejo.db
```

**General Settings:**
```
Site Title: Your Company Git
Repository Root Path: /var/lib/forgejo/repositories
Git LFS Root Path: /var/lib/forgejo/data/lfs
Run As Username: git
Server Domain: git.yourdomain.com
SSH Server Port: 22
HTTP Port: 3000
Application URL: http://git.yourdomain.com/
Log Path: /var/lib/forgejo/log
```

**Admin Account:**
```
Username: admin
Password: [strong password]
Email: admin@yourdomain.com
```

**Click "Install Forgejo"**

### Post-Install Security
```bash
# Secure config file
sudo chmod 750 /etc/forgejo
sudo chmod 640 /etc/forgejo/app.ini

# Restart
sudo systemctl restart forgejo
```

---

## Nginx Reverse Proxy

### Install Nginx
```bash
sudo apt install -y nginx
```

### Create Configuration
```bash
sudo nano /etc/nginx/sites-available/forgejo
```

**Paste this:**
```nginx
upstream forgejo {
    server 127.0.0.1:3000;
}

server {
    listen 80;
    listen [::]:80;
    server_name git.yourdomain.com;

    location / {
        proxy_pass http://forgejo;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts
        proxy_connect_timeout 600;
        proxy_send_timeout 600;
        proxy_read_timeout 600;
    }

    # Large file uploads
    client_max_body_size 512M;
}
```

### Enable Configuration
```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/forgejo /etc/nginx/sites-enabled/

# Test config
sudo nginx -t

# Reload
sudo systemctl reload nginx

# Configure firewall
sudo ufw allow 'Nginx Full'
```

### Update Forgejo Config
```bash
sudo nano /etc/forgejo/app.ini
```

**Update:**
```ini
[server]
DOMAIN = git.yourdomain.com
ROOT_URL = http://git.yourdomain.com/
HTTP_PORT = 3000
```
```bash
sudo systemctl restart forgejo
```

---

## SSL with Let's Encrypt

### Install Certbot
```bash
sudo apt install -y certbot python3-certbot-nginx
```

### Obtain Certificate
```bash
# Get SSL certificate
sudo certbot --nginx -d git.yourdomain.com \
  --email your-email@domain.com \
  --agree-tos --no-eff-email
```

### Update Forgejo for HTTPS
```bash
sudo nano /etc/forgejo/app.ini
```

**Change:**
```ini
[server]
ROOT_URL = https://git.yourdomain.com/
```
```bash
sudo systemctl restart forgejo
```

### Verify SSL

Test: `https://git.yourdomain.com`
```bash
# Check renewal timer
sudo systemctl status certbot.timer

# Test renewal
sudo certbot renew --dry-run
```

---

## Database Setup (MySQL)

### Install MariaDB
```bash
# Install
sudo apt install -y mariadb-server

# Secure installation
sudo mysql_secure_installation
```

**Answer:**
- Set root password: Yes
- Remove anonymous users: Yes
- Disallow root login remotely: Yes
- Remove test database: Yes

### Create Forgejo Database
```bash
sudo mysql -u root -p
```

**Execute:**
```sql
CREATE DATABASE forgejo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'forgejo'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON forgejo.* TO 'forgejo'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Configure Forgejo
```bash
sudo nano /etc/forgejo/app.ini
```

**Add/modify:**
```ini
[database]
DB_TYPE = mysql
HOST = 127.0.0.1:3306
NAME = forgejo
USER = forgejo
PASSWD = secure_password
CHARSET = utf8mb4
```
```bash
sudo systemctl restart forgejo
```

---

## Administration

### Admin Commands
```bash
# Create user
sudo -u git forgejo admin user create \
  --username newuser \
  --password password \
  --email user@example.com

# List users
sudo -u git forgejo admin user list

# Change password
sudo -u git forgejo admin user change-password \
  --username user \
  --password newpass

# Make user admin
sudo -u git forgejo admin user change-password \
  --username user \
  --admin
```

### SSH Configuration
```bash
# Test SSH
ssh -T git@git.yourdomain.com
```

**Expected:**
```
Hi there, You've successfully authenticated
```

### Enable Actions (CI/CD)
```bash
sudo nano /etc/forgejo/app.ini
```

**Add:**
```ini
[actions]
ENABLED = true
DEFAULT_ACTIONS_URL = https://code.forgejo.org
```
```bash
sudo systemctl restart forgejo
```

---

## Backup & Restore

### Create Backup Script
```bash
sudo nano /usr/local/bin/backup-forgejo.sh
```

**Paste:**
```bash
#!/bin/bash

BACKUP_DIR="/backup/forgejo"
DATE=$(date +%Y%m%d-%H%M%S)
RETENTION_DAYS=30

mkdir -p $BACKUP_DIR

echo "Starting backup: $DATE"

# Create backup
sudo -u git forgejo dump \
  --config /etc/forgejo/app.ini \
  --file $BACKUP_DIR/forgejo-$DATE.zip \
  --tempdir /tmp

# Clean old backups
find $BACKUP_DIR -name "forgejo-*.zip" -mtime +$RETENTION_DAYS -delete

echo "Backup complete: forgejo-$DATE.zip"
```
```bash
# Make executable
sudo chmod +x /usr/local/bin/backup-forgejo.sh

# Test
sudo /usr/local/bin/backup-forgejo.sh
```

### Schedule Backups
```bash
sudo crontab -e
```

**Add (daily at 2 AM):**
```
0 2 * * * /usr/local/bin/backup-forgejo.sh >> /var/log/forgejo-backup.log 2>&1
```

### Restore
```bash
# Stop Forgejo
sudo systemctl stop forgejo

# Extract backup
cd /tmp
sudo -u git unzip /backup/forgejo/forgejo-YYYYMMDD-HHMMSS.zip

# Restore
sudo -u git forgejo restore --config /etc/forgejo/app.ini --from /tmp

# Start
sudo systemctl start forgejo
```

---

## Troubleshooting

### Service Won't Start
```bash
# Check status
sudo systemctl status forgejo

# View logs
sudo journalctl -u forgejo -n 100 -f

# Check config
sudo -u git forgejo doctor check --config /etc/forgejo/app.ini

# Check permissions
ls -la /var/lib/forgejo
ls -la /etc/forgejo
```

### Port Issues
```bash
# Check what's using port
sudo lsof -i :3000
sudo ss -tulpn | grep 3000
```

### Permission Errors
```bash
# Fix ownership
sudo chown -R git:git /var/lib/forgejo
sudo chown root:git /etc/forgejo
sudo chmod 770 /etc/forgejo
sudo chmod 640 /etc/forgejo/app.ini
```

### Database Connection Issues
```bash
# Test MySQL connection
mysql -u forgejo -p forgejo

# Check database
sudo -u git forgejo admin regenerate hooks
```

### Git Push Fails
```bash
# Check SSH
ssh -T git@git.yourdomain.com

# Regenerate hooks
sudo -u git forgejo admin regenerate hooks

# Check repo permissions
sudo ls -la /var/lib/forgejo/repositories
```

---

## Maintenance

### Daily
```bash
# Check services
sudo systemctl status forgejo nginx mariadb

# Check disk
df -h /var/lib/forgejo

# Check logs
sudo journalctl -u forgejo --since today
```

### Weekly
```bash
# Update Forgejo
FORGEJO_VERSION="7.0.1"
sudo systemctl stop forgejo
sudo wget -O /usr/local/bin/forgejo \
  https://codeberg.org/forgejo/forgejo/releases/download/v${FORGEJO_VERSION}/forgejo-${FORGEJO_VERSION}-linux-amd64
sudo chmod +x /usr/local/bin/forgejo
sudo systemctl start forgejo

# Verify
forgejo --version
```

### Monthly
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Check backups
ls -lh /backup/forgejo/

# Review users
sudo -u git forgejo admin user list
```

---

## Useful Commands

### Service Management
```bash
sudo systemctl start forgejo
sudo systemctl stop forgejo
sudo systemctl restart forgejo
sudo systemctl status forgejo
sudo journalctl -u forgejo -f
```

### Admin Tasks
```bash
# User management
sudo -u git forgejo admin user list
sudo -u git forgejo admin user create --admin --username admin --password pass --email admin@example.com

# Cleanup
sudo -u git forgejo admin cleanup

# Check config
sudo -u git forgejo doctor check
```

---

## Configuration Files

**Key locations:**
```
/usr/local/bin/forgejo              - Binary
/etc/forgejo/app.ini                - Configuration
/var/lib/forgejo/                   - Working directory
/var/lib/forgejo/data/              - Database
/var/lib/forgejo/repositories/      - Git repos
/var/lib/forgejo/log/               - Logs
/etc/systemd/system/forgejo.service - Service
/etc/nginx/sites-available/forgejo  - Nginx config
```

---

## Security Best Practices

1. ✅ Use HTTPS with Let's Encrypt
2. ✅ Strong admin password
3. ✅ Enable 2FA for admin
4. ✅ Regular backups
5. ✅ Keep Forgejo updated
6. ✅ Use firewall (UFW)
7. ✅ Use SSH keys for Git
8. ✅ Limit admin access
9. ✅ Monitor logs
10. ✅ Disable registration (if private)

---

## Advanced Configuration

### Email Notifications
```bash
sudo nano /etc/forgejo/app.ini
```
```ini
[mailer]
ENABLED = true
FROM = forgejo@yourdomain.com
PROTOCOL = smtp
SMTP_ADDR = smtp.gmail.com
SMTP_PORT = 587
USER = your-email@gmail.com
PASSWD = app-password
```

### LFS (Large File Storage)
```ini
[lfs]
STORAGE_TYPE = local
PATH = /var/lib/forgejo/data/lfs
```
```bash
sudo mkdir -p /var/lib/forgejo/data/lfs
sudo chown git:git /var/lib/forgejo/data/lfs
```

### Package Registry
```ini
[packages]
ENABLED = true
```

---

## Next Steps

After installation:

1. Create your first repository
2. Add SSH keys
3. Invite team members
4. Set up CI/CD Actions
5. Configure webhooks
6. Enable package registry
7. Create organizations
8. Set up automated backups

---

## Resources

**Official:**
- Docs: https://forgejo.org/docs/
- Releases: https://codeberg.org/forgejo/forgejo/releases
- Matrix Chat: #forgejo-chat:matrix.org

**Community:**
- Forum: https://codeberg.org/forgejo/discussions
- Issues: https://codeberg.org/forgejo/forgejo/issues

---

**Version:** 1.0  
**Last Updated:** December 2024  
**Tested On:** Ubuntu 22.04 & 24.04  
**Forgejo Version:** 7.0.0

---

**End of Guide - Happy Forging! 🔨**

# Ubuntu 24.04 Server Setup & Hardening Guide

**A comprehensive step-by-step guide for setting up and securing Ubuntu 24.04 servers.**

## 📋 Table of Contents

1. OS Installation
2. Install Necessary Packages
3. Set Hostname
4. Change SSH Port
5. SSH Certificate Authentication
6. Timezone Configuration
7. Disable systemd-resolved
8. Set UTF-8 Locale
9. Configure GRUB
10. Clear MOTD
11. Configure Swap
12. Kernel Tuning
13. APT Sources
14. TCP Wrappers
15. UFW Firewall
16. iptables/nftables
17. Netplan

---

## STEP 1: OS Installation

### Installation Checklist

**✅ User Configuration**
- Set username and strong password

**✅ Disk Configuration**
- Store Virtual Disk as Single File
- Use Automatic Partition Scheme
- Use ext4 (NOT LVM)

**✅ Network**
- Configure Static IP

**✅ Software**
- Enable SSH Server
- Minimal Installation

---

## STEP 2: Install Necessary Packages
```bash
sudo apt update && sudo apt upgrade -y

sudo apt install -y qemu-guest-agent locales locales-all openssh-server \
  vim nano htop net-tools ifupdown tmux wireguard mtr wget curl \
  traceroute frr dnsutils iputils-ping ufw

sudo apt install --install-recommends linux-generic-hwe-24.04 -y
```

---

## STEP 3: Set or Modify Hostname
```bash
# Check hostname
hostname
hostnamectl

# Set new hostname
sudo hostnamectl set-hostname your-new-hostname

# Edit /etc/hosts
sudo nano /etc/hosts
```

Add:
```
127.0.0.1    localhost
127.0.1.1    your-new-hostname
```

---

## STEP 4: Change SSH Port
```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config
```

Change:
```
Port 2222
```
```bash
# Restart SSH
sudo systemctl restart ssh

# Update firewall
sudo ufw allow 2222/tcp
sudo ufw delete allow 22/tcp
```

---

## STEP 5: SSH Certificate Authentication

### Generate key (local machine):
```bash
ssh-keygen -t ed25519 -C "your-email"
```

### Copy to server:
```bash
ssh-copy-id -p 2222 username@server-ip
```

### Configure server:
```bash
sudo nano /etc/ssh/sshd_config
```

Set:
```
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
```
```bash
sudo systemctl restart ssh
```

---

## STEP 6: Timezone Configuration
```bash
timedatectl list-timezones | grep Dhaka
sudo timedatectl set-timezone Asia/Dhaka
sudo timedatectl set-ntp true
```

---

## STEP 7: Disable systemd-resolved
```bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo rm /etc/resolv.conf

sudo bash -c 'cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF'
```

---

## STEP 8: Set Local Language UTF-8
```bash
sudo dpkg-reconfigure locales
# Select: en_US.UTF-8

sudo update-locale LANG=en_US.UTF-8 LANGUAGE="en_US:en"
echo "export LANG=en_US.UTF-8" >> ~/.bashrc
```

---

## STEP 9: Modify GRUB Bootloader
```bash
sudo nano /etc/default/grub
```

Modify:
```
GRUB_TIMEOUT=5
GRUB_CMDLINE_LINUX=""
```
```bash
sudo update-grub
```

---

## STEP 10: Clear update-motd.d
```bash
sudo rm -rf /etc/update-motd.d/*
```

---

## STEP 11: Modify Swap Space
```bash
sudo swapoff /swap.img
sudo rm /swap.img
sudo fallocate -l 8G /swap.img
sudo chmod 600 /swap.img
sudo mkswap /swap.img
sudo swapon /swap.img

echo '/swap.img none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## STEP 12: Kernel Tuning with sysctl
```bash
sudo nano /etc/sysctl.d/99-sysctl.conf
```

Add:
```bash
net.ipv4.ip_forward=1
fs.file-max = 2097152
net.ipv4.tcp_max_orphans = 60000
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_max_syn_backlog = 100000
net.ipv4.tcp_congestion_control=bbr
net.core.default_qdisc=fq
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_synack_retries = 2
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_fin_timeout = 15
net.core.somaxconn = 100000
net.core.netdev_max_backlog = 100000
net.ipv4.tcp_mem = 65536 131072 262144
net.ipv4.udp_mem = 65536 131072 262144
net.core.rmem_max = 25165824
net.ipv4.tcp_rmem = 20480 12582912 25165824
net.core.wmem_max = 25165824
net.ipv4.tcp_wmem = 20480 12582912 25165824
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_tw_reuse = 1
vm.swappiness=75
vm.page-cluster=0
```
```bash
sudo sysctl -p
```

### Security Limits
```bash
sudo nano /etc/security/limits.conf
```

Add:
```
root soft nproc 1024000
root hard nproc 1024000
root soft nofile 1024000
root hard nofile 1024000
```

---

## STEP 13: APT Source List
```bash
cat /etc/apt/sources.list.d/ubuntu.sources
```

---

## STEP 14: TCP Wrapper Security
```bash
sudo nano /etc/hosts.allow
```
```
sshd : 127.0.0.1, 172.23.46.128/28, 192.168.42.40
```
```bash
sudo nano /etc/hosts.deny
```
```
sshd : ALL
```

---

## STEP 15: UFW Firewall
```bash
sudo apt install ufw
sudo ufw allow 2222/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status verbose
```

---

## STEP 16: iptables and nftables

### iptables:
```bash
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -s 192.168.10.100 -j DROP
```

### nftables:
```bash
sudo nft add table inet filter
sudo nft add chain inet filter input { type filter hook input priority 0 \; }
sudo nft add rule inet filter input ip saddr 192.168.10.100 drop
sudo nft add rule inet filter input tcp dport 22 accept
```

---

## STEP 17: Netplan Network Configuration

### DHCP:
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens18:
      dhcp4: true
      dhcp6: false
```

### Static IP:
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens18:
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
      dhcp4: false
```

### VLAN:
```yaml
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: false
  vlans:
    vlan100:
      id: 100
      link: ens18
      addresses:
        - 192.168.100.10/24
```

### Bridge:
```yaml
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: false
  bridges:
    br0:
      interfaces:
        - ens18
      addresses:
        - 192.168.1.100/24
      parameters:
        stp: false
```
```bash
sudo netplan apply
```

---

## Post-Installation Checklist

- [ ] System updated
- [ ] Hostname configured
- [ ] SSH port changed
- [ ] SSH key auth enabled
- [ ] Timezone set
- [ ] DNS configured
- [ ] Swap configured
- [ ] Kernel tuned
- [ ] Firewall enabled
- [ ] Network configured

---

## Security Best Practices
```bash
# Keep system updated
sudo apt update && sudo apt upgrade -y

# Install fail2ban
sudo apt install fail2ban

# Enable automatic security updates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Monitor logs
sudo tail -f /var/log/auth.log
sudo journalctl -f
```

---

## Quick Reference
```bash
# System
hostnamectl
uname -a

# Network
ip addr show
ip route show
ss -tulpn

# Services
systemctl status ssh
systemctl restart ssh

# Logs
journalctl -u ssh -f
tail -f /var/log/syslog

# Firewall
sudo ufw status
sudo iptables -L -n -v
sudo nft list ruleset
```

---

**Guide Version:** 1.0  
**Compatible:** Ubuntu 24.04 LTS  
**Last Updated:** December 2024

---

**End of Guide**


#### Install Ubuntu Server Minimized/Minimal without LVM and with ssh-server only ### v1.02-Jul-2025



apt update
apt full-upgrade -y

apt install qemu-guest-agent locales locales-all openssh-server vim htop net-tools ifupdown tmux wireguard mtr wget curl traceroute -y
apt install --install-recommends linux-generic-hwe-24.04 -y

vim /etc/default/grub

GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=
GRUB_TIMEOUT=20
GRUB_DISTRIBUTOR=`( . /etc/os-release; echo ${NAME:-Ubuntu} ) 2>/dev/null || echo Ubuntu`
GRUB_CMDLINE_LINUX_DEFAULT=""
GRUB_CMDLINE_LINUX="netcfg/do_not_use_netplan=true"

update-grub


vim /etc/network/interfaces

########### Legacy Network Configuration
auto lo
iface lo inet loopback
#

auto ens18
iface ens18 inet static    
    address 172.16.198.175/24
    gateway 172.16.198.1


{ Save+Exit }

apt autoremove -y --purge netplan.io resolvconf
rm -fr /etc/netplan


sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved.service
rm -fr /etc/resolv.conf
touch /etc/resolv.conf

echo "nameserver 9.9.9.9" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 1.0.0.3" >> /etc/resolv.conf

vim /etc/security/limits.conf
# add
root soft     nproc          1024000
root hard     nproc          1024000
root soft     nofile         1024000
root hard     nofile         1024000

# End of file

vim /etc/sysctl.conf

#add
net.ipv4.ip_forward=1
fs.file-max = 2097152
net.ipv4.tcp_max_orphans = 60000
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_max_syn_backlog = 100000
net.ipv4.tcp_congestion_control=bbr
net.core.default_qdisc=fq
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_synack_retries = 2 
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_fin_timeout = 15 
net.core.somaxconn = 100000
net.core.netdev_max_backlog = 100000
net.core.optmem_max = 25165824
net.ipv4.tcp_mem = 65536 131072 262144 
net.ipv4.udp_mem = 65536 131072 262144
net.core.rmem_default = 25165824
net.core.rmem_max = 25165824 
net.ipv4.tcp_rmem = 20480 12582912 25165824 
net.ipv4.udp_rmem_min = 16384
net.core.wmem_default = 25165824
net.core.wmem_max = 25165824
net.ipv4.tcp_wmem = 20480 12582912 25165824 
net.ipv4.udp_wmem_min = 16384
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_tw_reuse = 1 

### if you want to disable ipv6 network
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

# End of file

sudo swapoff /swap.img
sudo fallocate -l 8G /swap.img
sudo mkswap /swap.img
sudo swapon /swap.img


apt -y install locales locales-all

localectl set-locale LANG=en_US.UTF-8 LANGUAGE="en_US:en"
export LANG=en_US.UTF-8
cd /root/
echo  "LANG=en_US.UTF-8" >> .profile 
echo  "LANG=en_US.UTF-8" >> .bashrc
source .profile
source .bashrc

vim /etc/ssh/sshd_config
#Set
Port 8022
PermitRootLogin yes
UseDNS no

{ Save+Exit }

systemctl enable ssh
systemctl restart ssh
systemctl status ssh

netstat -tulpn

vim .ssh/authorized_keys 
rm -fr /etc/update-motd.d/*




systemctl disable systemd-networkd
systemctl stop systemd-networkd
systemctl status systemd-networkd

dpkg-reconfigure tzdata // Set Time Zone Asia/Dahaka

reboot


# Install FileBrowser
wget https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/addon/filebrowser-quantum.sh
bash filebrowser-quantum.sh 
cat /usr/local/community-scripts/fq-config.yaml 


# Install snmp-client
# Install ntp-client
# Configure wireguard-client
# Configure rsyslog-remote

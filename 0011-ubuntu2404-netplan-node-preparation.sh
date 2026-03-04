

#### Install Ubuntu Server Minimized/Minimal without LVM and with ssh-server only ### v1.03-Mar-2026


[-STEP#01-]

apt update
apt full-upgrade -y

apt install qemu-guest-agent locales locales-all openssh-server vim nano htop net-tools ifupdown tmux wireguard mtr wget curl traceroute frr -y
apt install --install-recommends linux-generic-hwe-24.04 -y


[-STEP#02-]

vim /etc/default/grub

GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=
GRUB_TIMEOUT=20
GRUB_DISTRIBUTOR=`( . /etc/os-release; echo ${NAME:-Ubuntu} ) 2>/dev/null || echo Ubuntu`
GRUB_CMDLINE_LINUX_DEFAULT=""
GRUB_CMDLINE_LINUX=""

update-grub


[-STEP#03-]

sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved.service
rm -fr /etc/resolv.conf
touch /etc/resolv.conf
echo "nameserver 9.9.9.9" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 1.0.0.3" >> /etc/resolv.conf


[-STEP#04-]

vim /etc/security/limits.conf
# add
root soft     nproc          1024000
root hard     nproc          1024000
root soft     nofile         1024000
root hard     nofile         1024000

# End of file

[-STEP#05-]

vim /etc/sysctl.d/sysctl.conf			||add the following lines||▼

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

### To disable IPv6 Option ############
### if you want to disable ipv6 network
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
#
vm.swappiness=75
vm.page-cluster=0

# End of file

chmod +x /etc/sysctl.d/sysctl.conf

rm -fr /etc/sysctl.conf
ln -s /etc/sysctl.d/sysctl.conf /etc/sysctl.conf


[-STEP#06-]

cat /etc/fstab  // check swap file name //

sudo swapoff /swap.img
sudo fallocate -l 8G /swap.img
sudo mkswap /swap.img
sudo swapon /swap.img

<OR>

sudo swapoff /swapfile
sudo fallocate -l 8G /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

#reload font cache after installing new font
fc-cache -fv

[-STEP#07-]

apt -y install locales locales-all
dpkg-reconfigure locales 					// select en_US.UTF-8 //
update-locale LANG=en_US.UTF-8 LANGUAGE="en_US:en"
export LANG=en_US.UTF-8

cd /root/
echo "export LANG=en_US.UTF-8" >> .profile
echo "export LANG=en_US.UTF-8" >> .bashrc


[-STEP#08-]
vim /etc/ssh/sshd_config
#Set
Port 8022
PermitRootLogin yes
UseDNS no

{ Save+Exit }

## For VM
systemctl enable ssh
systemctl restart ssh
systemctl status ssh

netstat -tulpn


[-STEP#09-]

vim .ssh/authorized_keys 
rm -fr /etc/update-motd.d/*


[-STEP#10-]


sudo apt update
sudo apt install -y chrony

sudo vim /etc/chrony/chrony.conf

server 172.23.47.91 iburst prefer
server bd.pool.ntp.org iburst prefer
server 0.asia.pool.ntp.org iburst

sudo systemctl restart chrony
chronyc makestep
sudo systemctl restart chrony

chronyc sources -v
chronyc tracking



[-STEP#11-]
dpkg-reconfigure tzdata // Set Time Zone Asia/Dahaka


[-STEP#12-]

"Network Modification with proper netplan file format" -- Important

/etc/netplan/00-installer-config.yaml 
# This is the network config written by 'subiquity'
#  version: 2
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: false
      dhcp6: false
      link-local: []  
      addresses:
      - 172.23.46.81/23
      optional: true
      routes:
        - to: default
          via: 172.23.47.254
      nameservers:
       addresses:
        - 8.8.8.8
        - 1.0.0.3
    ens19:
      dhcp4: false
      optional: true  
      addresses: []  
      dhcp6: false
      optional: true
      link-local: []      


netplan try
netplan apply

systemctl disable systemd-networkd
systemctl stop systemd-networkd
systemctl status systemd-networkd


[-STEP#13-]
# Fix APT Sources #
cat /etc/apt/sources.list.d/ubuntu.sources
Types: deb
URIs: https://mirrors.cloud.tencent.com/ubuntu/
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: http://security.ubuntu.com/ubuntu/
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# Alternative 
#deb https://mirrors.cicku.me/linuxmint/packages wilma main upstream import backport 
deb https://repo.extreme-ix.org/ubuntu noble main restricted universe multiverse
deb https://repo.extreme-ix.org/ubuntu noble-updates main restricted universe multiverse
deb https://repo.extreme-ix.org/ubuntu noble-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse


[-STEP#14-] { OPTIONAL } "NETWORK WITHOUT NETPLAN"

# option2-fix use classic interface file

sudo apt install ifupdown
sudo apt purge netplan.io
sudo ln -sf /dev/null /etc/systemd/system-generators/netplan

sudo vim /etc/network/interfaces

# loopback
auto lo
iface lo inet loopback

# ethernet -- modify as per your interface name
auto ens18
iface ens18 inet static
  address 192.168.1.100
  netmask 255.255.255.0
  gateway 192.168.1.1
  dns-nameservers 8.8.8.8 8.8.4.4

sudo systemctl restart networking
sudo /etc/init.d/networking restart

sudo rm -rf /usr/share/netplan /etc/netplan


[-STEP#15-] "if require"
# sudo without password
sudo visudo
# Add the following line at the end of the file
username ALL=(ALL) NOPASSWD:ALL

<OR>

sudo nano /etc/sudoers.d/nopasswd_reza
reza ALL=(ALL) NOPASSWD:ALL




[-STEP#16-] Install Docker "if requiare"

### Install Dcoker ----
apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
apt remove docker docker-engine docker.io containerd runc
apt update
apt install ca-certificates curl gnupg lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
systemctl enable --now docker



[-STEP#17-] Import old ssh keys 'if requiare'

chmod 700 .ssh/
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa


[-STEP#18-]

apt install frr
systemctl enable frr
systemctl restart frr

vtysh
> Configure route

[-STEP#19-]

vim /etc/hosts.allow
sshd : 127.0.0.1, 172.23.46.128/28, 172.23.77.128/28, 172.23.88.128/28, 172.23.47.54, 192.168.42.40, 192.168.21.132

vim /etc/hosts.deny
sshd : ALL






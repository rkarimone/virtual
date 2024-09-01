


### PROXMOX ZFS OVER iSCSI ###
  
  cat /etc/pve/storage.cfg
  cat /etc/iscsi/initiatorname.iscsi
  apt search freenas-proxmox              // Will not be found! //

  keyring_location=/usr/share/keyrings/ksatechnologies-truenas-proxmox-keyring.gpg
  curl -1sLf 'https://dl.cloudsmith.io/public/ksatechnologies/truenas-proxmox/gpg.284C106104A8CE6D.key' |  gpg --dearmor >> ${keyring_location}
  
  vim /etc/apt/sources.list.d/ksatechnologies-repo.list
  deb [signed-by=/usr/share/keyrings/ksatechnologies-truenas-proxmox-keyring.gpg] https://dl.cloudsmith.io/public/ksatechnologies/truenas-proxmox/deb/debian any-version main
  apt update
  apt search freenas-proxmox
  apt install freenas-proxmox
  apt full-upgrade

  systemctl restart freenas-proxmox
  /etc/init.d/open-iscsi restart
  
  mkdir /etc/pve/priv/zfs
  cp .ssh/id_rsa.pub /etc/pve/priv/zfs/172.23.88.200_id_rsa.pub     // 172.23.88.200 ip of TrueNAS Node //

  cp /root/.ssh/id_rsa /etc/pve/priv/zfs/172.23.88.200_id_rsa
  ssh-copy-id -i /etc/pve/priv/zfs/172.23.88.200_id_rsa.pub root@172.23.88.200
  ssh 'root@172.23.88.200'









### prxsrv03n88iscsi01


# https://github.com/TheGrandWazoo/freenas-proxmox/issues/44
# https://forum.proxmox.com/threads/proxmox-ve-and-zfs-over-iscsi-on-truenas-scale-my-steps-to-make-it-work.125387/
# https://github.com/TheGrandWazoo/freenas-proxmox#new-installs
# https://www.truenas.com/blog/iscsi-shares-on-truenas-freenas/
# https://www.youtube.com/watch?v=F-5rJqxFSrs
# https://www.truenas.com/docs/core/coretutorials/sharing/iscsi/addingiscsishare/#wizard-setup-process

# https://www.truenas.com/docs/core/uireference/sharing/iscsi/iscsishare/

# http://storagegaga.com/proxmox-storage-with-truenas-iscsi-volumes/

###########

apt-get install pve-zsync

pvesm zfsscan

zfs list -t snapshot
pve-zsync create --source 4001 --dest 192.168.105.22:vol1/backup --verbose --maxsnap 3  --name vm-4001
zfs list -t snapshot |grep 4001

pve-zsync create --source 4001 --dest 192.168.105.22:vol1/backup --verbose --maxsnap 3  --name vm-4001

vim /etc/cron.d/pve-zsync 

cd /etc/cron.d

cat pve-zsync 
root@prmoxnode4:/etc/cron.d# cat pve-zsync 
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

15 * * * * root pve-zsync sync --source 4001 --dest 192.168.105.22:sol1/ssd --name vm-4001 --maxsnap 10 --method ssh --source-user root --dest-user root
#*/15 * * * * root pve-zsync sync --source 4009 --dest 192.168.105.22:vol1/backup --name vm-4009 --maxsnap 10 --method ssh --source-user root --dest-user root


pve-zsync list
pve-zsync disable --source 192.168.105.24:4001 --name --name vm-4001
pve-zsync disable --source 192.168.105.24:4001 --name vm-4001

pve-zsync disable --source 4001 --name vm-4001
pve-zsync list

pve-zsync destroy --source 4001 --name vm-4001
pve-zsync list

zfs list -t snapshot |grep 4001
pve-zsync sync --source 4001 --dest 192.168.105.22:sol1/ssd --name vm-4001 --maxsnap 3 --method ssh --source-user root --dest-user root

zfs list -rt snapshot -o name |grep sol1/ssd/vm-4001-disk-0@ |sort |head -n -0 |xargs -n 1 zfs destroy -r
zfs list -t snapshot |grep 4001
  
pve-zsync create --source 4001 --dest 192.168.105.22:sol1/ssd --verbose --maxsnap 10  --name vm-4001
pve-zsync create --source 4001 --dest 192.168.105.22:sol1/ssd --verbose --maxsnap 10  --name vm-4001


zfs list -t snapshot |grep 4009
pve-zsync create --source 4009 --dest 192.168.105.22:vol1/backup --verbose --maxsnap 10 --name vm-4009 
zfs list -t snapshot |grep 4009

pve-zsync disable --source 4009 --name vm-4009
zfs list -t snapshot |grep 4001

systemctl status pveproxy
systemctl status corosync.service
systemctl status pveproxy

pveam status
pvecm status




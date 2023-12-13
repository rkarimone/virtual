


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


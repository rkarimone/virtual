

  471  fdisk -l
  472  ll /dev/disk/by-id/
  473  ls -lah /dev/disk/by-id/
  474  ls -lah /dev/disk/by-id/
  475  fdisk -l
  476  ls -lah /dev/disk/by-id/
  477  cat /etc/pve/storage.cfg
  478  cat /etc/iscsi/initiatorname.iscsi
  479  apt search freenas-proxmox
  480  keyring_location=/usr/share/keyrings/ksatechnologies-truenas-proxmox-keyring.gpg
  481  curl -1sLf 'https://dl.cloudsmith.io/public/ksatechnologies/truenas-proxmox/gpg.284C106104A8CE6D.key' |  gpg --dearmor >> ${keyring_location}
  482  vim /etc/apt/sources.list.d/ksatechnologies-repo.list
  483  apt update
  484  cat /etc/apt/sources.list
  485  vim /etc/apt/sources.list.d/ksatechnologies-repo.list
  486  apt update
  487  vim /etc/apt/sources.list.d/ksatechnologies-repo.list
  488  vim /etc/apt/sources.list.d/ksatechnologies-repo.list
  489  vim /etc/apt/sources.list.d/ksatechnologies-repo.list
  490  apt update
  491  apt search freenas-proxmox
  492  apt install freenas-proxmox
  493  apt full upgrade
  494  apt full-upgrade
  495  uptime
  496  date
  497  systemctl restart freenas-proxmox
  498  /etc/init.d/open-iscsi restart
  499  mkdir /etc/pve/priv/zfs
  500  ls -lah /etc/pve/priv/zfs
  501  ls
  502  ll
  503  ls -lah
  504  cp .ssh/id_rsa.pub /etc/pve/priv/zfs/
  505  cp .ssh/id_rsa.pub /etc/pve/priv/zfs/172.23.88.200_id_rsa.pub
  506  cd /etc/pve/priv/zfs/
  507  ls
  508  rm id_rsa.pub
  509  ls
  510  ll
  511  ssh-copy-id -i /etc/pve/priv/zfs/172.23.88.200_id_rsa.pub root@172.23.88.200
  512  cp /root/.ssh/id_rsa /etc/pve/priv/zfs/172.23.88.200_id_rsa
  513  ssh-copy-id -i /etc/pve/priv/zfs/172.23.88.200_id_rsa.pub root@172.23.88.200
  514  ssh 'root@172.23.88.200'
  515  cd
  516  history








### prxsrv03n88iscsi01


# https://github.com/TheGrandWazoo/freenas-proxmox/issues/44
# https://forum.proxmox.com/threads/proxmox-ve-and-zfs-over-iscsi-on-truenas-scale-my-steps-to-make-it-work.125387/
# https://github.com/TheGrandWazoo/freenas-proxmox#new-installs
# https://www.truenas.com/blog/iscsi-shares-on-truenas-freenas/
# https://www.youtube.com/watch?v=F-5rJqxFSrs
# https://www.truenas.com/docs/core/coretutorials/sharing/iscsi/addingiscsishare/#wizard-setup-process

# https://www.truenas.com/docs/core/uireference/sharing/iscsi/iscsishare/

# http://storagegaga.com/proxmox-storage-with-truenas-iscsi-volumes/



### ZFS ARCH MEMORY ###
Min 32GB Max 48GB 

echo "34359738368" >> /sys/module/zfs/parameters/zfs_arc_min
echo "51539607552" >> /sys/module/zfs/parameters/zfs_arc_max
		
vim /etc/modprobe.d/zfs.conf 
options zfs zfs_arc_min=34359738368		
options zfs zfs_arc_max=51539607552


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





$ sudo apt install pssh
vim hosts_list
root@172.16.198.62:22
root@172.16.198.63:22
root@172.16.198.64:22
root@172.16.198.65:22

parallel-ssh -i -h hosts_list "zpool status |grep state;"
parallel-ssh -H "root@172.16.198.62:22" -i "hostname"

rkarim@linux1981:~/pdsh$ parallel-ssh -H "root@172.16.198.62:22 root@172.16.198.63:22" -i "zpool status |grep error |grep -v scan"
[1] 23:53:35 [SUCCESS] root@172.16.198.62:22
errors: No known data errors
errors: No known data errors
errors: No known data errors
[2] 23:53:35 [SUCCESS] root@172.16.198.63:22
errors: No known data errors
errors: No known data errors
errors: No known data errors


parallel-ssh -i -h hosts "apt install aptitude -y;"
parallel-ssh -i -h hosts "aptitude install vim;"



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


#######



###############

root@prx-server-002:/etc/cron.d# 
qm list

VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID       
2011 iDRAC-OS-Center      stopped    8192             200.00 0         
2012 freepbx              stopped    8192             100.00 0         
2013 Bdcome-CallMaster    running    12288            300.00 955574    
2014 Bdcome-IPPBX         running    12288            300.00 970907    
3306 WorkStation-02-2141  running    8192             150.00 3767401   
8214 ABUZZ-CACTI          running    8192             100.00 15776 

############

VM (2013,2014) __replication__ from ---node:prx-server-002 (to) ---node:prx-server-001


root@prx-server-002:~# zfs list |grep 2013
sol1/vm-2013-disk-0       18.9G  2.82T  18.9G  -

zfs list -t snapshot |grep 2013
pve-zsync list
pve-zsync create --source 2013 --dest 172.23.88.128:sol1 --verbose --maxsnap 10  --name vm-2013


root@prx-server-001:~# zfs list |grep 2013
sol1/vm-2013-disk-0       18.9G  3.31T  18.9G  -


############
VM (3356) __replication__ from ---node:prx-server-003 (to) ---node:prx-server-002


root@prx-server-003:~# zfs list |grep 3356
sol1/vm-3356-disk-0      5.77G  3.38T  5.77G  -


zfs list -t snapshot |grep 3356
pve-zsync list
pve-zsync create --source 3356 --dest 172.23.88.129:sol1 --verbose --maxsnap 10  --name vm-3356



vim /etc/cron.d/pve-zsync     #### adjust crontab-schedule 



#####
pvecm status



################################################################################################
|| TRUE-NAST-CORE => NFS SERVICE CONFIGURATION  || 
################################################################################################


|| 01 ||   NAVIGATE → STORAGE → POOLS → ADD DATASET   ||||

[ Name ] 				      < tnas01-nfs4d01 >
[ Comments ] 			    < tnas01-nfs4d01 >
[ Sync ] 				      < Disabled >
[ Compression Level ]	< lz4 >
[ Enable Atime ]			< Off >
[ ZFS Deduplocation ]	< Off >


|| 02 ||   NAVIGATE → STORAGE → POOLS → EDIT PERMISSIONS (USE ACL)   ||||

[Select a preset ACL]
[ACL Options : RESTRICTED]
[ Path ] 				< /mnt/vol1/tnas01-nfs4d01 > 
[ User ] 				< nobody > 	[ Tick Apply User ]
[ Group ] 			< nogroup > 	[ Tick Aplly Group ]
[ Tick ] 				< Apply Permission Recursively >

( ALSO SET )+(ADD ACL ITEM)
[ Access Control List ]
Owner 		→ 	(Full Control)
Group 		→ 	(Full Control)
Everyone 	→ 	(Full Control)

|| 03 ||   NAVIGATE → SHARING → NFS → ADD (ALSO CLICK ADVANCED OPTIONS)   ||||

[ Path ] 				< /mnt/vol1/tnas01-nfs4d01 >
[ Tick ] 				< Quiet >
[ Tick ] 				< Enabled >

[ Maproot User ] 		      < nobody >
[ Maproot Group ] 		    < nogroup >
[ Authorized Networks ] 	< 172.23.77.0/24 172.23.88.0/24 >

|| 04 ||   NAVIGATE → SERVICES → NFS →   ||||

[ Number of Services ] 	< 32 >
[ Bind IP Addresses ] 	< 172.23.77.100, 172.23.88.100 >
[ Tick ] 				        < Enable NFSv4 >
[ Tick ] 				        < Allow non-root mount >


|| APPLY AND RESTART NFS SERVICE ||




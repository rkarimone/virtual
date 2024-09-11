

// PERIODIC REPLICATION AND SNAPSHOT TASK in PROXMOX CLUSTER with ZFS Backend //

SRC NODE: PRXSRV-04; 
DST NODE: PRXSRV-03; 

apt install pve-zsync 	// In both source and destination proxmox clustered nodes //

# { Replication Network 10g } #
SRC HOST-IP: 172.23.88.131	
DST HOST-IP: 172.23.88.130


root@prx-server-004:~# 
zfs list |grep 4004	// 4004 is PROXMOX VM ID //
Output >> sol1/vm-4004-disk-0  15.2G  3.31T  15.2G  -

root@prx-server-004:~# 
zfs list -t snapshot |grep 4004

root@prx-server-004:~# 
pve-zsync create --source 4004 --dest 172.23.88.130:sol1 --verbose --maxsnap 7  --name vm-4004

// NEW TO UPDATE CRON FILE //
root@prx-server-004:~# 
vim /etc/cron.d/pve-zsync

// FINAL CRONTAB ENTRY | MODIFY IT AS PER YOUR NEED AFTER INITIAL (1st) REPLICATION COMPLETE //
// Replicate Once a day (at 2:10 AM) and Keep Last 7 Snapshot (Here 7 days) //

root@prx-server-004:~# 
cat /etc/cron.d/pve-zsync 
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#
10 2 * * * root pve-zsync sync --source 4004 --dest 172.23.88.130:sol1 --name vm-4004 --maxsnap 7 --method ssh --source-user root --dest-user root



// VALIDATING BACK | CHECK BY RESTORING VM SNAPSHOT //

-> GOTO BACKUP LOCATION
root@prx-server-003:~# 
cd /var/lib/pve-zsync/

// CHECK/LIST ALL THE FILES //
root@prx-server-003:/var/lib/pve-zsync# ls -lah
3306.conf.qemu.rep_vm-3306_2024-09-09_16:14:01	3306.conf.qemu.rep_vm-3306_2024-09-11_04:14:01
3306.conf.qemu.rep_vm-3306_2024-09-09_20:14:01	3306.conf.qemu.rep_vm-3306_2024-09-11_08:14:01
3306.conf.qemu.rep_vm-3306_2024-09-10_00:14:01	3306.conf.qemu.rep_vm-3306_2024-09-11_12:14:01
3306.conf.qemu.rep_vm-3306_2024-09-10_04:14:01	4004.conf.qemu.rep_vm-4004_2024-09-11_11:45:57
3306.conf.qemu.rep_vm-3306_2024-09-10_08:14:01	4008.conf.qemu.rep_vm-4008_2024-09-11_11:58:39
3306.conf.qemu.rep_vm-3306_2024-09-10_12:14:02	4009.conf.qemu.rep_vm-4009_2024-09-11_12:25:56
3306.conf.qemu.rep_vm-3306_2024-09-10_16:14:01	cron_and_state.lock
3306.conf.qemu.rep_vm-3306_2024-09-10_20:14:01	sync.lock
3306.conf.qemu.rep_vm-3306_2024-09-11_00:14:01	sync_state

// COPY THE DESIRED FILE TO DEFERENT FOLDER //
root@prx-server-003:~# 
cp 3306.conf.qemu.rep_vm-3306_2024-09-11_12\:14\:01 /opt/

// GOTO THE FOLDER //
root@prx-server-003:~# 
cd /opt/

// CHECK THE CONFIGURATION FILE IF NEED TO CHANGE //
root@prx-server-003:~# 
vim 3306.conf.qemu.rep_vm-3306_2024-09-11_12\:14\:01 

// TO RUN THE VM, COPY THE CONFIGURATION FILE IN QEMU-SERVER FOLDER WITH A [ UNIQUE VM-ID ] //
root@prx-server-003:~# 
cp 3306.conf.qemu.rep_vm-3306_2024-09-11_12\:14\:01 /etc/pve/nodes/prx-server-003/qemu-server/3307.conf

// NOW CHECK THE VM FROM PROXMOX DASHBOARD //
{ Before Starting this VM Disconnect Network from Hardware Option of the VM from ProxMox WebUI }
 // Check by START/LOGIN/STOP //


// TO REMOVE THE TEST VM File //
rm /etc/pve/nodes/prx-server-003/qemu-server/3307.conf

~~~ Thank You ~~~
Ref-1: https://community.hetzner.com/tutorials/migrate-proxmox-to-new-server
Ref-2: https://www.servethehome.com/automating-proxmox-backups-with-pve-zsync
Ref-3: https://pve.proxmox.com/wiki/PVE-zsync
~~~ Thank You ~~~




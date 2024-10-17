

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





###############################################################################################
###############################################################################################

// PERIODIC REPLICATION AND SNAPSHOT TASK in PROXMOX CLUSTER with ZFS Backend //

SRC NODE: PRXSRV-01; 
DST NODE: PRXSRV-02; 

apt install pve-zsync 	// In both source and destination proxmox clustered nodes //

# { Replication Network 10g } #
SRC HOST-IP: 172.23.88.128	
DST HOST-IP: 172.23.88.129


root@prx-server-001:~# 
zfs list |grep 8052		// 8052 is PROXMOX CT ID //
zfs list -t snapshot |grep 8052


root@prx-server-001:~# 
11 */2 * * * root pve-zsync sync --source 8052 --dest 172.23.88.129:sol1 --name ct-8052 --maxsnap 24 --method ssh --source-user root --dest-user root

###############################################################################################




###############################################################################################
######## || PROXMOX BOOT DISK REPAIR || #######################################################
###############################################################################################

sgdisk --zap-all /dev/sda

>> Must copy the partition table >>


sgdisk /dev/sdb -R /dev/sda              > /dev/sda = destination disk or new disk    > /dev/sdb = source disk or existing/running disk
sgdisk -G /dev/sda
cfdisk /dev/sda
cfdisk /dev/sdb
lsblk

proxmox-boot-tool format /dev/sda2 --force
proxmox-boot-tool init /dev/sda2 --force

zpool replace rpool -f ata-WDC_WDS120G2G0A-00JH30_181738804394-part3 ata-WDC_WDS120G2G0A-00JH30_181742801635-part3 
 
 
ata-WDC_WDS120G2G0A-00JH30_181738804394-part3 = Error Disk
ata-WDC_WDS120G2G0A-00JH30_181742801635-part3 = New Disk


###############################################################################################

 
vim /usr/bin/zfs_arc_summery.sh
arc_summary | grep -E 'ARC size \(current\)|Min size \(hard limit\)|Max size \(high water\)|Anonymous metadata size'



## force delete-replication-task##
pvesr list
pvesr delete 105-0 --force

## Allow Unsupported SFP ##
- vi /etc/modprobe.d/ixgbe.conf
Add In...
options ixgbe allow_unsupported_sfp=1
- rmmod ixgbe; modprobe ixgbe

vim /etc/default/grub
Add In...
GRUB_CMDLINE_LINUX="ixgbe.allow_unsupported_sfp=1"
grub-mkconfig -o /boot/grub/grub.cfg
pve-efiboot-tool refresh
rmmod ixgbe && modprobe ixgbe

vim /etc/kernel/cmdline
Add In...
ixgbe.allow_unsupported_sfp=1

Finally, reboot the system and see that the interface comes up right.


---
root@pve:/# cat /opt/startup_script.sh 
#!/bin/bash
sleep 10
rmmod ixgbe && modprobe ixgbe
sleep 2
echo "4294967296" >> /sys/module/zfs/parameters/zfs_arc_max
sleep 3
ip link set ens4f0 up 
ip link set ens4f1 up
sleep 2
ip addr add 192.168.40.22/27 brd + dev ens4f1
ip addr add 192.168.50.22/27 brd + dev ens4f0

root@pve:/# cat /opt/startup_script_run.sh 
nohup /opt/startup_script.sh &

root@pve:/# cat /etc/network/interfaces
post-up /opt/startup_script_run.sh








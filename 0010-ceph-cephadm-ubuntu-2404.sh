
Here is the corrected and updated step-by-step guide that incorporates your specified networks.

Cluster Details:

Nodes: ceph-node1, ceph-node2, ceph-node3

Public Network: 172.23.46.0/23
Cluster Network: 172.23.88.0/24

Public IPs: 172.23.47.91, 172.23.47.92, 172.23.47.93
Cluster IPs: 172.23.88.91, 172.23.88.92, 172.23.88.93

Important Pre-requisites (PerfOrm on ALL 3 Nodes):

Physical Network Interfaces: Ensure each node has at least two network interfaces: one configured with a public IP and one with a cluster IP.

Set Hostnames:

'BASH' ||||||||||||||||||||||||||||||||||||||||

sudo hostnamectl set-hostname ceph-node1 # On ceph-node1
sudo hostnamectl set-hostname ceph-node2 # On ceph-node2
sudo hostnamectl set-hostname ceph-node3 # On ceph-node3

Configure /etc/hosts:
Add both public and cluster IP entries fOr all nodes on each node. This is crucial fOr hostname resolution.

'BASH' ||||||||||||||||||||||||||||||||||||||||

sudo vim /etc/hosts
# Add these lines:
172.23.47.91 ceph-node1
172.23.47.92 ceph-node2
172.23.47.93 ceph-node3
172.23.88.91 ceph-node1-cluster
172.23.88.92 ceph-node2-cluster
172.23.88.93 ceph-node3-cluster

'BASH' |||||||||||||||||||||||||||||||||||||||| NTP SERVER ||||


--- Server ---
sudo apt update
sudo apt install -y chrony


sudo vim /etc/chrony/chrony.conf

# server pool
server 103.144.200.42 iburst prefer

# Allow clients from the public and cluster networks to sync time
allow 172.23.47.0/23
allow 172.23.88.0/24

sudo systemctl restart chrony
chronyc makestep
sudo systemctl restart chrony

chronyc sources -v
chronyc tracking


--- Client ---



sudo apt update
sudo apt install -y chrony

sudo vim /etc/chrony/chrony.conf

server 172.23.47.91 iburst prefer

sudo systemctl restart chrony
chronyc makestep
sudo systemctl restart chrony

chronyc sources -v
chronyc tracking






Install Essential Packages:

'BASH' ||||||||||||||||||||||||||||||||||||||||

sudo apt update
sudo apt autoremove --purge docker.io
sudo apt install -y podman lvm2 cephadm


Enable SSH fOr cephadm:

Passwordless SSH: Ensure ceph-node1 (your bootstrap node) can SSH to ceph-node2 and ceph-node3 as root without a password.

On ceph-node1: ssh-keygen -t rsa -b 4096 (press enter fOr defaults).

On ceph-node1: ssh-copy-id root@ceph-node2

On ceph-node1: ssh-copy-id root@ceph-node3

Installation Steps (PerfOrm ONLY on ceph-node1)
1. Bootstrap the Cluster:
This command initializes the first monitor and manager, and sets up cephadm. We specify both the monitor IP and the cluster network here.

'BASH' ||||||||||||||||||||||||||||||||||||||||

sudo cephadm bootstrap --mon-ip 172.23.47.91 --cluster-network 172.23.88.0/24 --initial-dashboard-user admin --initial-dashboard-password "YourPassword"


--mon-ip: This must be the public IP of the bootstrap node.
--cluster-network: This tells Ceph which network to use fOr all internal replication and recovery traffic.


--OUTPUT--

             URL: https://ceph-node1:8443/
            User: admin
        Password: ***** --> new passwor *****

Enabling client.admin keyring and conf on hosts with "admin" label

Saving cluster configuration to /var/lib/ceph/41e46562-6ec7-11f0-aa07-bc2411ffe26f/config directory

You can access the Ceph CLI as following in case of multi-cluster or non-default config:

        sudo /usr/sbin/cephadm shell --fsid 41e46562-6ec7-11f0-aa07-bc2411ffe26f -c /etc/ceph/ceph.conf -k /etc/ceph/ceph.client.admin.keyring

Or, if you are only running a single cluster on this host:

        sudo /usr/sbin/cephadm shell 

Please consider enabling telemetry to help improve Ceph:

        ceph telemetry on

For more information see:

        https://docs.ceph.com/en/latest/mgr/telemetry/




--OUTPUT-- END


2. Check Cluster Health:
Wait a few minutes fOr the initial services to start.

'BASH' ||||||||||||||||||||||||||||||||||||||||

cephadm shell -- ceph orch apply osd --all-available-devices --unmanaged=true  // to setup 
cephadm shell -- ceph orch apply osd --all-available-devices    // to revert 
cephadm shell -- ceph orch ls --service_type=osd --export

Output-->
service_type: osd
service_id: all-available-devices
service_name: osd.all-available-devices
placement:
  host_pattern: '*'
unmanaged: true
spec:
  data_devices:
    all: true
  filter_logic: AND
  objectstore: bluestore









sudo cephadm shell -- ceph -s


You should see HEALTH_OK or HEALTH_WARN (which might be normal at this stage).

3. Add Remaining Hosts to the Cluster:
When adding hosts, you must specify both their public and cluster IP addresses.

'BASH' ||||||||||||||||||||||||||||||||||||||||


sudo cephadm install ceph-common
sudo ssh-copy-id -f -i /etc/ceph/ceph.pub root@ceph-node2
sudo ceph orch host ls

sudo cephadm shell -- ceph orch host add ceph-node2 --addr 172.23.47.92 --cluster-addr 172.23.88.92
sudo cephadm shell -- ceph orch host add ceph-node3 --addr 172.23.47.93 --cluster-addr 172.23.88.93

--addr: The public IP of the host.
--cluster-addr: The cluster IP of the host.

sudo ceph orch host ls

4. Verify Network Configuration:
cephadm will automatically update ceph.conf with the correct network settings.

'BASH' ||||||||||||||||||||||||||||||||||||||||

sudo cephadm shell -- cat /etc/ceph/ceph.conf

You should see:

Ini, TOML

[global]
    # ...
    public_network = 172.23.46.0/23
    cluster_network = 172.23.88.0/24
    # ...

5. Deploy Additional Monitors & Managers:
cephadm will automatically create the necessary services on the newly added hosts.

'BASH' ||||||||||||||||||||||||||||||||||||||||

sudo cephadm shell -- ceph orch apply mon all
sudo cephadm shell -- ceph orch apply mgr all

Verify: sudo cephadm shell -- ceph -s (should show 3 mons and 2 mgrs).

6. Deploy OSDs (Object Storage Daemons):
Use the drive_groups method to precisely control which devices become OSDs, ensuring you don mix SSDs and HDDs.

List devices to find their paths and types on each node:

'BASH' ||||||||||||||||||||||||||||||||||||||||

sudo cephadm shell -- ceph orch device ls

Create a YAML file (e.g., osd-spec.yaml) defining your OSDs fOr all nodes and apply it.

'BASH' ||||||||||||||||||||||||||||||||||||||||

# Example to apply all available devices (after careful verification)
sudo cephadm shell -- ceph orch apply osd --all-available-devices

This will create OSDs on all eligible devices on all hosts.

7. Access the Ceph Dashboard:

Open a web browser and navigate to https://172.23.47.91:8443.

Log in with admin and the password you set during bootstrap.

This revised guide provides the necessary steps to deploy a robust Ceph cluster with dedicated public and cluster networks. The use of --cluster-network in the bootstrap command and --cluster-addr during host addition is the key difference.



network:
  version: 2
  ethernets:
    enp6s18:
      addresses:
      - "172.23.47.91/23"
      dhcp6: false
      link-local: []
      routes:
      - to: "default"
        via: "172.23.47.237"
    enp6s19:
      addresses:
      - "172.23.88.91/24"
      nameservers:
        addresses:
        - 9.9.9.9
        - 1.1.1.1
      dhcp6: false
      link-local: []



cephadm shell -- ceph orch ls --service_type=osd --export

service_type: osd
service_id: all-available-devices
service_name: osd.all-available-devices
placement:
  host_pattern: '*'
unmanaged: true
spec:
  data_devices:
    all: true
  filter_logic: AND
  objectstore: bluestore
---
service_type: osd
service_id: dashboard-admin-1754051275801
service_name: osd.dashboard-admin-1754051275801
placement:
  host_pattern: ceph-node1
unmanaged: true
spec:
  data_devices:
    rotational: false
  filter_logic: AND
  objectstore: bluestore
---
service_type: osd
service_id: dashboard-admin-1754054694967
service_name: osd.dashboard-admin-1754054694967
placement:
  host_pattern: ceph-node2
unmanaged: true
spec:
  data_devices:
    rotational: false
  filter_logic: AND
  objectstore: bluestore
---
service_type: osd
service_id: dashboard-admin-1754054940124
service_name: osd.dashboard-admin-1754054940124
placement:
  host_pattern: ceph-node3
unmanaged: true
spec:
  data_devices:
    rotational: false
  filter_logic: AND
  objectstore: bluestore


--- have to run this part after adding single osd via dashboard in every node -- do not add other disks first, only add single disk first ----

sudo cephadm shell -- ceph orch ls --service_type=osd --export |grep dashboard-admin

Output -> 
service_id: dashboard-admin-1754051275801
service_name: osd.dashboard-admin-1754051275801
service_id: dashboard-admin-1754054694967
service_name: osd.dashboard-admin-1754054694967
service_id: dashboard-admin-1754054940124
service_name: osd.dashboard-admin-1754054940124


-- grab the dashboard-admin --- here those are

dashboard-admin-1754051275801 -For node 1
dashboard-admin-1754054694967 -For node 2
dashboard-admin-1754054940124 -For node 3



// Then create and import yaml file //

sudo vim osd-spec-node1.yaml

service_type: osd
service_id: dashboard-admin-1754051275801
service_name: osd.dashboard-admin-1754051275801
placement:
  host_pattern: ceph-node1
unmanaged: true     # <--- Add this line here
spec:
  data_devices:
    rotational: false
  filter_logic: AND
  objectstore: bluestore
  
// Then Run //
cat osd-spec-node1.yaml | cephadm shell -- ceph orch apply -i -


sudo vim osd-spec-node2.yaml

service_type: osd
service_id: dashboard-admin-1754054694967
service_name: osd.dashboard-admin-1754054694967
placement:
  host_pattern: ceph-node2
unmanaged: true     # <--- Add this line here
spec:
  data_devices:
    rotational: false
  filter_logic: AND
  objectstore: bluestore
  
// Then Run //
cat osd-spec-node2.yaml | cephadm shell -- ceph orch apply -i -



sudo vim osd-spec-node3.yaml

service_type: osd
service_id: dashboard-admin-1754054940124
service_name: osd.dashboard-admin-1754054940124
placement:
  host_pattern: ceph-node3
unmanaged: true     # <--- Add this line here
spec:
  data_devices:
    rotational: false
  filter_logic: AND
  objectstore: bluestore
  
// Then Run //
cat osd-spec-node3.yaml | cephadm shell -- ceph orch apply -i -

ceph orch ls |grep osd

OUTPUT ->
osd.all-available-devices                             0  -          68m   <unmanaged>  
osd.dashboard-admin-1754051275801                     2  2m ago     57m   <unmanaged>  
osd.dashboard-admin-1754054694967                     1  4m ago     56m   <unmanaged>  
osd.dashboard-admin-1754054940124                     2  41s ago    54m   <unmanaged>  
osd.dashboard-admin-1754062587505                     1  4m ago     113s  <unmanaged> 








cephadm shell -- ceph config get mon
cephadm shell -- ceph config get mon cluster_network
cephadm shell -- ceph config dump
cephadm shell -- ceph health detail


ceph osd tree
ceph osd df
ceph osd crush remove osd.<id>
ceph device ls	

ceph osd lspools	










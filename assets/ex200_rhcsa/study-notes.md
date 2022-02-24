# Red Hat Certified System Administrator (RHCSA) exam

Online version of the objectives for the EX200 exam can be found in this [link](https://www.redhat.com/en/services/training/ex200-red-hat-certified-system-administrator-rhcsa-exam?section=Objectives).

## Study points for the (EX200) exam

RHCSA exam candidates should be able to accomplish the tasks below without assistance. These have been grouped into several categories.

### Understand and use essential tools

- Access a shell prompt and issue commands with correct syntax

- **Use input-output redirection (>, >>, |, 2>, etc.)**
```shell
# (1) create new file
echo "this is a test" > /home/student/<file-name>

# (2) add content to an existing file
echo "this is a test" >> /home/student/<file-name>

# (3) add content to a new or existing file
cat << EOF | tee -a /home/student/<file-name>
this is a test
EOF

# (4) add content to a new or existing file
echo "this is a test" | tee -a /home/student/<file-name>

# (5) redirect stderr to stdout, and then both to a new/existing file
bash <script-name> 2>&1 | tee -a /home/student/<file-name>
```

- **Use grep and regular expressions to analyze text**
```shell
# print out content without comments
grep ^[^#] /etc/<file.conf>
```

- **Access remote systems using SSH**

1. Manual SSH configurations
```shell
# create ssh keypair
ssh-keygen -f .ssh/<key-name>

# copy pub key to remote server
ssh-copy-id -i <pub-key-name> <user>@<remote-server>

# access the remote server
ssh -i <priv-key-name> <user>@<remote-server>
```

2. Based on `ssh-agent` configurations
```shell
# start ssh-agent
eval $(ssh-agent)

# add key (with paraphrase) to ssh-agent
ssh-add .ssh/<key-name>   # enter the password now
```

> Note that the `eval` command started `ssh-agent and immediately load those variables in the same shell session to use them.

- Log in and switch users in multiuser targets
- Archive, compress, unpack, and uncompress files using tar, star, gzip, and bzip2
- Create and edit text files
- Create, delete, copy, and move files and directories
- Create hard and soft links
- List, set, and change standard ugo/rwx permissions
- Locate, read, and use system documentation including man, info, and files in /usr/share/doc

### Create simple shell scripts

- Conditionally execute code (use of: if, test, [], etc.)
- Use Looping constructs (for, etc.) to process file, command line input
- Process script inputs ($1, $2, etc.)
- Processing output of shell commands within a script
- Processing shell command exit codes

### Operate running systems

- Boot, reboot, and shut down a system normally
- Boot systems into different targets manually
- **Interrupt the boot process in order to gain access to a system**

1. Reset the root password 
```shell
# a) reboot the system (send Ctrl+Alt+Del).
# b) Interrupt the boot-loader by pressing any key (except Enter).
# c) Enter edit mode by pressing 'e'.
# d) Append rd.break to the line that starts with linux. This is to abort the boot process after the kernel mount all the filesystem and before it hands over control to systemd.
# e) Boot server using the current configuration by pressing Ctrl+x.
# f) Remount the /sysroot file system read/write
switch_root:/# mount -o remount,rw /sysroot
switch_root:/# chroot /sysroot

# g) Change the root password 
sh-4.4# passwd root

# h) Configure the system to automatically perform a full SELinux relabel after boot.
sh-4.4# touch /.autorelabel

# i) Continue the booting process by pressing exit twice.
```

- Identify CPU/memory intensive processes and kill processes
- Adjust process scheduling
- Manage tuning profiles
- Locate and interpret system log files and journals
- Preserve system journals
- Start, stop, and check the status of network services
- Securely transfer files between systems

### Configure local storage

- **List, create, delete partitions on MBR and GPT disks**

1. List block devices, disks, and partitions
```shell
# identify block devices, and disks
lsblk -fp

# list partitions (/dev/<disk-name> = block-device-name)
parted -s /dev/<disk-name> print
```

2. Create partitions
```shell
# create partitions
parted -s /dev/<disk-name> mklabel <gpt/msdos>
parted -s /dev/<disk-name> mkpart <primary/extended> <start>MiB <end>MiB

# register partition in the system
udevadm settle
```

3. Delete partitions
```shell
# delete partitions
parted -s /dev/<disk-name> rm <partition-number>
```

- **Create and remove physical volumes (PVs)**
```shell
# prepare physical device
parted -s /dev/<disk-name> mklabel <gpt/msdos>
parted -s /dev/<disk-name> mkpart <primary/extended> <start>MiB <end>MiB
parted -s /dev/<disk-name> set 1 lvm on

# create physical volume from a physical device
pvcreate /dev/<disk-name>1

# show physical volume status
pvdisplay /dev/<disk-name>1

# remove physical volume
pvremove /dev/<disk-name>1
```

- **Assign physical volumes to volume groups (VGs)**
```shell
# create volume group using one or more PVs
vgcreate <vg-name> /dev/<disk-name>1

# show volume group status
vgdisplay <vg-name>

# remove volume group
vgremove <vg-name>
```

- **Create and delete logical volumes (LVs)**
```shell
# create logical volume from a VG
lvcreate -n <lv-name> -L 700M <vg-name>

# show logical volume status
lvdisplay /dev/<vg-name>/<lv-name>

# create logical volume
lvremove /dev/<vg-name>/<lv-name>
```

- Configure systems to mount file systems at boot by universally unique ID (UUID) or label
- Add new partitions and logical volumes, and swap to a system non-destructively

### Create and configure file systems

- Create, mount, unmount, and use vfat, ext4, and xfs file systems
- **Mount and unmount network file systems using NFS**

1. Manually mount/unmount an NFS share
```shell
# create the mount point
mkdir -pv <mountpoint-directory>

# mount temporally the NFS <share-directory>
sudo mount -t nfs -o rw,sync serverb:<share-directory> <mountpoint-directory>

# unmount the NFS share
sudo umount <mountpoint-directory>

# (TIP!) check mount on system
mount | grep <mountpoint-directory>

# mount persistently the NFS share
echo "serverb:<share-directory>  <mountpoint-directory>  nfs  rw,soft  0 0" | sudo tee -a /etc/fstab
```

2. Configure `automount` for an NFS share
```shell
# install package
sudo dnf install autofs

# create the master map entry
cat << EOF | /etc/auto.master.d/<auto-name>.autofs
<share-directory> /etc/auto.<auto-name>   # (1) standard
/-                /etc/auto.direct        # (2) direct maps
EOF

# create the mapping files
cat << EOF | /etc/auto.<auto-name>
<mountpoint-directory>   -rw,sync   serverb:<share-directory>  # standard
/mnt/work                -rw,sync   serverb:/shares/work       # direct maps
*                        -rw,sync   serverb:/shares/&          # wildcard maps
EOF

# start and enable the autofs service
sudo systemctl enable --now autofs
```

> **Note:** In the `direct maps` example ^, the /mnt directory exists, and it is not managed by `autofs`. The full directory /mnt/work will be created and removed automatically by the `autofs` service.

- **Extend existing logical volumes**

1. Prepare the physical device and PV (if there's any already)
```shell
# prepare the physical device and PV
parted -s /dev/<disk-name> mklabel <gpt/msdos>
parted -s /dev/<disk-name> mkpart <primary/extended> <start>MiB <end>MiB
parted -s /dev/<disk-name> set 3 lvm on
```

2. Extend/reduce the VG
```shell
# extend the VG
vgcreate <vg-name> /dev/<disk-name>3

# move date from a PV (to available spaces in PVs of the same VG)
pvmove /dev/<disk-name>3

# remove the PV from the VG
vgreduce <vg-name> /dev/<disk-name>3
```

3. Extend/reduce the LG
```shell
# extend the LG
lvextend -L +300M /dev/<vg-name>/<lv-name>
```

- Create and configure set-GID directories for collaboration
- Configure disk compression
- **Manage layered storage**

1. Assembling Block Storage into Stratis Pools
```shell
# install stratis packages
sudo dnf install stratis-cli stratisd
sudo systemctl enable --now stratisd

# create pool of one or more block devices
stratis pool create <pool-name> /dev/vdb

# list pools
stratis pool list   # pools are subdirectories under /stratis directory

# add additional block devices to a pool
stratis pool add-data <pool-name> /dev/vdc

# view the block devices of a pool
stratis blockdev list <pool-name>
```

2. Managing Stratis File Systems
```shell
# create a file system from a pool
stratis filesystem create <pool-name> <file-system-name>   # xfs

# list of available file systems
stratis filesystem list
```

3. Mount persistently Stratis File Systems
```shell
lsblk -fp

cat /etc/fstab
UUID=<31b9363b-add8-4b46-a4bf-c199cd478c55> /dir1 xfs defaults,x-systemd.requires=stratisd.service 0 0
```

- Diagnose and correct file permission problems

### Deploy, configure, and maintain systems

- Schedule tasks using at and cron
- Start and stop services and configure services to start automatically at boot
- **Configure systems to boot into a specific target automatically**
```shell
# get default target
systemctl get-default

# set default target
systemctl set-default <target-name>  # TAB TAB

basic.target                multi-user.target
default.target              graphical.target
```

- Configure time service clients
- **Install and update software packages from Red Hat Network, a remote repository, or from the local file system**
```shell
# add remote repository
dnf config-manager --add-repo <repo-url-here>
dnf config-manager --add-repo <repo-url-here>

# check if a package is installed on the system
rpm -q <package-name>
```

- Work with package module streams
- Modify the system bootloader

### Manage basic networking

- Configure IPv4 and IPv6 addresses
- Configure hostname resolution
- Configure network services to start automatically at boot
- Restrict network access using firewall-cmd/firewall
- Configure a bridge over a bond interface
```shell
# 1) create bridge iface and connection
BRIDGE=baremetal
BRIDGE_STP=yes

IP_ADDR=10.5.190.36/26
IP_ROUTES="172.16.100/24 172.16.100.1,192.168.10.0/16 192.168.10.1"

nmcli con add ifname "${BRIDGE}" type bridge con-name "${BRIDGE}"
nmcli con modify "${BRIDGE}" ipv4.method manual ipv4.address "${IP_ADDR}" ipv4.routes "${IP_ROUTES}" ipv6.method ignore
nmcli con up "${BRIDGE}"

# 2) create bond iface and connection
BOND=bond0
BOND_CON="Bond bon0"
BOND_MODE="mode=802.3ad,downdelay=0,lacp_rate=fast,miimon=100,updelay=0,xmit_hash_policy=1"

BOND_SLAVE0=int0
BOND_SLAVE1=int2

nmcli con add type bond ifname "${BOND}" con-name "${BOND_CON}"
nmcli con modify "${BOND_CON}" bond.options mode="${BOND_MODE}"
nmcli con add type ethernet con-name "${BOND}-slave-${BOND_SLAVE0}" ifname "${BOND_SLAVE0}" master "${BOND}"
nmcli con add type ethernet con-name "${BOND}-slave-${BOND_SLAVE1}" ifname "${BOND_SLAVE1}" master "${BOND}"

nmcli con modify "${BOND_CON}" master "${BRIDGE}" slave-type bridge
nmcli con up "${BOND_CON}"
```

### Manage users and groups

- **Create, delete, and modify local user accounts**
```shell
# create user in one-liner
adduser <user-name> -m -p $(openssl passwd -1 <user-name>)

# delete user
userdel -r <user-name>
```

> When creating a user, the password needs to be encrypted with crypt(3) function, otherwise the system will consider it plain text to be stored on the `shadow` file.

- Change passwords and adjust password aging for local user accounts
- Create, delete, and modify local groups and group memberships
- Configure superuser access

### Manage security

- Configure firewall settings using firewall-cmd/firewalld
- Create and use file access control lists
- Configure key-based authentication for SSH

- **Set enforcing and permissive modes for SELinux**
```shell
# show current SELinux mode
getenforce

# change SELinux mode to permissive
setenforce 0

# change SELinux mode to enforcing
setenforce 1

# persistently change SELinux mode
grep ^SELINUX /etc/selinux/config
sed -i -e "s/=enforcing/=permissive/" /etc/selinux/config
```

- List and identify SELinux file and process context

- **Restore default file contexts**
```shell
restorecon -v <file-, folder-name>
```

- Use boolean settings to modify system SELinux settings
- Diagnose and address routine SELinux policy violations

### Manage containers

- Find and retrieve container images from a remote registry
- Inspect container images
- Perform container management using commands such as podman and skopeo
- Perform basic container management such as running, starting, stopping, and listing running containers
- Run a service inside a container

- **Configure a container to start automatically as a systemd service**

1. Start target container (e.g. command below)
```shell
podman run -d \
           --name <container-name> \
           -v /home/user/dbfiles:/var/lib/mysql:Z \
           -e MARIADB_ROOT_PASSWORD=dummy \
           docker.io/library/mariadb
```

2. Generate custom systemd unit file
```shell
# root user
cd /etc/systemd/system
podman generate systemd --name <container-name> --files --new

# non-root user
cd  ~/.config/systemd/user
podman generate systemd --name <container-name> --files --new
```

3. Reload unit files
```shell
# root user
systemctl daemon-reload

# non-root user
systemctl --user daemon-reload
```

4. Start/Stop target container
```shell
# root user
systemctl start/stop <unit-name>

# non-root user
systemctl --user start/stop <unit-name>
```

5. Enable target container
```shell
# root user
systemctl enable --now <unit-name>

# non-root user
systemctl --user enable --now <unit-name>
loginctl enable-linger
```

- Attach persistent storage to a container

> As with all Red Hat performance-based exams, configurations must persist after reboot without intervention.

# RHCx Training Box

This is the training lab I used during preparations for the RHCSA, and RHCE exams.


## System requirements

- [vagrant](https://www.vagrantup.com/docs/installation)
- [virtualbox](https://www.virtualbox.org/wiki/Downloads)


## Vagrant plugins required

After installing `vagrant` in your system, you may need the following plugins.

```
vagrant plugin install vagrant-registration vagrant-reload vagrant-vbguest
```


## Getting started

Once the system requirements are installed properly, you can bootstrap the whole virtual environment by executing the `vagrant up` command from the root directory of this folder.

1) Check current status of virtualized environment
```
rhcsa-student@laptop:~# vagrant status

Current machine states:

rhel-server               not created (virtualbox)

The environment has not yet been created. Run `vagrant up` to
create the environment. If a machine is not created, only the
default provider will be shown. So if a provider is not listed,
then the machine is not created for that environment.
```

2) Bootstrap training environment
```
rhcsa-student@laptop:~# vagrant up

Bringing machine 'rhel-server' up with 'virtualbox' provider...
==> rhel-server: Importing base box 'generic/rhel8'...
==> rhel-server: Matching MAC address for NAT networking...
==> rhel-server: Checking if box 'generic/rhel8' version '3.5.2' is up to date...
==> rhel-server: Setting the name of the VM: rhcx-training-box_rhel-server_1637423248521_48430
==> rhel-server: Fixed port collision for 22 => 2222. Now on port 2200.
==> rhel-server: Clearing any previously set network interfaces...
==> rhel-server: Preparing network interfaces based on configuration...
    rhel-server: Adapter 1: nat
==> rhel-server: Forwarding ports...
    rhel-server: 22 (guest) => 2200 (host) (adapter 1)
==> rhel-server: Running 'pre-boot' VM customizations...
==> rhel-server: Booting VM...
==> rhel-server: Waiting for machine to boot. This may take a few minutes...
    rhel-server: SSH address: 127.0.0.1:2200
    rhel-server: SSH username: vagrant
    rhel-server: SSH auth method: private key
==> rhel-server: Machine booted and ready!
==> rhel-server: Registering box with vagrant-registration...
    rhel-server: Would you like to register the system now (default: yes)? [y|n] 
    rhel-server: username: se-lochoa
    rhel-server: password: 
==> rhel-server: Registration successful.
==> rhel-server: Checking for guest additions in VM...
==> rhel-server: Setting hostname...
==> rhel-server: Installing rsync to the VM...
==> rhel-server: Rsyncing folder: /home/leo8a/Training/rhcx-training-box/ => /vagrant
```

> **Note:** You will be prompted to enter subscriptions details. Enter your credentials (optionally) if you want to, otherwise, once inside the box you may add those via the `subscription-manager`.

3) Suspend training machines
```
rhcsa-student@laptop:~# vagrant suspend

==> rhel-server: Saving VM state and suspending execution...
```

4) Destroy virtualized environment
```
cks-student@laptop:~# vagrant destroy -f

==> rhel-server: Discarding saved state of VM...
==> rhel-server: Destroying VM and associated drives...
```

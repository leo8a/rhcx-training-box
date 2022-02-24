# -*- mode: ruby -*-
# vi: set ft=ruby :

# Define the image box
IMAGE_NAME = "generic/rhel8"

# Second Disk location
CWD = File.dirname(File.expand_path(__FILE__))
secondDisk = "%s/%s" % [CWD, 'secondDisk.vdi']

# Vagrant provisioning
Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.vbguest.auto_update = false

  config.vm.network "private_network",
                ip: "192.168.56.25/24",
                auto_config: false                                  # private network 1
  config.vm.network "private_network",
                ip: "192.168.60.25/24",
                auto_config: false                                  # private network 2
  config.vm.network "forwarded_port",
                guest: 9090, host: 9090                             # cockpit-dashboard

  config.vm.provider "virtualbox" do |v|
    v.cpus = 2
    v.memory = 4096
    unless File.exist?(secondDisk)
      v.customize ['createhd', '--filename', secondDisk, \
                               '--variant', 'Fixed', \
                               '--size', 5 * 1024]
    end
    v.customize ['storageattach', :id, '--storagectl', 'IDE Controller', \
                                       '--medium', secondDisk, \
                                       '--port', 1, '--device', 0, '--type', 'hdd']
  end

  # 1) rhel-server setup
  config.vm.define "rhel-server" do |rhel|
    rhel.vm.box = IMAGE_NAME

    rhel.vm.hostname = "rhel.leo8a.io"
    rhel.hostmanager.manage_host = true

    rhel.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ['*.log', '*.vdi']
  end

  # 2) rhel-server bootstrap
  config.vm.provision "bootstrap", type: "shell", inline: <<-SHELL

    function update_system() {
    dnf -y update
    dnf -y upgrade
    }

    function config_bashrc() {
    grep -qxF '# podman aliases ' /root/.bashrc || echo -e "\n# podman aliases \nalias pd='podman'\nalias pds='podman ps'\nalias pdi='podman images'" | sudo tee -a /root/.bashrc
    }

    function get_tooling() {
    # GUI server management
    dnf -y install cockpit cockpit-dashboard

    # podman, skopeo, buildah
    dnf -y module install container-tools

    # ansible
    dnf config-manager --enable ansible-2-for-rhel-8-x86_64-rpms
    dnf -y install ansible
    }

    function config_user_student() {
    adduser student -m -p $(openssl passwd -1 student)
    }

    # bootstrapping workflow
    update_system
    get_tooling
    config_bashrc
    config_user_student

  SHELL
  config.vm.provision :reload

end

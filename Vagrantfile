# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"
  # config.vm.box = "ubuntu/xenial64"

  config.ssh.forward_agent = true

  config.vm.provider "virtualbox" do |node|
    node.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    node.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    node.cpus = "4"
    node.memory = "2048"
  end

  config.vm.hostname = 'new-ruby-project'
  config.vm.synced_folder '.', '/vagrant', nfs: true

  config.vm.network :private_network, ip: '10.10.10.99'
  config.vm.network "forwarded_port", guest: 2300, host: 12300
  # config.vm.network "forwarded_port", guest: 44300, host: 44300

  # Use a unique and explicit port to avoid collision with other boxes
  config.notify_forwarder.port = 23809
  config.notify_forwarder.enable = true
  config.notify_forwarder.run_as_root = false

  config.vm.provision "shell", path: "vm/bootstrap.sh", privileged: false
end

# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64" 
  config.vm.network "forwarded_port", guest: 3000, host: 8080

  config.vm.define "which_ride", primary: true do |which_ride|
    config.vm.provision :shell, path: "vagrant_setup.sh"
  end
end

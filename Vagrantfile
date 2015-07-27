# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.hostmanager.enable = true
  config.hostmanager.manage_host = true

  config.vm.define 'appserver' do |appserver|

    appserver.vm.box = "marghidanu/ubuntu-precise64"

    # appserver.librarian_puppet.puppetfile_dir = "puppet/librarian/appserver"
    # appserver.librarian_puppet.placeholder_filename = ".MYPLACEHOLDER"
    # appserver.librarian_puppet.use_v1_api  = '1'
    # appserver.librarian_puppet.destructive = false

    # appserver.vm.hostname = 'appserver'
    appserver.vm.network "forwarded_port", guest: 80, host: 3000
    appserver.vm.network "private_network", ip: "192.168.2.2"

    appserver.hostmanager.aliases = %w(appserver.local)

    appserver.vm.provision :puppet do |puppet|
      puppet.manifests_path = 'puppet/manifests'
      puppet.module_path = 'puppet/modules'
      puppet.manifest_file = 'appserver/init.pp'
    end
  end

  config.vm.provider "virtualbox" do |vb|
    host = RbConfig::CONFIG['host_os']

    # Give VM 1/4 system memory & access to all cpu cores on the host
    if host =~ /darwin/
      cpus = `sysctl -n hw.ncpu`.to_i
      # sysctl returns Bytes and we need to convert to MB
      mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4
    elsif host =~ /linux/
      cpus = `nproc`.to_i
      # meminfo shows KB and we need to convert to MB
      mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
    else # sorry Windows folks, I can't help you
      cpus = 2
      mem = 1024
    end

    vb.customize ["modifyvm", :id, "--memory", mem]
    vb.customize ["modifyvm", :id, "--cpus", cpus]
  end
end

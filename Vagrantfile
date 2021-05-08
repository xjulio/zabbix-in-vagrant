# -*- mode: ruby -*-
# vi: set ft=ruby :

# Require YAML module
require 'yaml'

# Read YAML file with box details
nodes = YAML.load_file('files/nodes.yaml')

Vagrant.configure(2) do |config|
 
  nodes.each do |node|
    config.vm.define node["name"] do |config|
      config.vm.box = node["box"]
      config.vm.hostname = node["name"]
      config.vm.network :private_network, ip: node["ip"]
 
      config.vm.provider :virtualbox do |vb|
        vb.name = node["name"]
        vb.memory = node["memory"]
      end
 
      config.vm.provision :shell, :path => node["bootstrap"]
    end
  end
end


# Zabbix Demo in Vagrant
Demo project x to create demo environment using Vagrant

# Requirements
* Virtualbox: https://www.virtualbox.org/wiki/Downloads
* Vagrant: https://www.vagrantup.com/downloads

# How to use
Clone repository:
```
https://github.com/xjulio/zabbix-in-vagrant.git
```

Go to project directory:
```
cd zabbix-in-vagrant
````

Adjust nodes configuration in:
```
files/nodes.yaml
```

Start ndoes
```
vagrant up
````

Finish Zabbix installation, acessing zabbix server from your machine, using default address or any other ip address defined in nodes.yaml

```
http://192.168.33.5/zabbix
```

During database setup input the zabbix database password `zabbixPW` or any other password defined in the bootstrap script

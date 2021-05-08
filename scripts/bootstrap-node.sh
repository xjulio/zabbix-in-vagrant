# Configure /etc/hosts file
echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "# Host config for zabbix and ndes" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "192.168.33.5    zabbix.local  zabbix" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "192.168.33.10   node01.local  node01" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "192.168.33.20   node02.local  node02" | sudo tee --append /etc/hosts 2> /dev/null

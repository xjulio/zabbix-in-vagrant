# Run on VM to bootstrap Zabbix server

# Variables
ZABBIX_PW=zabbixPW
ZABBIX_TZ=Europe/Dublin
 
# Configure /etc/hosts file
echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "# Host config for zabbix and ndes" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "192.168.33.5    zabbix.local  zabbix" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "192.168.33.10   node01.local  node01" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "192.168.33.20   node02.local  node02" | sudo tee --append /etc/hosts 2> /dev/null

# Install Zabbix repository
rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
yum clean all

# Install Zabbix server and agent
yum install zabbix-server-mysql zabbix-agent -y

# Install Zabbix frontend
yum install centos-release-scl -y

# Enable zabbix-frontend repository
sed -i 's/^enabled=.*/enabled=1/g' /etc/yum.repos.d/zabbix.repo

# Install Zabbix frontend packages
yum install zabbix-web-mysql-scl zabbix-apache-conf-scl -y

# Install DB server
yum install mariadb-server -y

# Enable and Start DB service
systemctl enable mariadb.service 
systemctl start mariadb.service

# Create databases
mysql -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -e "create user zabbix@localhost identified by '$ZABBIX_PW';"
mysql -e "grant all privileges on zabbix.* to zabbix@localhost;"


# Import zabbix schema
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql zabbix

# Configure the database for Zabbix server
sed -i "s|.*DBPassword=.*|DBPassword=${ZABBIX_PW}|g" /etc/zabbix/zabbix_server.conf

# Configure Zabbix TZ 
sed -i "s|.*php_value\[date\.timezone\].*|php_value\[date\.timezone\] = ${ZABBIX_TZ}|g" /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf

# Start Zabbix server and agent processes
systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm
systemctl enable zabbix-server zabbix-agent httpd rh-php72-php-fpm

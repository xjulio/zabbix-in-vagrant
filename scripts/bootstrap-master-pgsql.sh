# Run on VM to bootstrap Zabbix server

# Variables
ZABBIX_PW=zabbixPW
ZABBIX_TZ=Europe/Dublin

# Change to /tmp DIR to avoid sudo issues
cd /tmp
 
# Configure /etc/hosts file
echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "# Host config for zabbix and ndes" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "127.0.0.1       localhost     localhost" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "192.168.33.5    zabbix.local  zabbix" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "192.168.33.10   node01.local  node01" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "192.168.33.20   node02.local  node02" | sudo tee --append /etc/hosts 2> /dev/null

# Disabling SE Linux - DO NOT PERFORME THIS IN PRODUCTION
sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux
setenforce 0

# Install utils
yum install -y traceroute net-snmp net-snmp-utils wget curl tcpdump nmap net-tools epel-release

# Install Zabbix repository
rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
yum clean all

# Install Zabbix server and agent
yum install zabbix-server-pgsql zabbix-agent -y

# Install Zabbix frontend
yum install centos-release-scl -y

# Enable zabbix-frontend repository
sed -i 's/^enabled=.*/enabled=1/g' /etc/yum.repos.d/zabbix.repo

# Install Zabbix frontend packages
yum install zabbix-web-pgsql-scl zabbix-apache-conf-scl -y

# Install PG server
yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum install postgresql13-server -y

# Init DB
/usr/pgsql-13/bin/postgresql-13-setup initdb

# Enable and Start PG service
systemctl enable postgresql-13.service
systemctl start postgresql-13.service

# Create zabbix database
sudo -u postgres createuser zabbix
sudo -u postgres psql -c "alter user zabbix with encrypted password '$ZABBIX_PW';"
sudo -u postgres createdb -O zabbix zabbix

# Configuring zabbix DB connection
echo "host    zabbix          zabbix          127.0.0.1/32            scram-sha-256">>/var/lib/pgsql/13/data/pg_hba.conf
systemctl restart postgresql-13.service

# Import zabbix schema
zcat /usr/share/doc/zabbix-server-pgsql*/create.sql.gz | sudo -u zabbix psql zabbix

# Configure the database for Zabbix server
sed -i "s|.*DBPassword=.*|DBPassword=${ZABBIX_PW}|g" /etc/zabbix/zabbix_server.conf

# Configure Zabbix TZ 
sed -i "s|.*php_value\[date\.timezone\].*|php_value\[date\.timezone\] = ${ZABBIX_TZ}|g" /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf

# Start Zabbix server and agent processes
systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm
systemctl enable zabbix-server zabbix-agent httpd rh-php72-php-fpm

vagrant-precise32-apache-mysql-php
==================================

Vagrant precise32 (Ubuntu) with Apache, Mysql and Php

<b>Vagrantfile</b>
```shell 
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"
  
  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.network :forwarded_port, host: 8080, guest: 80
  config.vm.network :forwarded_port, guest: 3306, host: 3307
end


# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

```

<b>bootstrap.sh</b>
```shell 
#!/usr/bin/env bash

apt-get update
apt-get install -y apache2
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant/httpdocs /var/www
fi

#install MYSQLSERVER
debconf-set-selections <<< 'mysql-server mysql-server/root_password password Admin123'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password Admin123'
apt-get install -y mysql-server
if [ ! -f /var/log/databasesetup ];
then
    echo "CREATE USER 'my_user'@'%' IDENTIFIED BY 'my_user_pass'" | mysql -uroot -pAdmin123
    echo "CREATE DATABASE my_database" | mysql -uroot -pAdmin123
    echo "GRANT ALL ON my_database.* TO 'my_user'@'%'" | mysql -uroot -pAdmin123
    echo "flush privileges" | mysql -uroot -pAdmin123

    touch /var/log/databasesetup

    if [ -f /vagrant/bbdd.sql ];
    then
        mysql -uroot -pAdmin123 my_database < /vagrant/bbdd.sql
    fi
fi


# install PHP5
sudo apt-get install php5 libapache2-mod-php5 php5-mysql -y
 
# Restart Apache:
sudo /etc/init.d/apache2 restart

```

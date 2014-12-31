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

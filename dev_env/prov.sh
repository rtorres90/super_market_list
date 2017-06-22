#!/usr/bin/env bash

sudo apt-get update

sudo apt-get -o Dpkg::Options::="--force-confnew" -y install python-pip
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install python-virtualenv
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install python-dev
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install libffi-dev
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install libssl-dev
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install libmysqlclient-dev
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install supervisor

# Installing mysql
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password dev_env'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password dev_env'
sudo apt-get -y install mysql-server
mysql -uroot -pdev_env -e "create database dev"

sudo apt-get upgrade

sudo pip install --upgrade pip

sudo pip install -r /var/www/awesomemarketlist/requeriments.txt

cat > /etc/supervisor/conf.d/webapp.conf << EOL

[program:reports-server]
command = gunicorn awesomemarketlist.wsgi:application --bind 0.0.0.0:8001
directory = /var/www/awesomemarketlist/awesomemarketlist/
user = vagrant
autostart=true
environment=C_FORCE_ROOT=1,PYTHONPATH=/usr/local/src/
stderr_logfile=/var/log/webapp.err.log
stdout_logfile=/var/log/webapp.out.log

EOL

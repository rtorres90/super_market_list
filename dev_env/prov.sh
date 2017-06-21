#!/usr/bin/env bash

sudo apt-get update

sudo apt-get -o Dpkg::Options::="--force-confnew" -y install python-pip
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install python-virtualenv
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install libffi-dev
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install libssl-dev
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install libapache2-mod-wsgi
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install apache2

# Installing mysql
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password dev_env'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password dev_env'
sudo apt-get -y install mysql-server
mysql -uroot -pdev_env -e "create database dev"

sudo apt-get upgrade

sudo pip install --upgrade pip
sudo pip install django

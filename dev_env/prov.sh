#!/usr/bin/env bash

#Project variables
PROJECT_NAME="awesomemarketlist"
HOME_PATH="/home/vagrant"
PROJECT_PATH="$HOME_PATH/$PROJECT_NAME"
VIRTUALENV_NAME="env"
VIRTUALENV_PATH="$HOME_PATH/$VIRTUALENV_NAME"
TEMPLATES_PATH="$HOME_PATH/templates"

#Database variables
DATABASE_NAME="dev"
DATABASE_USER="root"
DATABASE_PASS="dev_env"

#Installing dependencies.
sudo apt-get update
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install python-pip
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install python-virtualenv
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install python-dev
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install libffi-dev
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install libssl-dev
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install libmysqlclient-dev
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install supervisor
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install apache2
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install libapache2-mod-wsgi

# Installing mysql
PASS_PASSWORD="mysql-server mysql-server/root_password password $DATABASE_PASS"
CONFIRM_PASSWORD="mysql-server mysql-server/root_password_again password $DATABASE_PASS"

sudo debconf-set-selections <<< $PASS_PASSWORD
sudo debconf-set-selections <<< $CONFIRM_PASSWORD
sudo apt-get -y install mysql-server
sudo service mysql start
mysql -u$DATABASE_USER -p$DATABASE_PASS -e "create database $DATABASE_NAME"

sudo apt-get upgrade

sudo pip install --upgrade pip

#Installing requirements on virtual env
sudo pip install virtualenv
virtualenv -p python2.7 env
$VIRTUALENV_PATH/bin/pip install -r $PROJECT_PATH/requeriments.txt

#Creating configuration file for database.
sudo rm $PROJECT_PATH/db.cnf
sudo sed -e "s/\${DATABASE_NAME}/$DATABASE_NAME/" -e "s/\${DATABASE_USER}/$DATABASE_USER/" -e "s/\${DATABASE_PASS}/$DATABASE_PASS/" $TEMPLATES_PATH/db_configurations.txt > $PROJECT_PATH/db.cnf

#Migrate changes into new db.
$VIRTUALENV_PATH/bin/python $PROJECT_PATH/manage.py migrate
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'supersecretpass')" | $VIRTUALENV_PATH/bin/python $PROJECT_PATH/manage.py shell


sudo service apache2 stop

#Making sure that the symblinks are created for wsgi
ln -s /etc/apache2/mods-available/wsgi.conf /etc/apache2/mods-enabled/wsgi.conf
ln -s /etc/apache2/mods-available/wsgi.load /etc/apache2/mods-enabled/wsgi.load

#Creating virtualhost for apacha2
sudo rm /etc/apache2/sites-available/000-default.conf

PROJECT_PATH="${PROJECT_PATH//\//\\/}"
VIRTUALENV_PATH="${VIRTUALENV_PATH//\//\\/}"

sudo sed -e "s/\${PROJECT_PATH}/$PROJECT_PATH/" -e "s/\${PROJECT_NAME}/$PROJECT_NAME/" -e "s/\${VIRTUALENV_PATH}/$VIRTUALENV_PATH/" $TEMPLATES_PATH/apache_virtualhost.txt > /etc/apache2/sites-available/000-default.conf

sudo service apache2 restart

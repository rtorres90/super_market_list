#!/usr/bin/env bash

PROJECT_NAME="awesomemarketlist"
PROJECT_PATH="/home/vagrant/$PROJECT_NAME"
VIRTUALENV_PATH="/home/vagrant/env"

DATABASE_NAME="dev"
DATABASE_USER="root"
DATABASE_PASS="dev_env"

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
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password $DATABASE_PASS'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $DATABASE_PASS'
sudo apt-get -y install mysql-server
mysql -u$DATABASE_USER -p$DATABASE_PASS -e "create database $DATABASE_NAME"

sudo apt-get upgrade

sudo pip install --upgrade pip

sudo pip install virtualenv
virtualenv -p python2.7 env
$VIRTUALENV_PATH/bin/pip install -r $PROJECT_PATH/requeriments.txt

cat > $PROJECT_PATH/db.cnf<< EOL

[client]
database = $DATABASE_NAME
user = $DATABASE_USER
password = $DATABASE_PASS
default-character-set = utf8

EOL

$VIRTUALENV_PATH/bin/python $PROJECT_PATH/manage.py migrate
$VIRTUALENV_PATH/bin/python $PROJECT_PATH/manage.py collectstatic
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'supersecretpass')" | $VIRTUALENV_PATH/bin/python $PROJECT_PATH/manage.py shell


sudo service apache2 stop

ln -s /etc/apache2/mods-available/wsgi.conf /etc/apache2/mods-enabled/wsgi.conf
ln -s /etc/apache2/mods-available/wsgi.load /etc/apache2/mods-enabled/wsgi.load

cat > /etc/apache2/sites-available/000-default.conf<< EOL

<VirtualHost *:80>
    Alias /static $PROJECT_PATH/static
    ErrorLog /home/vagrant/apache_errors.log
    <Directory $PROJECT_PATH/static>
        Require all granted
    </Directory>

    <Directory $PROJECT_PATH/$PROJECT_NAME>
        <Files wsgi.py>
            Require all granted
        </Files>
    </Directory>

    WSGIDaemonProcess $PROJECT_NAME python-path=$PROJECT_PATH python-home=$VIRTUALENV_PATH
    WSGIProcessGroup $PROJECT_NAME
    WSGIScriptAlias / $PROJECT_PATH/$PROJECT_NAME/wsgi.py
</VirtualHost>

EOL

sudo service apache2 restart

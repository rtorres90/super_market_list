#!/usr/bin/env bash

sudo apt-get update

sudo apt-get -o Dpkg::Options::="--force-confnew" -y install python-pip
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install python-virtualenv
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install python-dev
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install libffi-dev
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install libssl-dev
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install libmysqlclient-dev
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install supervisor
sudo apt-get -o Dpkg::Options::="--force-confnew" -y install nginx

# Installing mysql
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password dev_env'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password dev_env'
sudo apt-get -y install mysql-server
mysql -uroot -pdev_env -e "create database dev"

sudo apt-get upgrade

sudo pip install --upgrade pip

sudo pip install virtualenv
virtualenv -p python2.7 env

/home/vagrant/env/bin/pip install -r /var/www/awesomemarketlist/requeriments.txt

sudo touch /var/log/gunicorn_supervisor.log

NAME="web_app"                                   # Name of the application
DJANGODIR=/var/www/awesomemarketlist/awesomemarketlist              # Django project directory
SOCKFILE=/home/vagrant/env/run/gunicorn.sock  # we will communicte using this unix socket
NUM_WORKERS=3                                       # how many worker processes should Gunicorn spawn
DJANGO_SETTINGS_MODULE=awesomemarketlist.settings      # which settings file should Django use
DJANGO_WSGI_MODULE=awesomemarketlist.wsgi              # WSGI module name

cat > /etc/gunicorn_start.sh << EOL
#!/bin/bash
echo "Starting $NAME as `whoami`"

# Activate the virtual environment

cd $DJANGODIR
source /home/vagrant/env/bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH

# Create the run directory if it doesn't exist

RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)

exec gunicorn ${DJANGO_WSGI_MODULE}:application \
  --name $NAME \
  --workers $NUM_WORKERS \
  --bind=unix:$SOCKFILE \
  --log-level=debug \
  --log-file=-
EOL

sudo chmod +x /etc/gunicorn_start.sh

cat > /etc/supervisor/conf.d/webapp.conf << EOL

[program:web_app]
command = /etc/gunicorn_start.sh                                ; Command to start app
user = vagrant                                                   ; User to run as
stdout_logfile = /var/log/gunicorn_supervisor.log      ; Where to write log messages
redirect_stderr = true                                          ; Save stderr in the same log
environment=LANG=en_US.UTF-8,LC_ALL=en_US.UTF-8                 ; Set UTF-8 as default encoding

EOL

cat > /etc/nginx/sites-available/sample_project.conf << EOL
upstream base_django_server {
	server unix:/tmp/base_django.sock fail_timeout=0;
}


server {
    listen 80;
    server_name 192.168.68.8;

    client_max_body_size 4G;
    access_log /var/log/nginx-access.log;
    error_log /var/log/nginx-error.log;

    location /static/ {
        alias   /home/vagrant/static/;
    }

    location /media/ {
        alias   /home/vagrant/media/;
    }

    location / {
        satisfy any;
        if (!-f $request_filename) {
            proxy_pass http://sample_project_server;
            break;
        }
    }

    # Error pages
    error_page 500 502 503 504 /500.html;
    location = /500.html {
        root /home/vagrant/static/;
    }
}
EOL

sudo ln -s /etc/nginx/sites-available/sample_project.conf /etc/nginx/sites-enabled/sample_project.conf

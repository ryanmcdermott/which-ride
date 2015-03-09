#!/usr/bin/env bash
sudo apt-get update
sudo apt-get install libpq-dev -y
sudo apt-get install postgresql-9.3 -y
sudo -u postgres bash -c "psql -c \"CREATE USER dev WITH PASSWORD 'password';\""
sudo -u postgres bash -c "psql -c \"CREATE DATABASE which_ride;\""
sudo -u postgres bash -c "psql -c \"CREATE DATABASE which_ride_test;\""
sudo -u postgres bash -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE which_ride to dev;\""
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
sed -i '1i source /home/vagrant/.rvm/scripts/rvm' .bashrc
cd /vagrant
source /usr/local/rvm/scripts/rvm
rvm install 2.1.5
rvm gemset create which-ride
rvm gemset use which-ride
sudo apt-get install -y nodejs
sudo apt-get install xdotool -y
cd ~
sudo apt-get install libcurl3 libcurl3-gnutls libcurl4-openssl-dev -y
gem install rails --no-document
wget http://download.redis.io/releases/redis-2.8.19.tar.gz
tar xzf redis-2.8.19.tar.gz
cd redis-2.8.19
cd src
sudo make install
cd ../utils
xdotool type "Return Return Return Return Return Return" | sudo ./install_server.sh 
cd /vagrant
bundle install
rake fares:lyft
rails s

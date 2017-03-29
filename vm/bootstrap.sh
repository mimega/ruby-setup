#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y git
sudo apt-get install -y libssl-dev libreadline-dev zlib1g-dev # needed by ruby
sudo apt-get install -y libpq-dev # for pg gem


echo "=============== Postgres stuff begin =============="

DISTRIB_CODENAME=$(awk -F= '/DISTRIB_CODENAME=/{print $2}' /etc/lsb-release)
POSTGRES_VERSION=9.3

echo "Adding Postgres repository"
wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ $DISTRIB_CODENAME-pgdg main"
sudo apt-get update

echo "Installing Postgresql server and Client"
sudo apt-get install -y "postgresql-$POSTGRES_VERSION" "postgresql-contrib-$POSTGRES_VERSION"

echo "Installing Postgresql Host Based authentication file"
sudo cp /vagrant/vm/config/postgres-$POSTGRES_VERSION/pg_hba.conf "/etc/postgresql/$POSTGRES_VERSION/main/pg_hba.conf"
sudo chown postgres:postgres "/etc/postgresql/$POSTGRES_VERSION/main/pg_hba.conf"

echo "Installing Postgresql Configuration file"
sudo cp /vagrant/vm/config/postgres-$POSTGRES_VERSION/postgresql.conf "/etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf"
sudo chown postgres:postgres "/etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf"

echo "Configure Postgresql to start at boot"
sudo update-rc.d postgresql enable

echo "Restaring Postgresql"
sudo /etc/init.d/postgresql restart

echo "Waiting for Postgresql to restart"
sleep 3

echo "Create vagrant role for Postgresql"
sudo su postgres -c 'createuser -s -d vagrant'

echo "=============== Postgres stuff end ================"





echo "=============== Ruby stuff begin =================="

RBENV_VERSION=v1.1.0 # https://github.com/rbenv/rbenv/releases
RUBY_BUILD_VERSION=v20170201 # https://github.com/rbenv/ruby-build/releases
RUBY_VERSION=2.4.0 # https://www.ruby-lang.org/en/downloads/releases/
BUNDLER_VERSION=1.14.6 # https://rubygems.org/gems/bundler

echo "Installing rbenv $RBENV_VERSION"
VAGRANT_HOME="/home/vagrant"

git clone --branch $RBENV_VERSION git://github.com/sstephenson/rbenv.git $VAGRANT_HOME/.rbenv

echo "Installing ruby-build $RUBY_BUILD_VERSION"
git clone --branch $RUBY_BUILD_VERSION git://github.com/sstephenson/ruby-build.git $VAGRANT_HOME/.rbenv/plugins/ruby-build

echo "Installing ruby $RUBY_VERSION"
$VAGRANT_HOME/.rbenv/bin/rbenv install $RUBY_VERSION
$VAGRANT_HOME/.rbenv/bin/rbenv global $RUBY_VERSION
$VAGRANT_HOME/.rbenv/shims/gem install bundler -v $BUNDLER_VERSION
$VAGRANT_HOME/.rbenv/bin/rbenv rehash

echo "Add more PATH to bashrc"
echo 'export PATH="/vagrant/bin:$PATH"' | cat - $VAGRANT_HOME/.bashrc > temp && mv temp $VAGRANT_HOME/.bashrc
echo 'eval "$(rbenv init -)"' | cat - $VAGRANT_HOME/.bashrc > temp && mv temp $VAGRANT_HOME/.bashrc
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' | cat - $VAGRANT_HOME/.bashrc > temp && mv temp $VAGRANT_HOME/.bashrc
sudo chown vagrant:vagrant $VAGRANT_HOME/.bashrc

#!/bin/bash

#INSTALAR MARIADB
#Ejemplo en Arch: pacman -S mariadb

#Activar MySQL
#Ejemplo en Arch:
#systemctl start mysqld.service
#systemctl enable mysqld.service

#Configurar MySQL
#mysql_secure_installation
mysql_upgrade -u root -p
echo "CREATE USER monopoly@localhost IDENTIFIED BY 'monopoly';
CREATE DATABASE Monopoly
GRANT ALL PRIVILEGES ON Monopoly.* TO monopoly@localhost WITH GRANT OPTION
GRANT SUPER ON *.* TO monopoly@'localhost' IDENTIFIED BY 'monopoly';" > tmp.sql
mysql -u root -p < tmp.sql
rm tmp.sql

#INSTALAR RUBY
#Ejemplo en Arch: sudo pacman -S ruby
PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"
gem install mysql
gem update
gem install ruby
mysql -u root -p
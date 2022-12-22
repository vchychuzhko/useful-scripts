#!/bin/sh
# sudo access will be requested if the script was not run with sudo or under root user
sudo -k

# Read root password
if ! [ $(sudo id -u) = 0 ]; then
    echo "\033[31;1m"
    echo "Root password was not entered correctly!"
    exit 1;
fi

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y

    printf "\n>>> Creating files and folders... >>>\n"
# Creating working folders
mkdir -p ~/misc/apps ~/misc/ssl ~/misc/db

# Adding context option to create "Untitled Document"
mkdir -p ~/Templates
touch ~/Templates/Untitled\ Document

# Install cUrl
    printf "\n>>> cUrl is going to be installed >>>\n"
sudo apt-get install curl -y

    printf "\n>>> Adding repositories and updating software list >>>\n"
# Various PHP versions
sudo add-apt-repository ppa:ondrej/php -y

# Telegram repo
sudo add-apt-repository ppa:atareao/telegram -y

# Node
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# ElasticSearch 7
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg
echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

    printf "\n>>> Running Ubuntu upgrade >>>\n"
sudo apt-get update
sudo apt-get upgrade -y

# ifconfig since 18.04
sudo apt-get install net-tools -y

# Install Docker and docker-compose
    printf "\n>>> Docker and docker-compose are going to be installed >>>\n"
# Using official repo to keep this updatable
sudo apt-get install docker.io docker-compose -y
sudo service docker enable
# This is to execute Docker command without sudo. Will work after logout/login because permissions should be refreshed
sudo usermod -aG docker ${USER}

# Install MySQL client and MySQL Docker images
    printf "\n>>> MySQL 5.6, 5.7, MariaDB and phpMyAdmin are going to be installed via docker-compose >>>\n"
sudo apt-get install mysql-client -y

mkdir -p ~/misc/db/docker_mysql
cd ~/misc/db/docker_mysql
echo "[mysqld]
wait_timeout=28800
max_allowed_packet=128M
innodb_log_file_size=128M
innodb_buffer_pool_size=1G

[mysql]
auto-rehash
" > my.cnf

echo "# docker-compose up -d --build --force-recreate
version: '3.7'
services:
  mysql56:
    container_name: mysql56
    image: mysql:5.6
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_PASS=root
    volumes:
      - ./mysql56_databases:/var/lib/mysql
      - ./my.cnf:/etc/my.cnf
    ports:
      - 3356:3306

  mysql57:
    container_name: mysql57
    image: mysql:5.7
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_PASS=root
    volumes:
      - ./mysql57_databases:/var/lib/mysql
      - ./my.cnf:/etc/my.cnf
    ports:
      - 3357:3306

  mysql80:
    container_name: mysql80
    image: mysql:8.0
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_PASS=root
    volumes:
      - ./mysql80_databases:/var/lib/mysql
      - ./my.cnf:/etc/my.cnf
    ports:
      - 3380:3306

  mariadb104:
    container_name: mariadb101
    image: bitnami/mariadb:10.4
    user: root
    restart: always
    environment:
      - MARIADB_ROOT_USER=root
      - MARIADB_ROOT_PASSWORD=root
    volumes:
      - ./mariadb104_databases:/bitnami/mariadb
      - ./my.cnf:/etc/my.cnf
    ports:
      - 33104:3306

  phpmyadmin:
    container_name: phpmyadmin
    image: phpmyadmin/phpmyadmin
    restart: always
    depends_on:
      - mysql56
      - mysql57
      - mysql80
      - mariadb104
    environment:
      - PMA_HOSTS=mysql56,mysql57,mysql80,mariadb104
      - PMA_USER=root
      - PMA_PASSWORD=root
    volumes:
      - /sessions
    links:
      - mysql56:mysql56
      - mysql57:mysql57
      - mysql80:mysql80
      - mariadb104:mariadb104
    ports:
      - 8080:80
" > ./docker-compose.yml
# Run docker-compose this way because we need not to log out in order to refresh permissions
sudo docker-compose up -d
    printf "\n>>> MySQL 5.6, 5.7, 8.0 and MariaDB 10.4 along with phpMyAdmin were installed successfully! >>>\n"

# Install Nginx web server
    printf "\n>>> Nginx is going to be installed: >>>\n"
sudo apt-get install nginx -y
    printf "\n>>> Set Nginx user to system: >>>\n"
sudo sed -i "s/user www-data;/user $USER;/g" /etc/nginx/nginx.conf
    printf "\n>>> Enabling nginx service >>>\n"
sudo service nginx enable

# Install Apache web server
    printf "\n>>> Apache is going to be installed: >>>\n"
sudo apt-get install apache2 -y
    printf "\n>>> Set Apache user to system: >>>\n"
sudo sed -i "s/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=$USER/g" /etc/apache2/envvars
sudo sed -i "s/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=$USER/g" /etc/apache2/envvars
    printf "\n>>> Appending 'ServerName localhost' to /etc/apache2/apache2.conf >>>\n"
echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf
    printf "\n>>> Enabling apache modules >>>\n"
sudo a2enmod rewrite proxy proxy_http ssl headers
    printf "\n>>> Enabling apache2 service >>>\n"
sudo service apache2 enable
    printf "\n>>> Apache installed successfully! >>>\n"

# Setup Nginx-Apache parallel flow - https://stackoverflow.com/a/56379304
    printf "\n>>> Setting up Nginx-Apache parallel flow configuration >>>\n"
# Nginx
sudo sed -i "/listen \[::\]:80 default_server;/d" /etc/nginx/sites-available/default
sudo sed -i "s/listen 80 default_server;/listen nginx:80;/g" /etc/nginx/sites-available/default
# Apache
sudo sed -i "s/Listen 80/Listen apache:80/g" /etc/apache2/ports.conf
sudo sed -i "s/Listen 443/Listen apache:443/g" /etc/apache2/ports.conf
sudo sed -i "s/<VirtualHost \*:80>/<VirtualHost apache:80>/g" /etc/apache2/sites-available/000-default
# hosts file
echo "

# Nginx-Apache parallel setup
127.0.0.1 nginx
127.0.0.2 apache
" | sudo tee -a /etc/hosts
    printf "\n>>> Restarting nginx and apache >>>\n"
sudo service nginx restart
sudo service apache2 restart

# Install PHP common packages
    printf "\n>>> Install common PHP packages (php-pear php-imagick php-memcached php-ssh2 php-xdebug) >>>\n"
sudo apt-get install php-pear php-imagick php-memcached php-ssh2 php-xdebug --no-install-recommends -y

# Install PHP 5.6 and modules
#    printf "\n>>> PHP 5.6 and common modules are going to be installed >>>\n"
#sudo apt-get install php5.6 php5.6-cli php5.6-common php5.6-json php5.6-opcache php5.6-readline --no-install-recommends -y
#sudo apt-get install php5.6-bz2 php5.6-bcmath php5.6-curl php5.6-gd php5.6-imap php5.6-intl php5.6-mbstring php5.6-mcrypt php5.6-mysql php5.6-recode php5.6-soap php5.6-xdebug php5.6-xml php5.6-xmlrpc php5.6-zip php5.6-fpm -y
#sudo service php5.6-fpm enable

# Install PHP 7.0 and modules, enable modules
#    printf "\n>>> PHP 7.0 and common modules are going to be installed >>>\n"
#sudo apt-get install php7.0 php7.0-cli php7.0-common php7.0-json php7.0-opcache php7.0-readline --no-install-recommends -y
#sudo apt-get install php7.0-bz2 php7.0-bcmath php7.0-curl php7.0-gd php7.0-imap php7.0-intl php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-recode php7.0-soap php7.0-xdebug php7.0-xml php7.0-xmlrpc php7.0-zip php7.0-fpm -y
#sudo service php7.0-fpm enable

# Install PHP 7.1 and modules, enable modules
#     printf "\n>>> PHP 7.1 and common modules are going to be installed >>>\n"
# sudo apt-get install php7.1 php7.1-cli php7.1-common php7.1-json php7.1-opcache php7.1-readline --no-install-recommends -y
# sudo apt-get install php7.1-bz2 php7.1-bcmath php7.1-curl php7.1-gd php7.1-imap php7.1-intl php7.1-mbstring php7.1-mcrypt php7.1-mysql php7.1-recode php7.1-soap php7.1-xdebug php7.1-xml php7.1-xmlrpc php7.1-zip php7.1-fpm -y
# sudo service php7.1-fpm enable

# Install PHP 7.2 and modules, enable modules
#    printf "\n>>> PHP 7.2 and common modules are going to be installed >>>\n"
#sudo apt-get install php7.2 php7.2-cli php7.2-common php7.2-json php7.2-opcache php7.2-readline --no-install-recommends -y
#sudo apt-get install php7.2-bz2 php7.2-bcmath php7.2-curl php7.2-gd php7.2-imap php7.2-intl php7.2-mbstring php7.2-mysql php7.2-recode php7.2-soap php7.2-xdebug php7.2-xml php7.2-xmlrpc php7.2-zip php7.2-fpm -y
#sudo service php7.2-fpm enable

# Install PHP 7.3 and modules, enable modules
#    printf "\n>>> PHP 7.3 and common modules are going to be installed >>>\n"
#sudo apt-get install php7.3 php7.3-cli php7.3-common php7.3-json php7.3-opcache php7.3-readline --no-install-recommends -y
#sudo apt-get install php7.3-bz2 php7.3-bcmath php7.3-curl php7.3-gd php7.3-imap php7.3-intl php7.3-mbstring php7.3-mysql php7.3-recode php7.3-soap php7.3-xdebug php7.3-xml php7.3-xmlrpc php7.3-zip php7.3-fpm -y
#sudo service php7.3-fpm enable

# Install PHP 7.4 and modules, enable modules
    printf "\n>>> PHP 7.4 and common modules are going to be installed >>>\n"
sudo apt-get install php7.4 php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline --no-install-recommends -y
sudo apt-get install php7.4-bz2 php7.4-bcmath php7.4-curl php7.4-gd php7.4-imap php7.4-intl php7.4-mbstring php7.4-mysql php7.4-soap php7.4-xdebug php7.4-xml php7.4-xmlrpc php7.4-zip php7.4-fpm -y
sudo service php7.4-fpm enable

# Install PHP 8.0 and modules, enable modules
    printf "\n>>> PHP 8.0 and common modules are going to be installed >>>\n"
sudo apt-get install php8.0 php8.0-cli php8.0-common php8.0-opcache php8.0-readline --no-install-recommends -y
sudo apt-get install php8.0-bz2 php8.0-bcmath php8.0-curl php8.0-gd php8.0-imap php8.0-intl php8.0-mbstring php8.0-mysql php8.0-soap php8.0-xdebug php8.0-xml php8.0-xmlrpc php8.0-zip php8.0-fpm -y
sudo service php8.0-fpm enable

# Install PHP 8.1 and modules, enable modules
    printf "\n>>> PHP 8.1 and common modules are going to be installed >>>\n"
sudo apt-get install php8.1 php8.1-cli php8.1-common php8.1-opcache php8.1-readline --no-install-recommends -y
sudo apt-get install php8.1-bz2 php8.1-bcmath php8.1-curl php8.1-gd php8.1-imap php8.1-intl php8.1-mbstring php8.1-mysql php8.1-soap php8.1-xdebug php8.1-xml php8.1-xmlrpc php8.1-zip php8.1-fpm -y
sudo service php8.1-fpm enable

    printf "\n>>> Creating ini files for the development environment >>>\n"
IniDirs=/etc/php/*/*/conf.d/
for IniDir in ${IniDirs};
do
    printf "Creating ${IniDir}/999-custom-config.ini\n"
sudo rm ${IniDir}999-custom-config.ini
echo "error_reporting=E_ALL & ~E_DEPRECATED
display_errors=On
display_startup_errors=On
ignore_repeated_errors=On
cgi.fix_pathinfo=1
max_execution_time=3600
session.gc_maxlifetime=84600

opcache.enable=1
opcache.validate_timestamps=1
opcache.revalidate_freq=1
opcache.max_wasted_percentage=10
opcache.memory_consumption=256
opcache.max_accelerated_files=20000

xdebug.mode=debug
xdebug.remote_handler=dbgp
xdebug.show_error_trace=1
xdebug.start_with_request=yes
xdebug.max_nesting_level=256
xdebug.log_level=0
" | sudo tee ${IniDir}999-custom-config.ini
done

IniDirs=/etc/php/*/apache2/conf.d/
for IniDir in ${IniDirs};
do
echo "memory_limit=768M
" | sudo tee -a ${IniDir}999-custom-config.ini
done

IniDirs=/etc/php/*/fpm/conf.d/
for IniDir in ${IniDirs};
do
echo "memory_limit=768M
" | sudo tee -a ${IniDir}999-custom-config.ini
done

FpmConfFiles=/etc/php/*/fpm/pool.d/www.conf
for FpmConfFile in ${FpmConfFiles};
do
sudo sed -i "s/user = www-data/user = $USER/g" ${FpmConfFile}
sudo sed -i "s/group = www-data/group = $USER/g" ${FpmConfFile}
sudo sed -i "s/listen.owner = www-data/listen.owner = $USER/g" ${FpmConfFile}
sudo sed -i "s/listen.group = www-data/listen.group = $USER/g" ${FpmConfFile}
done

IniDirs=/etc/php/*/cli/conf.d/
for IniDir in ${IniDirs};
do
echo "memory_limit=2G
" | sudo tee -a ${IniDir}999-custom-config.ini
done

# Set default PHP version to 7.4
    printf "Enabling PHP 7.4 by default"
sudo update-alternatives --set php /usr/bin/php7.4
sudo service php7.4-fpm enable > /dev/null 2>&1
sudo service php7.4-fpm restart

    printf "\n>>> Enabling php modules: mbstring mcrypt xdebug >>>\n"
sudo phpenmod mbstring mcrypt xdebug
sudo service nginx restart
sudo service apache2 restart

# Composer
    printf "\n>>> Install composer globally >>>\n"
sudo apt-get remove composer -y
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/bin/composer

# Setup CLI settings and alias
    printf "\n>>> Creating aliases and enabling color output >>>\n"
# XDEBUG_SESSION is important for CLI debugging
echo "force_color_prompt=yes
shopt -s autocd
set completion-ignore-case On

export XDEBUG_SESSION=PHPSTORM
export XDEBUG_MODE=debug

cert_function() {
  mkdir -p ~/misc/ssl/\$1
  mkcert -key-file ~/misc/ssl/\$1/\$1+1-key.pem -cert-file ~/misc/ssl/\$1/\$1+1.pem \$1 www.\$1
}

nginx_symlink_function() {
  sudo ln -s /etc/nginx/sites-available/\$1 /etc/nginx/sites-enabled/
}

alias CERT=cert_function
alias NGENSITE=nginx_symlink_function

alias C1=\"composer self-update --1\"
alias C2=\"composer self-update --2\"

alias ES=\"sudo service elasticsearch restart\"

# alias PHP56=\"sudo update-alternatives --set php /usr/bin/php5.6\"
# alias PHP70=\"sudo update-alternatives --set php /usr/bin/php7.0\"
# alias PHP71=\"sudo update-alternatives --set php /usr/bin/php7.1\"
# alias PHP72=\"sudo update-alternatives --set php /usr/bin/php7.2\"
# alias PHP73=\"sudo update-alternatives --set php /usr/bin/php7.3\"
alias PHP74=\"sudo update-alternatives --set php /usr/bin/php7.4\"
alias PHP80=\"sudo update-alternatives --set php /usr/bin/php8.0\"
alias PHP81=\"sudo update-alternatives --set php /usr/bin/php8.1\"

alias AP=\"sudo service apache2 restart\"
alias NG=\"sudo service nginx restart\"

# alias FPM56=\"sudo service php5.6-fpm restart\"
# alias FPM70=\"sudo service php7.0-fpm restart\"
# alias FPM71=\"sudo service php7.1-fpm restart\"
# alias FPM72=\"sudo service php7.2-fpm restart\"
# alias FPM73=\"sudo service php7.3-fpm restart\"
alias FPM74=\"sudo service php7.4-fpm restart\"
alias FPM80=\"sudo service php8.0-fpm restart\"
alias FPM81=\"sudo service php8.1-fpm restart\"

alias MY56=\"mysql -uroot -proot -h127.0.0.1 --port=3356 --show-warnings\"
alias MY57=\"mysql -uroot -proot -h127.0.0.1 --port=3357 --show-warnings\"
alias MY80=\"mysql -uroot -proot -h127.0.0.1 --port=3380 --show-warnings\"
alias MD104=\"mysql -uroot -proot -h127.0.0.1 --port=33104 --show-warnings\"

alias SU=\"php bin/magento setup:upgrade\"
alias DI=\"php bin/magento setup:di:compile\"
alias CC=\"php bin/magento cache:clean\"
alias CF=\"php bin/magento cache:flush\"
alias RI=\"php bin/magento indexer:reindex\"
alias RS=\"php bin/magento indexer:status\"
" | tee -a ~/.bash_aliases

# Install Node Package Manager and Grunt tasker
    printf "\n>>> NPM and Grunt are going to be installed >>>\n"
sudo apt-get install nodejs -y
sudo npm install -g grunt-cli

# Install Yarn
    printf "\n>>> Yarn is going to be installed >>>\n"
sudo npm install -g yarn

# Install N
    printf "\n>>> N package is going to be installed >>>\n"
sudo npm install -g n

# Install ElasticSearch 7
    printf "\n>>> JDK and ElasticSearch 7 is going to be installed >>>\n"
sudo apt-get install default-jre elasticsearch -y
sudo systemctl disable elasticsearch # use /etc/elasticsearch/jvm.options to configure its memory heap size

# Install Google Chrome
    printf "\n>>> Google Chrome is going to be installed >>>\n"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

# Install mkcert - https://github.com/FiloSottile/mkcert/releases
    printf "\n>>> mkcert are going to be installed >>>\n"
sudo apt-get install libnss3-tools -y
wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64
chmod +x mkcert-v1.4.4-linux-amd64
sudo mv mkcert-v1.4.4-linux-amd64 /usr/bin/mkcert
mkcert -install

# Install Guake terminal
    printf "\n>>> Guake terminal is going to be installed >>>\n"
sudo apt-get install guake -y

# Install Diodon clipboard manager
    printf "\n>>> Diodon clipboard manager is going to be installed >>>\n"
sudo apt-get install diodon -y

# Install xclip - copy output to clipboard
    printf "\n>>> xclip is going to be installed >>>\n"
sudo apt-get install xclip -y

# Install Midnight Commander
    printf "\n>>> Midnight Commander is going to be installed >>>\n"
sudo apt-get install mc -y

# Install Sublime Text editor
    printf "\n>>> Sublime Text is going to be installed >>>\n"
sudo snap install sublime-text --classic

# Install Vim text editor
    printf "\n>>> Vim is going to be installed >>>\n"
sudo apt-get install vim -y

# Install htop utility
    printf "\n>>> htop is going to be installed >>>\n"
sudo apt-get install htop -y

# Install Git and Git Gui
    printf "\n>>> Git and Git Gui are going to be installed >>>\n"
sudo apt-get install git git-gui -y

# Install Redis cache system
    printf "\n>>> Redis cache system is going to be installed >>>\n"
sudo apt-get install redis-server -y
sudo sed -i 's/^supervised no/supervised systemd/g' /etc/redis/redis.conf
sudo service redis restart

# Install Shutter
    printf "\n>>> Shutter is going to be installed >>>\n"
sudo apt-get install shutter -y

# Install Pinta
    printf "\n>>> Pinta is going to be installed >>>\n"
sudo apt-get install pinta -y

# Install OBS Studio
    printf "\n>>> OBS Studio is going to be installed >>>\n"
sudo apt-get install obs-studio -y

# Install KeePassXC - free encrypted password storage
    printf "\n>>> KeePassXC is going to be installed >>>\n"
sudo snap install keepassxc

# Install Slack messenger
    printf "\n>>> Slack messenger is going to be installed >>>\n"
sudo snap install slack --classic

# Install Telegram messenger
    printf "\n>>> Telegram messenger is going to be installed >>>\n"
sudo apt-get install telegram -y

# Install Skype messenger
    printf "\n>>> Skype messenger is going to be installed >>>\n"
sudo snap install skype --classic

# Install PhpStorm
    printf "\n>>> PhpStorm is going to be installed >>>\n"
sudo snap install phpstorm --classic
    printf "\n>>> Setting filesystem parameters for PHPStorm IDE: fs.inotify.max_user_watches = 524288 >>>\n"
echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.conf

# Install Gnome Tweak Tool for tuning Ubuntu
    printf "\n>>> Gnome Tweak Tool is going to be installed >>>\n"
sudo apt-get install gnome-tweaks -y

# System reboot
    printf "\033[31;1m"
read -p "/**********************
*
*    ATTENTION!
*
*    System is going to be restarted
*
*    Based on this instruction by DefaultValue:
*    - post-install script - https://github.com/DefaultValue/ubuntu_post_install_scripts
*
*    PRESS ANY KEY TO CONTINUE
*
\**********************
" nothing

printf "\n*** Job done! Going to reboot in 5 seconds... ***\n"

sleep 5
sudo reboot

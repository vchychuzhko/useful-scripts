#!/bin/sh
# sudo access will be requested if the script was not run with sudo or under root user
sudo -k

# Read root password
if ! [ $(sudo id -u) = 0 ]; then
    echo "\033[31;1m"
    echo "Root password was not entered correctly!"
    exit 1;
fi

sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

    printf "\n>>> Creating files and folders... >>>\n"
# Creating working folders
mkdir -p ~/misc/apps ~/misc/ssl ~/misc/db

# Adding context option to create "Untitled Document"
mkdir -p ~/Templates
touch ~/Templates/Untitled\ Document

# Install cUrl
    printf "\n>>> cUrl is going to be installed >>>\n"
sudo apt install curl -y

    printf "\n>>> Adding repositories and updating software list >>>\n"
# Docker - https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Various PHP versions
sudo add-apt-repository ppa:ondrej/php -y -n

# Node
curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash -

# ElasticSearch 7
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg
echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

# Sublime Text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

# PhpStorm
curl -s https://s3.eu-central-1.amazonaws.com/jetbrains-ppa/0xA6E8698A.pub.asc | gpg --dearmor | sudo tee /usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg] http://jetbrains-ppa.s3-website.eu-central-1.amazonaws.com any main" | sudo tee /etc/apt/sources.list.d/jetbrains-ppa.list > /dev/null

    printf "\n>>> Running Ubuntu upgrade >>>\n"
sudo apt update
sudo apt upgrade -y

# Install ifconfig
sudo apt install net-tools -y

# Install Docker and Docker Compose
    printf "\n>>> Docker and Docker Compose are going to be installed >>>\n"
sudo apt install docker.io docker-compose-plugin -y
# This is to execute Docker command without sudo. Will work after logout/login because permissions should be refreshed
sudo usermod -aG docker ${USER}

# Install MySQL client and MySQL Docker images
    printf "\n>>> MySQL 8.0, MariaDB 10.11 and phpMyAdmin are going to be installed with docker compose >>>\n"
sudo apt install mysql-client -y

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

echo "# docker compose up -d --build --force-recreate
services:
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

  mariadb10:
    container_name: mariadb10
    image: bitnami/mariadb:10.11
    user: root
    restart: always
    environment:
      - MARIADB_ROOT_USER=root
      - MARIADB_ROOT_PASSWORD=root
    volumes:
      - ./mariadb10_databases:/bitnami/mariadb
      - ./my.cnf:/etc/my.cnf
    ports:
      - 3310:3306

  phpmyadmin:
    container_name: phpmyadmin
    image: phpmyadmin/phpmyadmin
    restart: always
    depends_on:
      - mysql80
      - mariadb10
    environment:
      - PMA_HOSTS=mysql80,mariadb10
      - PMA_USER=root
      - PMA_PASSWORD=root
    volumes:
      - /sessions
    links:
      - mysql80:mysql80
      - mariadb10:mariadb10
    ports:
      - 8080:80
" > ./docker-compose.yml
# Run docker-compose this way because we need not to log out in order to refresh permissions
sudo docker compose up -d
    printf "\n>>> MySQL 8.0 and MariaDB 10.11 along with phpMyAdmin were installed successfully! >>>\n"

# Install Nginx web server
    printf "\n>>> Nginx is going to be installed: >>>\n"
sudo apt install nginx -y
    printf "\n>>> Set Nginx user to system: >>>\n"
sudo sed -i "s/user www-data;/user $USER;/g" /etc/nginx/nginx.conf
    printf "\n>>> Nginx installed successfully! >>>\n"

# Install Apache web server
    printf "\n>>> Apache is going to be installed: >>>\n"
sudo apt install apache2 -y
    printf "\n>>> Set Apache user to system: >>>\n"
sudo sed -i "s/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=$USER/g" /etc/apache2/envvars
sudo sed -i "s/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=$USER/g" /etc/apache2/envvars
    printf "\n>>> Appending 'ServerName localhost' to /etc/apache2/apache2.conf >>>\n"
echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf
    printf "\n>>> Enabling apache modules >>>\n"
sudo a2enmod rewrite proxy proxy_http ssl headers
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
# Nginx-Apache parallel setup - https://stackoverflow.com/a/56379304
127.0.0.1 nginx
127.0.0.2 apache" | sudo tee -a /etc/hosts
    printf "\n>>> Restarting nginx and apache >>>\n"
sudo service nginx restart
sudo service apache2 restart

# Install PHP common packages
    printf "\n>>> Install common PHP packages (php-pear php-imagick php-memcached php-ssh2 php-xdebug) >>>\n"
sudo apt install php-pear php-imagick php-memcached php-ssh2 php-xdebug --no-install-recommends -y

# Install PHP 8.0 and modules
    printf "\n>>> PHP 8.0 and common modules are going to be installed >>>\n"
sudo apt install php8.0 php8.0-cli php8.0-common php8.0-opcache php8.0-readline --no-install-recommends -y
sudo apt install php8.0-bz2 php8.0-bcmath php8.0-curl php8.0-gd php8.0-imap php8.0-intl php8.0-mbstring php8.0-mysql php8.0-soap php8.0-xdebug php8.0-xml php8.0-xmlrpc php8.0-zip php8.0-fpm -y

# Install PHP 8.1 and modules
    printf "\n>>> PHP 8.1 and common modules are going to be installed >>>\n"
sudo apt install php8.1 php8.1-cli php8.1-common php8.1-opcache php8.1-readline --no-install-recommends -y
sudo apt install php8.1-bz2 php8.1-bcmath php8.1-curl php8.1-gd php8.1-imap php8.1-intl php8.1-mbstring php8.1-mysql php8.1-soap php8.1-xdebug php8.1-xml php8.1-xmlrpc php8.1-zip php8.1-fpm -y

# Install PHP 8.2 and modules
    printf "\n>>> PHP 8.2 and common modules are going to be installed >>>\n"
sudo apt install php8.2 php8.2-cli php8.2-common php8.2-opcache php8.2-readline --no-install-recommends -y
sudo apt install php8.2-bz2 php8.2-bcmath php8.2-curl php8.2-gd php8.2-imap php8.2-intl php8.2-mbstring php8.2-mysql php8.2-soap php8.2-xdebug php8.2-xml php8.2-xmlrpc php8.2-zip php8.2-fpm -y

# Install PHP 8.3 and modules
    printf "\n>>> PHP 8.3 and common modules are going to be installed >>>\n"
sudo apt install php8.3 php8.3-cli php8.3-common php8.3-opcache php8.3-readline --no-install-recommends -y
sudo apt install php8.3-bz2 php8.3-bcmath php8.3-curl php8.3-gd php8.3-imap php8.3-intl php8.3-mbstring php8.3-mysql php8.3-soap php8.3-xdebug php8.3-xml php8.3-xmlrpc php8.3-zip php8.3-fpm -y

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
xdebug.log_level=0" | sudo tee ${IniDir}999-custom-config.ini
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

# Set default PHP version to 8.2
    printf "Enabling PHP 8.2 by default"
sudo update-alternatives --set php /usr/bin/php8.2

    printf "\n>>> Configuring php modules >>>\n"
sudo phpenmod mbstring
sudo phpdismod xdebug
sudo service nginx restart
sudo service apache2 restart

# Composer
    printf "\n>>> Install composer globally >>>\n"
sudo apt remove composer -y
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

nginx_function() {
  sudo ln -s /etc/nginx/sites-available/\$1 /etc/nginx/sites-enabled/
}

xdebug_function() {
    if [ -e \"/etc/php/8.0/fpm/conf.d/20-xdebug.ini\" ]; then
        sudo phpdismod xdebug
        echo \"Xdebug is OFF\"
    else
        sudo phpenmod xdebug
        echo \"Xdebug is ON\"
    fi
}

alias CERT=cert_function
alias NGENSITE=nginx_function
alias XD=xdebug_function

alias PHP80=\"sudo update-alternatives --set php /usr/bin/php8.0\"
alias PHP81=\"sudo update-alternatives --set php /usr/bin/php8.1\"
alias PHP82=\"sudo update-alternatives --set php /usr/bin/php8.2\"
alias PHP83=\"sudo update-alternatives --set php /usr/bin/php8.3\"

alias C1=\"sudo composer self-update --1\"
alias C2=\"sudo composer self-update --2\"

alias N16=\"sudo n 16\"
alias N18=\"sudo n 18\"
alias N20=\"sudo n 20\"
alias N22=\"sudo n 22\"

alias AP=\"sudo service apache2 restart\"
alias NG=\"sudo service nginx restart\"
alias ES=\"sudo service elasticsearch restart\"
alias ESOFF=\"sudo service elasticsearch stop\"

alias MY80=\"mysql -uroot -proot -h127.0.0.1 --port=3380 --show-warnings\"
alias MA10=\"mysql -uroot -proot -h127.0.0.1 --port=3310 --show-warnings\"

alias SU=\"php bin/magento setup:upgrade\"
alias DI=\"php bin/magento setup:di:compile\"
alias CC=\"php bin/magento cache:clean\"
alias RI=\"php bin/magento indexer:reindex\"
alias RS=\"php bin/magento indexer:status\"" | tee -a ~/.bash_aliases

# Install Node Package Manager and set home directory as user-global folder
    printf "\n>>> NPM is going to be installed >>>\n"
sudo apt install nodejs -y
mkdir ~/.npm-global
npm config set prefix "${HOME}/.npm-global"
echo "export PATH=\$PATH:~/.npm-global/bin" | tee -a ~/.bashrc

# Install Grunt tasker
    printf "\n>>> Grunt is going to be installed >>>\n"
npm install -g grunt-cli

# Install Yarn
    printf "\n>>> Yarn is going to be installed >>>\n"
npm install -g yarn

# Install N
    printf "\n>>> N package is going to be installed >>>\n"
npm install -g n
sudo ln -s ~/.npm-global/bin/n /usr/local/bin/n # as n requires sudo access

# Install ElasticSearch 7
    printf "\n>>> JDK and ElasticSearch 7 are going to be installed >>>\n"
sudo apt install default-jre elasticsearch -y
sudo systemctl disable elasticsearch # use /etc/elasticsearch/jvm.options to configure its memory heap size

# Install Google Chrome
    printf "\n>>> Google Chrome is going to be installed >>>\n"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

# Remove Thunderbird
    printf "\n>>> Thunderbird is going to be removed >>>\n"
sudo snap remove --purge thunderbird

# Reinstall Firefox - https://www.debugpoint.com/remove-firefox-snap-ubuntu
    printf "\n>>> Firefox is going to be reinstalled >>>\n"
sudo snap remove --purge firefox
echo '
Package: firefox*
Pin: release o=Ubuntu*
Pin-Priority: -1
' | sudo tee /etc/apt/preferences.d/firefox-no-snap
sudo apt purge firefox -y
sudo add-apt-repository ppa:mozillateam/ppa -y
sudo apt install firefox -y
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

# Install Epiphany Web Browser
    printf "\n>>> Epiphany Web Browser is going to be installed >>>\n"
sudo apt install epiphany-browser -y

# Install mkcert - https://github.com/FiloSottile/mkcert/releases
    printf "\n>>> mkcert is going to be installed >>>\n"
sudo apt install libnss3-tools -y
curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64
sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
mkcert -install

# Install Guake terminal
    printf "\n>>> Guake terminal is going to be installed >>>\n"
sudo apt install guake -y

# Install Diodon clipboard manager
    printf "\n>>> Diodon clipboard manager is going to be installed >>>\n"
sudo apt install diodon -y

# Install Sublime Text editor
    printf "\n>>> Sublime Text is going to be installed >>>\n"
sudo apt install sublime-text -y

# Install xclip - copy output to clipboard
    printf "\n>>> xclip is going to be installed >>>\n"
sudo apt install xclip -y

# Install Midnight Commander
    printf "\n>>> Midnight Commander is going to be installed >>>\n"
sudo apt install mc -y

# Install Vim text editor
    printf "\n>>> Vim is going to be installed >>>\n"
sudo apt install vim -y

# Install htop utility
    printf "\n>>> htop is going to be installed >>>\n"
sudo apt install htop -y

# Install pv
    printf "\n>>> pv is going to be installed >>>\n"
sudo apt install pv -y

# Install Git and Git Gui
    printf "\n>>> Git and Git Gui are going to be installed >>>\n"
sudo apt install git git-gui -y

# Install Redis cache system
    printf "\n>>> Redis cache system is going to be installed >>>\n"
sudo apt install redis-server -y
sudo sed -i 's/^supervised no/supervised systemd/g' /etc/redis/redis.conf
sudo service redis restart

# Install Shutter
    printf "\n>>> Shutter is going to be installed >>>\n"
sudo apt install shutter -y

# Install Pinta
    printf "\n>>> Pinta is going to be installed >>>\n"
sudo apt install pinta -y

# Install OBS Studio
    printf "\n>>> OBS Studio is going to be installed >>>\n"
sudo apt install obs-studio -y

# Install KeePassXC - free encrypted password storage
    printf "\n>>> KeePassXC is going to be installed >>>\n"
sudo add-apt-repository ppa:phoerious/keepassxc -y
sudo apt install keepassxc -y

# Install Slack messenger
    printf "\n>>> Slack messenger is going to be installed >>>\n"
wget https://downloads.slack-edge.com/releases/linux/4.35.131/prod/x64/slack-desktop-4.35.131-amd64.deb
sudo apt install ./slack-desktop-4.35.131-amd64.deb
rm ./slack-desktop-4.35.131-amd64.deb

# Install Telegram messenger
    printf "\n>>> Telegram messenger is going to be installed >>>\n"
sudo add-apt-repository ppa:atareao/telegram -y
sudo apt install telegram -y

# Install Skype messenger
    printf "\n>>> Skype messenger is going to be installed >>>\n"
wget https://repo.skype.com/latest/skypeforlinux-64.deb
sudo dpkg -i skypeforlinux-64.deb
rm skypeforlinux-64.deb

# Install PhpStorm - https://github.com/JonasGroeger/jetbrains-ppa
    printf "\n>>> PhpStorm is going to be installed >>>\n"
sudo apt install phpstorm -y
if ! grep -q 'fs.inotify.max_user_watches = 524288' /etc/sysctl.conf; then
    printf "\n>>> Setting filesystem parameters for PHPStorm IDE: fs.inotify.max_user_watches = 524288 >>>\n"
    echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.conf > /dev/null
fi

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

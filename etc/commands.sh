#-----Magento 2 cli commands-----#

grunt exec:first_theme
grunt less:first_theme
grunt exec:theme && grunt less:theme
grunt watch

php bin/magento module:enable Vendor_Module # enable module

php bin/magento cache:clean
php bin/magento cache:flush

php bin/magento setup:upgrade --keep-generated # upgrading magento scheme, optionally with no removing cache files
php bin/magento setup:di:compile

php bin/magento indexer:reindex # run indexers reindexing
php bin/magento indexer:set-mode realtime # switch indexers to on-save processing, use "schedule" for cron processing

php bin/magento setup:static-content:deploy -f # deploy static content forced (ignoring non-production mode)
php bin/magento setup:static-content:deploy en_US nl_NL --exclude-theme Vendor/theme
php bin/magento setup:static-content:deploy en_US en_GB de_DE --theme Vendor/theme

php bin/magento deploy:mode:set developer # set mode to developer
php bin/magento deploy:mode:set production --skip-compilation # set mode to production, optionally skipping compilation

php bin/magento maintenance:enable --ip=127.0.0.1 # enable maintenance mode, optionally allow entered ips
php bin/magento maintenance:disable

php bin/magento dev:urn-catalog:generate .idea/misc.xml # generate urn-catalog for xml
php bin/magento setup:config:set --backend-frontname="newadminurl" # change admin URL

php bin/magento sampledata:deploy # download sample data packages (dont forget about auth.json) then > php bin/magento setup:upgrade
php bin/magento sampledata:remove # while removing, delete *.flag file (drop DB, uninstall, delete, install)

php bin/magento app:config:import # import configurations

rm -rf var/cache/ var/page_cache/ # clear layout
rm -rf pub/static/frontend/ pub/static/_cache/ pub/static/deployed_version.txt var/cache/ var/page_cache/ var/view_preprocessed/ # full clear

/misc/apps/marketplace-eqp/vendor/bin/phpcs --standard=MEQP2 --severity=8 <path to dir> # run tests to check php code

/rest/V1/products?searchCriteria # Magento REST API all products
/rest/V1/products/<SKU>
/rest/V1/directory/currency
# vendor/magento/module-webapi/Controller/Rest/RequestValidator.php -> L68

dev/tests/static/testsuite/Magento/Test/Js/_files/eslint/.eslintrc # ESLINT path example, for phpstorm

cat app/etc/env.php | grep 'host\|dbname\|username\|password' # view needed db data

#-----Magento Cli Installation-----#

# Execute the following command in order to create a new administrator with username "new-admin" and password "!admin123!"
php bin/magento admin:user:create --admin-user='admin' --admin-password='Q1w2e3r4' --admin-email='admin@mail.com' --admin-firstname='Admin' --admin-lastname='User'

sudo rm var/log/access.log var/log/error.log && > var/log/access.log && > var/log/error.log # reset apache log files to have write premissions on them

rm app/etc/config.php
rm app/etc/env.php
php bin/magento setup:install --admin-firstname="Admin" --admin-lastname="User" --admin-email="admin@mail.com" --admin-user="admin" --admin-password="Q1w2e3r4" --base-url="https://magento.local/" --base-url-secure="https://magento.local/" --db-name="magento_db" --db-user="root" --db-password="root" --db-host="127.0.0.1:3357" --use-rewrites=1 --use-secure="1" --use-secure-admin="1" --session-save="files" --language=en_US --currency=USD --timezone=Europe/Kiev --cleanup-database --backend-frontname="admin"

#-----Symfony encore commands-----#

yarn encore dev # compile assets once
yarn encore dev --watch # or, recompile assets automatically when files change
yarn encore production # on deploy, create a production build

#-----Git commands-----#

cat ~/.ssh/id_rsa.pub | pbcopy # copy ssh key to clipboard
type ~/.ssh/id_rsa.pub | clip # copy ssh key to clipboard on Windows

git config core.fileMode false # ignore file owner modification

git checkout -b <name_of_your_new_branch> # create new branch and switch to it
git checkout <name_of_your_new_branch> # change working branch
git branch -m (old-name) <new-name> # rename (!current) local branch
git push origin :old-name new-name # push and rename remote branch

git branch -D <branch_name> # remove branch locally
git push <remote_name> :<branch_name> # remove branch on remote

git reset --hard <commit_hash> # hard reset to selected commit
git push origin <your_branch_name> --force # force push

git merge <branch_name> # merge selected branch into current
git merge origin/<branch_name> && git push origin --delete <branch_name> # merge branch and delete it

git add index.html css/styles.css
git commit -m "Change titles and styling on homepage"

git remote set-url origin <URL> # change remote URL

ssh-keygen -t rsa # generate ssh
cat ~/.ssh/id_rsa.pub # view ssh

gitdir: /home/wolbocht/repo/bedroomsecrets/.git # .git file content example

git tag -l | grep "pro" | while read t; do n="${t/-pro/}"; git tag $n $t ; git tag -d $t ; done # update tags by removing "-pro" string from them
git tag -l | grep "pro" | while read t; do git tag -d $t ; done # remove tags with "-pro" string
git tag -l | grep "pro" | while read t; do git tag -d $t ; git push origin :refs/tags/$t ; done # remove tags with "-pro" string (including remote)

git filter-branch -f --tree-filter 'test -f app/config.php && sed -i "/sensitivedata/ d" app/config.php || echo "skip"' -- --all # remove line with sensitive data from history
git filter-branch -f --tree-filter 'test -f nginx.conf.sample && sed -i "s/searched/replace/g" nginx.conf.sample || echo "skip"' -- --all # same but replacing
git push --force --verbose --dry-run

git tag -d 2.2.8 # remove tag locally
git push origin :refs/tags/2.2.8 # remove tag on remote
git tag 2.2.8 # create tag locally
git push origin : 2.2.8 # upload new tag to remote

git filter-branch -f --prune-empty --tree-filter "find . -name 'composer.json' -exec sed -i '' -e 's/srm/cat/g' {} \;" # replace string in specified file for all git history
git filter-branch --tag-name-filter cat -f --prune-empty --tree-filter "find . -name 'composer.json' -exec sed -i '' -e 's/srm/cat/g' {} \;" -- --tags # same as above but with tags
git push origin :refs/tags/1.0.0 && git push origin : 1.0.0 # upload tag changes after filtering to remote (remove and re-upload)

git filter-branch -f --tree-filter 'test -d Vendor/Attribute && mv Vendor/Attribute/* . || echo "Nothing to do"' -- --all # move folder to the project root for repository
git filter-branch -f --tag-name-filter cat --tree-filter 'test -d Vendor/Attribute && mv Vendor/Attribute/* . || echo "Nothing to do"' -- --tags # same as above but with tags

# Remove folder/file from git with no physical removing
1. Add the folder path to your repo root .gitignore file.
2. git rm -r --cached path_to_your_folder/

# Pull changes with no merge commit - https://stackoverflow.com/a/30054231
# Commit needed changes then pull remote commits by using rebase option
git stash # save current uncommited changes
git pull --rebase <remote> <branch>
git rebase --continue # after conflicts are resolved (if any)
git stash pop # restore saved changes

# Update commit in history
# https://stackoverflow.com/a/1186549
git rebase --interactive '<commit_hash>^'
# modify 'pick' to 'edit' in the line mentioning needed commit
git commit --amend --no-edit # add your changes
git rebase --continue # finish rebase, force push will be required

# Rename commit(s) in history
git rebase -i HEAD~2 # init rebase for last 2 commits
# modify 'pick' for 'reword' for needed commits and save
# edit name(s)
git push --force

# Clean up local branch list
git branch --merged | egrep -v "(^\*|master|staging)" | xargs git branch -D # remove all merged branches LOCALLY

git log --full-history -1 -- <file> # show last commit related to file

#-----Use existing folder for git repository-----#

cd <dir>
git init
git remote add origin <repository ssh/https>
git add .
git commit -m "Initial commit"
git push origin master

#-----Docker commands-----#

docker ps | grep <part of name> # show all containers in docker with part of name
docker exec -it <moduleName> bash # enable cli in selected module

docker-compose up -d --build --force-recreate

#-----Varnish-----#

sudo systemctl restart varnish # restart varnish service

sudo varnishadm backend.list # list active backends
varnishd -C -f /etc/varnish/default.vcl # validate vcl file

subl /lib/systemd/system/varnish.service # configure varnish service launch parameters
subl /etc/varnish/default.vcl # varnish environment configuration file
subl /etc/default/varnish # varnish launch configuration file

#-----PHP-----#

php -i | grep php.ini # find the location of the php.ini file

source /opt/cpanel/ea-php70/enable # enable specific php version for current cli session
php -d memory_limit=1G my_script.php # increase memory limit for single command

echo "<?php phpinfo();" > info.php # create info.php file

php -r 'echo ("0" ? 1 : 0) . "\n";' # run code in the command line
php -r 'phpinfo();' | grep gc_maxlifetime # run phpinfo in CLI with filtering results

find ./ -type f -iname '*.php' | xargs -n1 /usr/bin/php -l # validate php files according to your current PHP version
find ./ -type f -iname '*.php' | xargs -n1 /usr/bin/php7.0 -l # use specific PHP version

#-----ElasticSearch-----#

sudo service elasticsearch restart

subl /etc/elasticsearch/jvm.options # edit elasticsearch memory config
curl -X GET 'http://127.0.0.1:9200' # view elasticsearch version
curl -X GET 'http://127.0.0.1:9200/_cat/indices' # view all indexes
curl -X GET 'http://127.0.0.1:9200/vue_storefront_catalog_global_en_product/_search?q=id:11269&pretty' # get product info from elastic
curl -X DELETE 'http://127.0.0.1:9200/_all' # remove all indexes

#-----Linux-----#

ifconfig | grep "inet " | grep -v 127.0.0.1 # show your local IP

subl /etc/bash.bashrc # create cmd alias
subl ~/.bashrc # edit command prompt view - l59

tail -n <number> <file> # shows last <number> of lines in the file
tail -f <file> | grep <filter> # shows last 10 lines of the <file> with refreshing and filtering by <filter>

tail -n 10 test.log > test1.log # create temporary file with 10 last lines of old one
mv test1.log test.log # replace old file with temporary

lsof -i :8000 # see the app which is listening to 8000 port
ps aux | grep cron:run # show all running processes with name 'cron:run'
kill -9 <pid> # kill process with found PID

ln -s <target> <name> # create symlink

composer install --ignore-platform-reqs # install ignoring environment requirements
composer clearcache # clear composer cache

scp user@127.0.0.1:/home/user/db_dump.sql.gz . # copy a file from server
scp -P 41 user@127.0.0.1:/home/user/public_html/var/backups/db_dump.sql.gz . # copy a file from server with port
scp -P 41 ~/Downloads/adminer.php user@127.0.0.1:/home/user/public_html # copy file to server
# add "-rp" flags for directories recursively

rsync -avz --progress user@127.0.0.1:/home/user/public_html/media/ ~/Projects/project/media/ # sync remote directory files with local folder

tar --exclude='./folder' --exclude='./upload/folder2' -zcvf /backup/filename.tgz ./ # archive current directory
tar --exclude='./.git' --exclude='./var/cache' --exclude='./var/report' --exclude='./media/js' --exclude='./media/css_secure' --exclude='./media/cache' --exclude='./media/pdf_catalog' --exclude='./media/catalog' -zcvf ./filename.tgz ./ # archive current directory for M1
tar -xvf filename.tar # extract tar archive
gunzip -k filename.gz # extract gz archive, keeping archive file

du -hs ~/public_html/var/sessions # show size of a folder (or a file)
ls -l ~/public_html/var/sessions | wc -l # show number of files in a folder

du --max-depth=1 / 2>/dev/null | sort -r -k1,1n # sort directories by size with 1 level depth
find / -size +100M -ls 2>/dev/null # find files that are larger than 100Mb

find ./ -type f -name "js-translation.json" # search for the filename in current directory
grep --exclude-dir={generated,dev,setup,pub,var,.git,.idea,node_modules} -rnw './' -e 'searched text' # search for string in files

:%s/`searched_user`@`%`/`new_user`@`localhost`/gc # vim find and replace
vi +10 file.txt # open file on the specific line

sudo -H -u <username> bash -c 'ssh -Tv git@bitbucket.org' # run command as another user

#-----CentOs-----#

cat /etc/redhat-release # check Centos version

firewall-cmd --zone=public --add-service=http --permament # add apache (httpd) to public rule for iptables service (permanently)
firewall-cmd --zone=public --permanent --list-services # list all (permanent) public rules for iptables

vi /etc/php-fpm.d/www.conf # edit php-fpm configurations file
systemctl restart php-fpm

vi /etc/httpd/conf/httpd.conf # edit apache configurations file
vi /etc/httpd/conf.d/vhosts.conf # edit apache virtual hosts file
systemctl restart httpd

systemctl restart php-fpm && systemctl restart httpd

#-----Supervisor-----#

systemctl status supervisord
supervisorctl status # list active jobs
supervisorctl stop messenger-consume:* # enable pre-configured job

#-----Virtual host setup-----#

sudo service apache2 restart # restart apache 2

cd /etc/apache2/sites-available/ # goto apache2 sites directory
sudo cp mage.dev.conf <name of site>.conf # copy already existing config file

# edit created config

sudo subl /etc/hosts # add your site to the list

sudo a2ensite <name of site>.conf # enable site

cd /misc/apps/team_scripts/
sh ssl.sh <name of site> # setup https for site, generated lines input into <name of site>.conf

#-----MySql commands-----#

SHOW VARIABLES LIKE "%version%"; #check version
SHOW STATUS WHERE `variable_name` = 'Threads_connected'; # show number of current connections

SET GLOBAL max_allowed_packet=1073741824; # increase packet size when db is not extracting. after executing exit and re-login to mysql for changes to be applied

SELECT User FROM mysql.user; # show users
SELECT table_name, table_schema FROM INFORMATION_SCHEMA.COLUMNS WHERE column_name = '<needed_column>' AND table_schema = '<needed_db>'; # search for spesific column name in the database
SELECT SUM(ROUND(((data_length + index_length) / 1024 / 1024), 2)) AS "Size (MB)" FROM information_schema.TABLES WHERE table_schema = "db_name"; # get database size

SET PASSWORD FOR 'user-name-here'@'hostname' = PASSWORD('new-password'); # update password for mysql user, be root

mysql -u<user_name> -p # sigh in mysql

CREATE DATABASE <db_name>; # create db
DROP DATABASE <db_name>; # remove db

SHOW DATABASE; # show all DB
USE <db_name>; # get into database
SHOW TABLES; # show all tables of DB

SELECT DISTINCT TABLE_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME IN ('<column>') AND TABLE_SCHEMA = '<database>'; # find tables with a column

# Check and repair corrupted table
CHECK TABLE <table_name>;
REPAIR TABLE <table_name>;

mysql -u[username] -p[password] [dbname] --execute='SELECT * FROM core_config_data' # execute command directly from bash

mysqldump -u<user> -p <db_name> | gzip > <db_name>_$(date +'%Y-%m-%d_%H-%M').sql.gz # create zip dump of db with date
mysqldump -v --single-transaction -u<user> -p <db_name> | gzip > <db_name>_$(date +'%Y-%m-%d_%H-%M').sql.gz # safe variant of dump
mysql -u[username] -p[password] [dbname] -N -e 'show tables like "prefix\_%"' | xargs mysqldump -u[username] -p[password] [dbname] > [dump_file] # dump tables with specific prefix

USE <db_name>;
SOURCE <file_name.sql>; # import dump into db
docker exec -i mysql57 mysql -u<user> -p<password> <db_name> < <file_name.sql> # upload dump for docker mysql, you should be in dump's dir
docker exec -i mysql57 mysqldump -u<user> -p <db_name> | gzip > <db_name>_$(date +'%Y-%m-%d_%H-%M').sql.gz; # create dump for docker mysql

GRANT ALL ON <db_name>.* TO '<user_name>'@'localhost'; # gives user(s)(separated by coma) access to '<db_name>' DB
GRANT ALL ON <db_name>.* TO '<user_name>'@'localhost' IDENTIFIED BY '<password>'; # create new user and gives him access to <db_name> DB

ALTER USER 'user'@'hostname' IDENTIFIED BY 'newPass'; # set password to user

SHOW FULL PROCESSLIST\G # show active processes
KILL <process_id> # kill found process

UPDATE `catalog_product_entity_text` SET `value` = replace(`value`, '{{media url="/icons/herb.png"}}', '{{media url="icons/herb.png"}}'); # replace

UPDATE mytable
    SET column1 = value1,
        column2 = value2
    WHERE key_value = some_value; # update value of columns

ALTER TABLE mage_recently_visited_categories
    CHANGE user_id customer_id int(11); # rename table column name

# Remove all records from the table and reset key
DELETE FROM `catalog_product_entity`; # query to delete all products
ALTER TABLE `catalog_product_entity` AUTO_INCREMENT = 1; # then query to start product id from 1

# Remove user
SELECT User,Host FROM mysql.user; # view all users
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'user'@'localhost'; # disable privileges
DROP USER 'user'@'localhost'; # remove user

#-----Create Magento patch-----#

git clone https://github.com/magento/magento2.git
cd magento2
git checkout 2.3.3 # switch to your version
# do changes
git diff > file.patch
# remove app/code/Magento/Module path from patch file
# https://magento.stackexchange.com/a/256580

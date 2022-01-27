#!/bin/bash
read -p 'Имя БД: ' DbName
read -p 'Имя пользователя: '  userName

apt -y install curl wget software-properties-common apt-transport-https git nano php php-fpm nginx mysql-server phpmyadmin  &&
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add - &&
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" &&
apt install code &&
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &&
mysql -u root --execute="
UPDATE mysql.user SET plugin = 'mysql_native_password', authentication_string  = '' WHERE user = 'root';
" &&
systemctl restart mysql.service && systemctl status mysql.service &&
mysql -u root --execute="
CREATE DATABASE IF NOT EXISTS ${DbName};
GRANT ALL PRIVILEGES ON ${DbName}.* TO '${userName}'@'localhost';
" &&
echo 'Change rootAllowNoPassord in phpmyadmin settings\n' &&
echo '== Open nano ==' && sleep 1 &&
nano /etc/phpmyadmin/config.inc.php 

chmod -R g+w /var/www && chown -R www-data:www-data /var/www &&

read -p 'Создать новый проект ?[y/n] ' isCreateDomain

if [ ${isCreateDomain}="y" ]
then
sh ./createDomain.sh
else
echo '	Готово!'
fi


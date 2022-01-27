#!/bin/bash
DbName="phpdev_01"
ProjName="pma.my"
ProjRootPath="/var/www/${ProjName}"
MyAdminPath="/usr/share/phpmyadmin"

apt -y install curl wget software-properties-common apt-transport-https git nano php php-fpm nginx mysql-server phpmyadmin  &&
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | apt-key add - &&
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" &&
apt install code &&
mysql -u root --execute="
UPDATE mysql.user SET plugin = 'mysql_native_password', authentication_string  = '' WHERE user = 'root';
" &&
systemctl restart mysql.service && systemctl status mysql.service &&
mysql -u root --execute="
CREATE DATABASE IF NOT EXISTS ${DbName};
GRANT ALL PRIVILEGES ON ${DbName}.* TO 'phpmyadmin'@'localhost';
" &&
echo 'Change rootAllowNoPassord in phpmyadmin settings\n' &&
echo '== Open nano ==' && sleep 1 &&
nano /etc/phpmyadmin/config.inc.php &&

chmod g+w /var/www && chown -R www-data:www-data /var/www &&
mkdir -p ${ProjRootPath} && 
echo "server {
	listen 80;
	listen [::]:80;

	server_name ${ProjName};

	root ${varvarProjRootPath}
	index index.php index.html;
	
	access_log	/var/log/nginx/phpmyadmin.access.log;
	error_log	/var/log/nginx/phpmyadmin.error.log;

	charset utf-8;

	location / {
		if (-f \$request_filename) {
			expires max;
			break;
		}
		if (!-e \$request_filename) {
			rewrite ^(.*) /index.php last;
		}
	}
	
	location /phpmyadmin {
		root ${MyAdminPath};
		index index.php;
	}
	
	location ~ '^(.+\.php)(\$|/)' {
		fastcgi_param 	SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
		fastcgi_param 	SCRIPT_NAME	\$fastcgi_script_name;
		fastcgi_param 	PATH_INFO 	\$fastcgi_path_info;
		fastcgi_pass  	unix:/run/php/php7.4-fpm/sock;
		include   	fastcgi_params;
	}
}" > /etc/nginx/sites-available/${ProjName} &&
ln -s /etc/nginx/sites-available/${ProjName} /etc/nginx/sites-enabled/${ProjName} -f &&
echo "#local server for ${ProjName}\n127.0.0.1	${ProjName} " >> /etc/hosts &&
git clone https://github.com/DNSAndrv/phpdev-01.git /var/www/pma.my



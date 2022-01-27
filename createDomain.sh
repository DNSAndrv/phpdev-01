#!/bin/bash
read -p 'Название проекта: ' ProjName
ProjRootPath="/var/www/${ProjName}"

mkdir -p ${ProjRootPath} && mkdir -p ${ProjRootPath}/conf && 

echo "server {
	listen 80;
	listen [::]:80;

	server_name ${ProjName};

	root ${ProjRootPath};
	index index.php index.html;
	
	access_log	/var/log/nginx/${ProjName}.access.log;
	error_log	/var/log/nginx/${ProjName}.error.log;

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
	
	location ~ '^(.+\.php)(\$|/)' {
		fastcgi_param 	SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
		fastcgi_param 	SCRIPT_NAME	\$fastcgi_script_name;
		fastcgi_param 	PATH_INFO 	\$fastcgi_path_info;
		fastcgi_pass  	unix:/run/php/php7.4-fpm.sock;
		include   	fastcgi_params;
	}
}" > ${ProjRootPath}/conf/nginx.local &&

ln -s ${ProjRootPath}/conf/nginx.local /etc/nginx/sites-enabled/${ProjName} -f &&

echo "#local server for ${ProjName}.my\n127.0.0.1	${ProjName}" >> /etc/hosts &&

chmod g+w /var/www && chown -R www-data:www-data /var/www &&
service nginx reload &&
echo  '
<html>
<body>
<h1>Autocreated by script</h1>
</body>
</html>' >> ${ProjRootPath}/index.html
echo "-- Проект созван в папке ${ProjRootPath} --"




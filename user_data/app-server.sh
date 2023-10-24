#!/bin/bash
hostname=$(cat /etc/hostname | tr -d '\n')
yum install httpd -q -y
cat << EOF > /etc/httpd/conf.d/app-server.conf
<VirtualHost *:80>
  ServerName $hostname
  DocumentRoot /var/www/html
</VirtualHost>
EOF
cat << EOF > /var/www/html/index.html
<html>
  <head>
    <title>$hostname</title>
  </head>
  <body>
    <h2>$hostname</h2>
  </body>
</html>
EOF
systemctl enable httpd -q
systemctl start httpd

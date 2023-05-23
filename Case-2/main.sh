sudo yum install httpd -y
sudo service httpd start
sudo chmod -R 777 /var/www/html/
echo "hello world" >> /var/www/html/index.html
sudo service httpd restart
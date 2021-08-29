#!/bin/bash

name="Shubham"
s3_bucket="upgrad-shubham"
timestamp=$(date '+%d%m%Y-%H%M%S')

echo "Updating Pacakge"

sudo apt update -y

echo "Checking whether Apache HTTP is installed ?"

dpkg-query -W apache2 
if [ $? -eq 0 ]; 
then
 echo "Apache2 is installed."
else
 echo "Installing Apache2 on server"
sudo apt install apache2 -y
fi

echo "Checking whether Process is running or not"

ps cax | grep httpd
if [ $? -eq 0 ]; then
 echo "Process is running."
else
 echo "Starting the process"
 systemctl start apache2
fi

echo "Checking whether service is enabled or not "

servicestat=$(systemctl status apache2)
if [[ $servicestat == *"active (running)"* ]];
then
echo " Service is enabled "
else
echo "service enabling..."
 systemctl enable apache2
fi


cd /var/log/apache2

find  -name "*.log" | tar -cvf /tmp/${name}-httpd-logs-${timestamp}.tar /var/log/apache2

echo "Tar file created and placed at desired location"

aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar  s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar

echo "Tar file is copied to desired S3 Bucket"

#!/bin/bash

#Variables Declaration and Initialization
name="Shubham"
s3_bucket="upgrad-shubham"
timestamp=$(date '+%d%m%Y-%H%M%S')

#Part-2 : Hosting Web Server

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

#part -2 : Archiving Logs

cd /var/log/apache2

find  -name "*.log" | tar -cvf /tmp/${name}-httpd-logs-${timestamp}.tar /var/log/apache2

Size=$(du -sh /tmp/${name}-httpd-logs-${timestamp}.tar |  awk '{print $1}')

echo "Tar file created and placed at desired location"

aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar  s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar

echo "Tar file is copied to desired S3 Bucket"


#Part -3 : Bookkeeping

Log_type="httpd-logs"
Type="tar"

FILE=/var/www/html/inventory.html

if [[ -f "$FILE" ]];then
  echo "$FILE exists"
else
cd /var/www/html
touch inventory.html
echo -e 'Log Type \t Time Created \t\t Type \t Size' >> inventory.html
echo "Inventory File created"
fi

echo -e "<td><tr>${Log_type} \t  ${timestamp} \t ${Type} \t ${Size}</tr></td>"  >> /var/www/html/inventory.html

echo "Meta data copied to inventory.html"

#part -3 :Cron Job 

CRON=/etc/cron.d/automation

if [[ -f "$CRON" ]];then
echo "Cron Job file exists "
else
touch /etc/cron.d/automation
echo "40 * 29 8 0-7 root /root/Automation_Project/automation.sh" >> /etc/cron.d/automation
echo "CRON File created"
fi



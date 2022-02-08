#!/bin/bash

umask 0022      # give 'group' and 'others' write permission 

cd $HOME
mkdir .pypiinfo
cd .pypiinfo

echo "====> get service file and pypi-info.py"
curl -sL -o pypi-info.service https://raw.githubusercontent.com/juggledad/pypi-info/main/pypi-info.service
curl -sL -o pypi-info.py https://raw.githubusercontent.com/juggledad/pypi-info/main/pypi-info.py 
curl -sL -o pypiconfig.py https://raw.githubusercontent.com/juggledad/pypi-info/main/pypiconfig.py 

echo "====> remove old pypi-info.service file if it exists"
sudo rm /lib/systemd/system/pypi_info.service

echo "====> move pypi-info.service.temp to /lib/systemd/system/ and rename"
sudo mv pypi-info.service /lib/systemd/system/pypi-info.service

echo "====> install python3-pip and paho-mqtt"
sudo apt update
#sudo apt upgrade -y
sudo apt install python3 -y
sudo apt install python3-pip -y
sudo pip3 install paho-mqtt

echo "====> enable the pypi-info.service"
sudo systemctl enable pypi-info.service
sudo systemctl daemon-reload
sudo systemctl start pypi-info.service
sudo systemctl status pypi-info.service
echo "You might want to reboot"

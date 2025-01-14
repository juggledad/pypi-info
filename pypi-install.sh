#!/bin/bash

umask 0022      # give 'group' and 'others' write permission 

cd $HOME
mkdir pypiinfo
cd pypiinfo

echo "====> get service file and pypi-info.py"
curl -sL -o pypi-info.service https://raw.githubusercontent.com/juggledad/pypi-info/main/pypi-info.service
curl -sL -o pypi-info.py https://raw.githubusercontent.com/juggledad/pypi-info/main/pypi-info.py 
curl -sL -o pypiconfig.py https://raw.githubusercontent.com/juggledad/pypi-info/main/pypiconfig.py 


echo "====> remove old pypi_info.service and pypi-info.service file if they exists"
sudo rm /lib/systemd/system/pypi_info.service
sudo rm /lib/systemd/system/pypi-info.service

echo "====> move pypi-info.service.temp to /etc/systemd/user"
echo "====> and pypi-info.py and pypiconfig.py to /usr/local/bin"
sudo mv pypi-info.service /lib/systemd/system/pypi-info.service
sudo mv pypi-info.py /usr/local/bin/pypi-info.py
sudo mv pypiconfig.py /usr/local/bin/pypiconfig.py
cd $HOME
sudo rm -rf pypiinfo
sudo rm -rf .pypiinfo

echo "====> install python3-pip and paho-mqtt or python3-paho-matt"
sudo apt update
sudo apt full-upgrade -y
sudo apt install python3 -y
sudo apt install python3-pip -y

. /etc/os-release
NAME=$VERSION_CODENAME
echo '======================================='
if [[ $NAME == "bookworm" ]]
then
   sudo pip3 install python3-paho-mqtt
else
   sudo pip3 install paho-mqtt
fi

sudo pip3 install paho-mqtt

echo "====> enable the pypi-info.service"
sudo systemctl stop pypi-info.service
sudo systemctl disable pypi-info.service
sudo systemctl daemon-reload
sudo systemctl enable pypi-info.service
sudo systemctl start pypi-info.service
sudo systemctl daemon-reload
sudo systemctl status pypi-info.service
echo "You might want to reboot"

#!/bin/bash
# sudo chmod u+x testpypi.sh
cd $HOME
mkdir .pypiinfo
cd .pypiinfo
curl -sL -o pypi_info.service.temp https://raw.githubusercontent.com/juggledad/pypi-info/main/pypi-info.service
curl -sL -o pypi_info.service.temp https://raw.githubusercontent.com/juggledad/pypi-info/main/pypi-info.py
curl -sL -o pypi_info.service.temp https://raw.githubusercontent.com/juggledad/pypi-info/main/pypi-config.py

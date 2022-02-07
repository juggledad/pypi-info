# pypi-info
Python program to process commands sent by MQTT

**pypi-info.py** is designed to be installed on one or more Pi's[^1] and will run when the Pi is booted (using **systemd**). It will wait to receive MQTT messages, processes the command in the message and then publish the results. 

It subscribes to the MQTT topic: 
```
pypi_info/command/#
```

Example: the incoming msg could have the topic **pypi_info/command/ip** and the msg content would be **{"ip": "hostname -I"}** or you might have a topic of **pypi_info/command/osrelease** with a msg content of **{"osrelease":"cat /etc/os-release"}**

After parsing and running the command, the results will publish results using the topic: 
```
**pypi_info/result/C/H**  
```
where **C** is the name of the command from part three of the incoming topic and **H** is the hostname of the PI. The msg data will 
be an object containing the contents of **stdout** and **stderr** from the execution of the command. 

# Walkthru
Example 1: The Node-RED flow publishes a msg with the topic:
```
pypi_info/command/temperature
```
and the msg data is:
```
{"temperature": "/opt/vc/bin/vcgencmd measure_temp"}
```
**pypi-info.py** gets the hostname of the pi (let's say the hostname is 'testpi'), parses the object passed to it and runs the command (using **subprocess.Popen**). It then retreives stdout and stderr and builds an object with the contents of them and publishes the results. In out example the topic would be:
```
pypi_info/results/temperature/testpi
```
and the data might look like
```
{"host":"fastpi", "command":"temperature", "stdout": "temp=45.6'C\n", "stderr": ""}
```
Example 2: We want to find out what version of **Influx** is installed (in this case it is not). The topic would be
```
pypi_info/command/influx
```
and the msg data would be
```
{"influx":"influx -v"}
```
Since Influx is not installed, results will be a topic of
```
pypi_info/results/influx/testpi
```
and msg data will be
```
{"host":"fastpi", "command":"influx","stdout": "", "stderr": "/bin/sh: 1: influx: not found\n"}
```
The application receiving the data (Node-RED in my case) needs to be able to handle both cases - where there is data in stdout and, if an error occured, data in stderr.

# PyPi-Info.flow
This flow can be set to periodically run a series of commands. All Pi's with **pypi_info.py** installed will process the command and return the results. The flow will parse the results and create/update a flow variable (based on the hostname)to store the results.

Eventually the flow will be adapted to store the data (one row for each Pi) in an SQLite database and a database will be created to siaplay the results.

# Installation
open a terminal on your Raspberry Pi. copy 
Running the following command will download and run the script **pypi-install.sh**. If you want to review the contents of the script first, you can view it [here](https://github.com/juggledad/pypi-info/blob/main/pypi-install.sh).
```
bash <(curl -sL https://raw.githubusercontent.com/juggledad/pypi-info/main/pypi-install.sh)
```

[^1]: pypi-info.py might run on other devices, it just hasn't been tested.

# pypi-info
Python program to process commands sent by MQTT

**pypi_info.py** is designed to be installed on one or more Pi's[^1] and will run when the Pi is booted (using **systemd**). It will wait to receive MQTT messages, processes the command in the message and then publish the results.  
It subscribes to the MQTT topic: **pypi_info/command/#**     
Example: the incoming msg could have the topic **pypi_info/command/ip** and the msg content would be **{"ip": "hostname -I"}** or you might have a topic of **pypi_info/command/osrelease** with a msg content of **{"osrelease":"cat /etc/os-release"}**

After parsing and running the command, **pypi_info.py** will publish results using the topic:  
**pypi_info/result/C/H**  
where **C** is the name of the command from part three of the incoming topic and **H** is the hostname of the PI. The msg data will 
be an object containing the **stdout** and **stderr** from the execution of the command. 

# Walkthru
Example 1: The Node-RED flow publishes a topic of **pypi_info/command/temperature** and the msg data is **{"temperature": "/opt/vc/bin/vcgencmd measure_temp"}**  
pypi_info.py gets the hostname of the pi (let's say the hostname is 'testpi'), parses the object passed to it and runs the command (using **subprocess.Popen**).   
It then retreives stdout and stderr and builds an object with the contents of them and publishes the results. In out example the topic would be **pypi_info/results/temperature/testpi** and the data might look like **{"host":"fastpi", "command":"temperature", "stdout": "temp=45.6'C\n", "stderr": ""}**  

Example 2: We want to find out what version of **Influx** is installed (in this case it is not). The topic would be **pypi_info/command/influx** and the msg data would be **{"influx":"influx -v"}**
Since Influx is not installed, results will be a topic of **pypi_info/results/influx/testpi** and msg data will be **{"host":"fastpi", "command":"influx","stdout": "", "stderr": "/bin/sh: 1: influx: not found\n"}** The Node-RED flow needs to be able to handle both sitations.

#Node-RED flow
The Flow will periodically run a series of commands that all Pi's with **pypi_info.py** installed will process and return their results. The flow will parse the results and create/update a row for that Pi in an SQLite database. The database will then be read and the information displayed in a dashboard.

[^1]: pypi_info.py might run on other devices, it just hasn't been tested.

#!/usr/bin/env python
############################################################################## 
# 
# Name       : pypi-info.py
# GitHub     : https://github.com/juggledad/pypi-info
# Author     : Paul M Woodard
# License    : Apache License 2.0
# Copyright  : 2022
#
# Description: This program processes commands and returns results via MQTT.
# subscribe topic: "pypi_info/command/#"
# publish topic  : "pypi_info/result/C/H" where 
#                   C= the command 
#                   H= hostname of the PI
# the content of the command is in the format: {"command id": "actual command"} 
# example: {"ip": "hostname -I"}
#          {"osrelease":"cat /etc/os-release"}
# the result will be returned in json format with stdout and stderr
# example: {"stdout": "192.168.48.243 \n", "stderr": ""}
#
##############################################################################

import paho.mqtt.client as mqtt
import time
import socket
import subprocess  
import json
  
# ---------------------------------------------------------
# enter your MQTT broker's IP or hostname in pypi-config.py
# ---------------------------------------------------------
import pypi_config
broker_address = pypi-config.broker

hostname = socket.gethostname()
connection_topic = "pypi_info/connected/connected/hostname"
subscribe_topic  = "pypi_info/command/#"
publish_topic    = "pypi_info/results/"  # the rest of the reply topic will be built later

result_dict = {}

# ----------------------------------------
# MQTT connect
# ----------------------------------------
def on_connect(client, obj, flags, rc):
#    print ("We are connected to the broker")
    client.subscribe("connection_topic", 0)


# ----------------------------------------
# MQTT subscribe
# ----------------------------------------
def on_subscribe(client, userdata, mid, granted_qos):
#    print ('Subscribed:', userdata, mid, granted_qos)
    print ('We have subscribed to topics, waiting...to be killed')

# ----------------------------------------
# message processing code
# ----------------------------------------
def on_message(client, userdata, message):
    y = json.loads(message.payload.decode("utf-8"))

    global th_abort
 
    if "abort" in message.payload.decode("utf-8"):
        client.publish(publish_topic+"/"+hostname, "closing pypi_info.py", 0)
        th_abort = True
        
    # grab command from incoming topic to put in reply topic
    topic = message.topic
    topic = topic.split("/")
    command = topic[2]
    topic = publish_topic+command+"/"+hostname

    cmd_with_options = y[command]

    # run the command
    process = subprocess.Popen(cmd_with_options, 
                      shell=True,
                      stdout = subprocess.PIPE, 
                      stderr = subprocess.PIPE, 
                      universal_newlines=True) 
    # get the output as a array
    output = process.communicate()
    print("stdout= ", output[0], "stderr= ", output[1]) #

    # build a python dictionary and create a json result
    result_dict["hostname"] = hostname
    result_dict["command"]  = command
    result_dict["stdout"]   = output[0]
    result_dict["stderr"]   = output[1]
    result_json = json.dumps(result_dict)

    # publish the result 
    client.publish(topic, result_json, 0) 

# ----------------------------------------
# Starting code
# ----------------------------------------
th_abort = False
client   = mqtt.Client() #create new instance

client.on_connect   = on_connect
client.on_subscribe = on_subscribe
client.on_message   = on_message

resp = client.connect(broker_address)
client.subscribe(subscribe_topic)

# ----------------------------------------
# client.loop_start
# ----------------------------------------
client.loop_start()
result, mid = client.publish("result/data", "Just testing MQTT", 0)

t = 5
while t == 5 and not th_abort:
    time.sleep(0.1)
client.loop_stop()
client.disconnect()
print ("pypi_info.py stopped...")
exit()

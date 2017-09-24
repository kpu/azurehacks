#!/usr/bin/python2
import json
import subprocess

def query(command):
  return json.load(subprocess.Popen(command, stdout=subprocess.PIPE).stdout)

count = {}

vmss = query(["az", "vmss", "list"])
for ss in vmss:
  l = ss['location']
  sku = ss['sku']['name']
  if sku not in count:
    count[sku] = 0
  for m in query(["az", "vmss", "get-instance-view", "-g", ss['resourceGroup'], "-n", ss['name'], "-o", "json", "--instance-id", "*"]):
    if m['instanceView']['statuses'][1]['code'] == u'PowerState/running':
      count[sku] += 1

for single in query(["az", "vm", "list", "-o", "json"]):
  for status in query(["az", "vm", "get-instance-view", "-g", single['resourceGroup'], "-n", single['name']])['instanceView']['statuses']:
    if status['code'] == 'PowerState/running':
      key = single['hardwareProfile']['vmSize']
      if key not in count:
        count[key] = 0
      count[key] += 1
    
for key, value in count.items():
  print(key,value) 

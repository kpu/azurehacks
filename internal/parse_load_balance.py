#!/usr/bin/env python3
#Parses the output of az network lb show --resource-group $resource --name ${name}LB -o json
#Prints a table of instanceId and port.
import sys
import json
if len(sys.argv) == 2:
  ip = " " + sys.argv[1]
else:
  ip = ""
for m in json.load(sys.stdin)['inboundNatRules']:
  print(m['name'].split('.')[-1] + ' ' + str(m['frontendPort']) + ip)

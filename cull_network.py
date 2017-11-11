#!/usr/bin/env python2
#Print commands to delete load balancers, NICs, and IPs not attached to any VM
#Plenty of bugs here.  Assumes a stock setup with nothing fancy.
import json
import subprocess

def query(command):
  return json.load(subprocess.Popen(command, stdout=subprocess.PIPE).stdout)

lb = query(["az", "network", "lb", "list", "-o", "json"])
vmss = query(["az", "vmss", "list", "-o", "json"])

in_use_lbs = []
for m in vmss:
  balancer = m["virtualMachineProfile"]["networkProfile"]["networkInterfaceConfigurations"][0]["ipConfigurations"][0]["loadBalancerBackendAddressPools"]
  if balancer:
    in_use_lbs.append('/'.join(balancer[0]["id"].split('/')[0:9]))
 
allocated_lbs = ['/'.join(l["frontendIpConfigurations"][0]["id"].split('/')[0:9]) for l in lb]

unused_lbs = set(allocated_lbs) - set(in_use_lbs)
for l in unused_lbs:
  split = l.split('/')
  print "az network lb delete -g " +  split[4] +  " -n " + split[8]

#TODO: exclude the lbs that are to be deleted
ip_used_by_lb = []
for l in lb:
  public_ip = l["frontendIpConfigurations"][0]["publicIpAddress"]
  if public_ip:
    ip_used_by_lb.append(public_ip["id"])

vm = query(["az", "vm", "list", "-o", "json"])
in_use_nics = [v["networkProfile"]["networkInterfaces"][0]["id"] for v in vm]
nics = query(["az", "network", "nic", "list", "-o", "json"])
allocated_nics = [n["id"] for n in nics]
for n in set(allocated_nics) - set(in_use_nics):
  split = n.split('/')
  print "az network nic delete -g " + split[4] + " -n " + split[8]

#TODO: exclude the nics that are to be deleted
ip_used_by_nic = [n["ipConfigurations"][0]["publicIpAddress"]["id"] for n in nics]
in_use_ips = ip_used_by_lb + ip_used_by_nic

allocated_ips = [i["id"] for i in query(["az", "network", "public-ip", "list", "-o", "json"])]
for i in set(allocated_ips) - set(in_use_ips):
  split = i.split('/')
  print "az network public-ip delete -g " + split[4] + " -n " + split[8]

nsg_all = [n['id'] for n in query(["az", "network", "nsg", "list", "-o", "json"])]
nsg_in_use = set()
for n in nics:
  if n['networkSecurityGroup']:
    nsg_in_use.add(n['networkSecurityGroup']['id'])

for i in set(nsg_all) - nsg_in_use:
  split = i.split('/')
  print "az network nsg delete -g " + split[4] + " -n " + split[8]

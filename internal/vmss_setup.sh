#!/bin/bash
set -e
#Arguments are host:port --resource-group $resource --name $name
#Take one argument as host:port
port=$(cut -d : -f 2 <<<$1)
host=$(cut -d : -f 1 <<<$1)
shift
#Accept host keys :-(
if ! ssh-keyscan -p $port $host >>~/.ssh/known_hosts 2>/dev/null; then
  echo $host:$port does not seem to be up, might be hallucinated 1>&2
  exit 1
fi
#Copy azure credentials over and make delete/deallocate commands
(echo $@ --instance-ids '$(printf %d 0x${HOSTNAME: -7:7})'; cd ~; tar c .azure) |ssh -p $port $host 'read a; echo -e '\''#!/bin/bash\n'\''az vmss deallocate $a >deallocate && echo -e '\''#!/bin/bash\n'\''az vmss delete-instances $a >delete && chmod +x deallocate delete && tar x && sudo mv deallocate delete /bin'
#Print hosts in GNU parallel format
echo 1/ssh -p $port $host

#!/bin/bash
set -e
#Arguments are instance port host --resource-group $resource --name $name
instance=$1
port=$2
host=$3
shift 3
#Accept host keys :-(
if ! ssh-keyscan -p $port $host >>~/.ssh/known_hosts 2>/dev/null; then
  echo $host:$port does not seem to be up, might be hallucinated 1>&2
  exit 1
fi
#Copy azure credentials over and make delete/deallocate commands
(echo $@ --instance-ids $instance; cd ~; tar c .azure) |ssh -p $port $host 'read a; echo -e '\''#!/bin/bash\n'\''az vmss deallocate $a >deallocate && echo -e '\''#!/bin/bash\n'\''az vmss delete-instances $a >delete && chmod +x deallocate delete && tar x && sudo mv deallocate delete /bin'
echo ssh -p $port $host "  #id $instance"

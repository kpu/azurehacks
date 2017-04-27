#!/bin/bash
set -e -o pipefail
if [ $# != 4 ]; then
  cat 1>&2 <<EOF
Usage: $0 --resource-group group --name name
Where name is the name of a VM scale set."

This script:
1. Insecurely gets SSH host keys and adds them to your ~/.ssh/known_hosts .
2. Copies your ~/.azure to the machines so they have command line access.
3. Installs delete and deallocate commands so you can stop them from inside.
4. Prints SSH connection information.
EOF
  exit 1
fi
ip=$(az vmss list-instance-connection-info $@ --output tsv | head -n 1 | cut -d : -f 1)
echo IP address $ip 1>&2
az network lb show $1 $2 $3 ${4}LB --o json | \
  "$(dirname "$0")"/internal/parse_load_balance.py $ip | \
  parallel --gnu --no-notice --colsep ' ' "$(dirname "$0")"/internal/vmss_setup.sh {} $@

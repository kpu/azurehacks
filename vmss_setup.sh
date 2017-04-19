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
4. Prints connection information in GNU parallel --sshloginfile format:
     $0 --resource-group group --name name >hosts
     parallel --sshloginfile hosts <commands
EOF
  exit 1
fi
az vmss list-instance-connection-info $@ --output tsv |parallel --gnu --no-notice "$(dirname "$0")"/internal/vmss_setup.sh {} $@

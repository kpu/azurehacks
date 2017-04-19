#!/bin/bash
set -e
if ([ "$1" != "--resource-group" ] && [ "$1" != "-g" ]) || ([ "$3" != "--name" ] && [ "$3" != "-n" ]); then
  cat 1>&2 <<EOF
Usage: $0 --resource-group group --name name ...
All arguments are forwarded to az vmss create, so see that for help.
However, you must have --resource-group group --name name at the beginning.
That way they can be passed to $(dirname "$0")/vmss_setup.sh
EOF
fi
az vmss create "$@"
"$(dirname "$0")"/vmss_setup.sh $1 $2 $3 $4

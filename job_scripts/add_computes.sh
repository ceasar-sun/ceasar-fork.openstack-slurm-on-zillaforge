#!/bin/bash

set -e

NODE_LIST=$1

KOLLA_CMDS=("bootstrap-servers" "prechecks" "pull" "deploy")

for cmd in "${KOLLA_CMDS[@]}"; do
    echo "Run $cmd ..."
        kolla-ansible $cmd -i /etc/kolla/inventroy/ --limit $NODE_LIST
done

echo "Expanding Compute to existing cluster finished."
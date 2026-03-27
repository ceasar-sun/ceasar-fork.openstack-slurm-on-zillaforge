#!/bin/bash

set -e

NODE_LIST=$1

KOLLA_CMDS=("bootstrap-servers" "prechecks" "pull" "deploy")

for cmd in "${KOLLA_CMDS[@]}"; do
    echo "Run $cmd ..."
        kolla-ansible $cmd -i /etc/kolla/inventroy/ --limit $NODE_LIST
done

echo "Expanding Compute to existing cluster finised, wait for Recycle signal."
# 當收到 SIGUSR1 訊號時，印出訊息並正常退出 (exit 0)
trap "echo 'Receive recycle signal, exit...'; exit 0" SIGUSR1
sleep infinity &
wait
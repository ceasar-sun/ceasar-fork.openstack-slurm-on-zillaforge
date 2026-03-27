#!/bin/bash

set -e

NODE_LIST=$1

if [ -z "$NODE_LIST" ]; then
    echo "錯誤: 未提供 NODE_LIST"
    exit 1
fi

## TODO: 
source /etc/kolla/admin-openrc.sh

IFS=',' read -ra NODES <<< "$NODE_LIST"

for NODE_NAME in "${NODES[@]}"; do
  echo "停用 Nova compute: $NODE_NAME"
  openstack compute service set --disable $NODE_NAME nova-compute
done

echo "執行 kolla-ansible stop..."
kolla-ansible stop -i /etc/kolla/inventroy/ --limit $NODE_LIST --yes-i-really-really-mean-it

for NODE_NAME in "${NODES[@]}"; do
  echo "清理網路與運算服務: $NODE_NAME"
  openstack network agent list --host $NODE_NAME -f value -c ID | while read id; do
    openstack network agent delete $id
  done

  openstack compute service list --host $NODE_NAME -f value -c ID | while read id; do
    openstack compute service delete $id
  done
done

echo "執行 kolla-ansible destroy..."
kolla-ansible destroy -i /etc/kolla/inventroy/ --limit $NODE_LIST --yes-i-really-really-mean-it

echo "腳本執行完畢。"


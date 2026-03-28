#!/bin/bash
# 檔案名稱: submit.sh
#SBATCH --exclusive       # 獨佔節點

set -e
set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

if [ -n "$PROJECT_DIR" ]; then
    # Injected by make via --export (sbatch through make targets)
    PAYLOAD_DIR="${PAYLOAD_DIR:-$PROJECT_DIR/job_scripts}"
elif [ -f "$SCRIPT_DIR/add_computes.sh" ]; then
    # dirname "$0" is reliable (srun or direct bash execution)
    PROJECT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
    PAYLOAD_DIR="$SCRIPT_DIR"
else
    # sbatch copied script to spool dir; fall back to SLURM_SUBMIT_DIR.
    # Assumes `sbatch submit.sh` was run from the job_scripts/ directory.
    PAYLOAD_DIR=$(cd "$SLURM_SUBMIT_DIR" && pwd)
    PROJECT_DIR=$(cd "$SLURM_SUBMIT_DIR/.." && pwd)
fi

# 1. 接收外部傳入的參數
ACTION=$1

# ONLY required for del_computes.sh
OCCUPY_JOB_ID=$2

if [ "$ACTION" = "add" ]; then
    NODE_LIST=$(scontrol show hostnames | paste -sd ',')
    PAYLOAD_SCRIPT="add_computes.sh"
elif [ "$ACTION" = "del" ]; then
    NODE_LIST=$(scontrol show hostnames $(squeue -j $OCCUPY_JOB_ID -h -o "%N") | paste -sd, -)
    PAYLOAD_SCRIPT="del_computes.sh"
else
    echo "Usage: submit <add|del> [OCCUPY_JOB_ID]"
    exit 1
fi

# 2. 換成實際包含 openstack-cli 與 kolla-ansible 的映像檔路徑
IMAGE_PATH="$PROJECT_DIR/kolla-ansible.sif"

# 3. 設定要掛載進容器的目錄 (Bind Mounts)
BIND_ARGS="-B $PROJECT_DIR/kolla-ansible/etc/kolla/:/etc/kolla -B $PROJECT_DIR/kolla-ansible/etc/openstack/:/etc/openstack"

# 4. 啟動 Singularity 並執行 payload.sh
echo "開始執行 $PAYLOAD_SCRIPT Job，目標節點: $NODE_LIST"

if [ "$ACTION" = "add" ]; then
    # 背景執行，讓 submit.sh 的 wait 能被 SIGUSR1 中斷並觸發 trap
    singularity exec $BIND_ARGS $IMAGE_PATH bash "$PAYLOAD_DIR/$PAYLOAD_SCRIPT" $NODE_LIST

    echo "Expanding Compute to existing cluster finished, wait for Recycle signal."
    trap 'echo "Receive recycle signal, exit..."; exit 0' SIGUSR1
    # 關閉 set -e，避免 wait 被信號中斷時因非零返回值直接退出（繞過 trap）
    set +e
    sleep infinity &
    wait $!
    set -e
else
    singularity exec $BIND_ARGS $IMAGE_PATH bash "$PAYLOAD_DIR/$PAYLOAD_SCRIPT" $NODE_LIST

    # send SIGUSR1 讓 expand job graceful exit
    scancel --batch --signal=SIGUSR1 $OCCUPY_JOB_ID
    echo "回收先前佔位 Job, ID: $OCCUPY_JOB_ID。"
fi

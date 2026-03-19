# 資源動態調度


## Prepare Terraform Container Environment

```shell
make terraform-container
```

## Setup Slurm

```shell
cd /workspace/infra_slurm

terraform init
terraform plan
terraform apply

## ssh to slurm headnode
ssh cloud-user@x.x.x.x
```


## Setup OpenStack

```shell
## execute in terraform container
cd /workspace/infra_openstack

terraform init
terraform plan
terraform apply

# ssh to openstack bastion
ssh cloud-user@y.y.y.y

## execute in opnestack bastion
cd ~/resource_manage
# build and launch kolla-ansible via docker compose
make kolla-up

# access kolla-ansible container as kolla user
make kolla-exec

# generate password
kolla-genpwd

# kolla-ansible deploy step
kolla-ansible bootstrap-servers -i /etc/kolla/inventroy/
kolla-ansible prechecks         -i /etc/kolla/inventroy/
kolla-ansible pull              -i /etc/kolla/inventroy/
kolla-ansible deploy            -i /etc/kolla/inventroy/
kolla-ansible post-deploy       -i /etc/kolla/inventroy/
```



## RoadMap

* [x] Setup infrastructure from Terraform
    * [x] OpenStack
    * [x] Slurm

* [ ] Run Kolla-Ansible in Conatiner
    * [x] Docker Container
    * [ ] Singularity Container
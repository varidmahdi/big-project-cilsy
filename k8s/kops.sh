#!/bin/bash
## notes
# requirement tools
# 1. install aws cli
# 2. install kubectl
# 3. install kops

# requirement aws
# 1. persiapkan iam user kops
# 2. persiapkan iam group kops
# 3. attach policies ke group kops
# 4. pasang domain pada route53
# 5. persiapkan certifikat ssl
# 6. persiapkan s3 bucket

export KOPS_CLUSTER_NAME=lokaljuara.id
export KOPS_STATE_STORE=s3://k8scilsy.lokaljuara.id

kops create cluster --node-count=1 --node-size=t3a.small --master-size=t3a.small --zones=us-east-1a --name=${KOPS_CLUSTER_NAME} --ssh-public-key=d:/ssh_key/id_rsa.pub --cloud=aws --cloud-labels="Cost=bigProjectCilsy"

kops edit ig --name=${KOPS_CLUSTER_NAME} nodes-us-east-1a
kops edit ig --name=${KOPS_CLUSTER_NAME} master-us-east-1a

kops update cluster --name=${KOPS_CLUSTER_NAME} --yes --admin

kops rolling-update cluster --cloudonly

kops validate cluster --wait 10m

kops delete cluster --name=${KOPS_CLUSTER_NAME} --yes
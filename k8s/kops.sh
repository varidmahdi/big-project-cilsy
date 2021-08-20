#!/bin/bash

export KOPS_CLUSTER_NAME=lokaljuara.id
export KOPS_STATE_STORE=s3://k8scilsy.lokaljuara.id

kops create cluster --node-count=1 --node-size=t3a.small --master-size=t3a.small --zones=us-east-1a --name=${KOPS_CLUSTER_NAME} --ssh-public-key=d:/ssh_key/id_rsa.pub --cloud=aws --cloud-labels="Cost=bigProjectCilsy"

kops update cluster --name=${KOPS_CLUSTER_NAME} --yes --admin

kops rolling-update cluster --cloudonly

kops validate cluster --wait 10m

kops delete cluster --name=${KOPS_CLUSTER_NAME} --yes
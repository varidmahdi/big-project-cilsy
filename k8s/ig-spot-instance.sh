apiVersion: kops.k8s.io/v1alpha2
kind: InstanceGroup
metadata:
  creationTimestamp: "2021-08-19T07:24:51Z"
  generation: 1
  labels:
    kops.k8s.io/cluster: k8scilsy.lokaljuara.id
  name: master-us-east-1a
spec:
  image: 099720109477/ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20210720
  machineType: t3a.small
  maxPrice: "0.0057"
  maxSize: 1
  minSize: 1
  mixedInstancesPolicy:
    instances:
    - t3a.small
    - t3.small
    - t3a.medium
    - t3.medium
    onDemandAboveBase: 0
    onDemandBase: 0
    spotAllocationStrategy: capacity-optimized
  nodeLabels:
    kops.k8s.io/instancegroup: master-us-east-1a
  role: Master
  subnets:
  - us-east-1a

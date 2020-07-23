#!/bin/bash
#
#
#
#
CLUSTER=mediaflow
NODEGROUP=mediaflow
IAMID=eks-cladmin
FARGATEID=eks-fargate
REGION=us-east-1
DEBUG=3
NODETYPE=t2.small
STARTWITH=3
MIN=2
MAX=5

#
#     --nodegroup-name string          name of the nodegroup (generated if unspecified, e.g. "ng-a85ce3f1")
#      --without-nodegroup              if set, initial nodegroup will not be created
#  -t, --node-type string               node instance type (default "m5.large")
#  -N, --nodes int                      total number of nodes (for a static ASG) (default 2)
#  -m, --nodes-min int                  minimum nodes in ASG (default 2)
#  -M, --nodes-max int                  maximum nodes in ASG (default 2)

printf "Running aws configure. Apply credentials \n"
aws configure 

printf "Generate the key for the env \n"
./mk_keys.sh
printf "Create the $CLUSTER cluster \n"
eksctl create cluster --version 1.17 --name=$CLUSTER -v$DEBUG  --nodegroup-name=mediaflow -t $NODETYPE -N $STARTWITH -m $MIN -M $MAX


printf "Enable Monitoringand Logging (temporarily. Eval costs) \n"
#eksctl utils update-cluster-logging --region=$REGION --cluster=$CLUSTER

eksctl utils update-cluster-logging --region=$REGION --cluster=$CLUSTER --enable-types scheduler --approve  
eksctl utils update-cluster-logging --region=$REGION --cluster=$CLUSTER --enable-types controllerManager --approve  

printf "Create the IAM ID \n"
eksctl create iamserviceaccount $IAMID 

printf "Create the IAM ID \n"
eksctl create fargateprofile $FARGATEID
printf "Create the EBS volumes for the environment \n"
../tt-complete/scripts/create-ebs-volumes.sh

#printf "Create nodegroup $NODEGROUP #NOT ALLOWED
#eksctl create nodegroup  $NODEGROUP"

#  eksctl create fargateprofile                  Create a Fargate profile
#  eksctl create iamidentitymapping              Create an IAM identity mapping
#  eksctl create iamserviceaccount               Create an iamserviceaccount - AWS IAM role bound to a Kubernetes service account
#  eksctl create nodegroup                       Create a nodegroup
#


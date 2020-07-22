#!/bin/bash
#
#
#
#
CLUSTER=mediaflow
NODEGROUP=mediaflow
IAMID=kube-cladmin
REGION=us-east-1

#
#     --nodegroup-name string          name of the nodegroup (generated if unspecified, e.g. "ng-a85ce3f1")
#      --without-nodegroup              if set, initial nodegroup will not be created
#  -t, --node-type string               node instance type (default "m5.large")
#  -N, --nodes int                      total number of nodes (for a static ASG) (default 2)
#  -m, --nodes-min int                  minimum nodes in ASG (default 2)
#  -M, --nodes-max int                  maximum nodes in ASG (default 2)

printf "Generate the key for the env \n"
./mk_keys.sh
printf "Create the $CLUSTER cluster \n"
eksctl create cluster --version 1.17 --name=$CLUSTER -v4  --nodegroup-name=mediaflow -t t2.small -N 3 -m 2 -M 4 
# added verbose 4 flag for review 
#--without-nodegroup 

#eksctl create cluster  --name my-cluster --without-nodegroup

#eksctl create iamserviceaccount $IAMID 

printf "Enable Monitoringand Logging (temporarily. Eval costs) \n"
#eksctl utils update-cluster-logging --region=$REGION --cluster=$CLUSTER
eksctl utils update-cluster-logging --region=$REGION --cluster=$CLUSTER --enable-types scheduler --approve  
eksctl utils update-cluster-logging --region=$REGION --cluster=$CLUSTER --enable-types controllerManager --approve  

#printf "Create nodegroup $NODEGROUP #NOT ALLOWED
#eksctl create nodegroup  $NODEGROUP"
#  eksctl create fargateprofile                  Create a Fargate profile
#  eksctl create iamidentitymapping              Create an IAM identity mapping
#  eksctl create iamserviceaccount               Create an iamserviceaccount - AWS IAM role bound to a Kubernetes service account
#  eksctl create nodegroup                       Create a nodegroup
#


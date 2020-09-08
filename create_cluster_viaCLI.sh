#!/bin/bash
#
#
#
#
#CLUSTER=mediaflow-$RANDOM
CLUSTER=mediaflow
NODEGROUP=mediaflow
K8SVER=1.16
NGNAME=dev
IAMID=mediaflow-cladmin
FARGATEID=mediaflow-fargate
export REGION=us-east-1
DEBUG=3
NODETYPE=t2.small
STARTWITH=3
MIN=2
MAX=4
LOG=$CLUSTER-$NGNAME.log
DATE=`date`
TIMESTAMP=`date +%A-%m-%d-%Y-%H:%M`
#
#     --nodegroup-name string          name of the nodegroup (generated if unspecified, e.g. "ng-a85ce3f1")
#      --without-nodegroup              if set, initial nodegroup will not be created
#  -t, --node-type string               node instance type (default "m5.large")
#  -N, --nodes int                      total number of nodes (for a static ASG) (default 2)
#  -m, --nodes-min int                  minimum nodes in ASG (default 2)
#  -M, --nodes-max int                  maximum nodes in ASG (default 2)

#printf "Deleting old CF stack \n\a"
#eksctl delete cluster --region=$REGION --name=$CLUSTER
echo $?
printf "Starting $0 at ##### $DATE #### \n\a"
printf "Running aws configure. Apply credentials \n"
aws configure 

printf "Generate the key for the env \n"
./mk_keys.sh

printf "Create the $CLUSTER cluster \n"
eksctl create cluster --version $K8SVER --name=$CLUSTER -v$DEBUG  --nodegroup-name=$NGNAME -t $NODETYPE -N $STARTWITH -m $MIN -M $MAX | tee $LOG

if [[ $? -ne 0 ]]; then
printf "Cluster create failed!! \a\a\a\a\n"
exit
fi

printf "Enable Monitoringand Logging (temporarily. Eval costs. Check CloudWatch) \n"
sleep 30
eksctl utils update-cluster-logging --region=$REGION --cluster=$CLUSTER --enable-types scheduler --approve  | tee -a $LOG
eksctl utils update-cluster-logging --region=$REGION --cluster=$CLUSTER --enable-types controllerManager --approve | tee -a $LOG
eksctl utils update-cluster-logging --region=$REGION --cluster=$CLUSTER --enable-types api --approve | tee -a $LOG
#eksctl utils update-cluster-logging --region=$REGION --cluster=$CLUSTER --enable-types all --approve | tee -a $LOG

#printf "Create the IAM ID \n"
#eksctl create iamserviceaccount $IAMID --cluster=$CLUSTER 

#printf "Create the Fargate ID \n"
#eksctl create fargateprofile $FARGATEID --cluster=$CLUSTER --namespace=$CLUSTER


printf "Create the EBS volumes for the environment \n"
#../tt-complete/scripts/create-ebs-volumes.sh
az=us-east-1a
voltypeIO1=io1
voltypeST1=st1
voltypeGP2=gp2
voltypeLOG=standard
sizeIO1=10
sizeST1=500
sizeGP2=20
sizeLOG=50
IOPS=100

#aws ec2 create-volume --availability-zone $az --size $sizeIO1 --volume-type $voltypeIO1 --multi-attach-enabled --iops $IOPS
aws ec2 create-volume --availability-zone $az --size $sizeST1 --volume-type $voltypeST1
aws ec2 create-volume --availability-zone $az --size $sizeGP2 --volume-type $voltypeGP2
aws ec2 create-volume --availability-zone $az --size $sizeLOG --volume-type $voltypeLOG

#../tt-complete/scripts/create_s3bucket.sh
aws s3 mb s3://mediaflow-logdata --region $REGION 
aws s3 mb s3://mediaflow-appdata --region $REGION
aws s3 mb s3://mediaflow-templates --region $REGION

aws s3 ls


#ARN=grep "auth ConfigMap" mediaflow-dev.log|awk '{print$4}'|sed 's/"//g'
#aws eks tag-resource --resource-arn $ARN --tags team=development TTL=5
#printf "Create nodegroup $NODEGROUP #NOT ALLOWED
#eksctl create nodegroup  $NODEGROUP"
#  eksctl create fargateprofile                  Create a Fargate profile
#  eksctl create iamidentitymapping              Create an IAM identity mapping
#  eksctl create iamserviceaccount               Create an iamserviceaccount - AWS IAM role bound to a Kubernetes service account
#  eksctl create nodegroup                       Create a nodegroup
#

date >>$LOG
cp $LOG logs/$CLUSTER-create-$TIMESTAMP.log 
printf "\a\a\a\a\a"

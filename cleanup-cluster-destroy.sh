#!/bin/bash
###
region=us-east-1
name=mediaflow
stackname=eksctl-${name}-cluster

aws cloudformation delete-stack --stack-name $stackname
aws cloudformation list-stacks 
echo $?
eksctl delete cluster --region=$region --name=$name
echo $?

printf "Deleting Buckets and EBS Volumes \n"
aws s3 rm s3://mediaflow-appdata/
aws s3 rm s3://mediaflow-logdata/
aws s3 rm s3://mediaflow-templates/

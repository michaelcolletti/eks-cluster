#!/bin/bash
###
region=us-east-1
name=mediaflow
stackname=eksctl-${cluster}-cluster

aws cloudformation delete-stack --stack-name $stackname
echo $?
eksctl delete cluster --region=$region --name=$name
echo $?

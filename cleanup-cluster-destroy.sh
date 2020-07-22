#!/bin/bash
###
region=us-east-1
name=mediaflow
stackname=eksctl-${cluster}-cluster
eksctl delete cluster --region=$region --name=$name
aws cloudformation delete-stack --stack-name $stackname

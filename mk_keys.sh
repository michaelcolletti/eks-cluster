#!/bin/bash

# Script to create ec2 keys, describe and import
#
KEYPAIRNAME=cf-infra-provision
KEYPEMOUT=${KEYPAIRNAME}.pem

#rm -f $HOME/.aws/$KEYPEMOUT 2>/dev/null
# gen public key 
ssh-keygen -t rsa -C "$KEYPAIRNAME" -f ~/.ssh/$KEYPAIRNAME 2>/dev/null
aws ec2 import-key-pair --key-name "$KEYPAIRNAME" --public-key-material fileb://~/.ssh/${KEYPAIRNAME}.pub 2>/dev/null
#
#aws ec2 create-key-pair --key-name $KEYPAIRNAME --query 'KeyMaterial' --output text > $HOME/.aws/$KEYPEMOUT 2>/dev/null
chmod 400 $HOME/.aws/$KEYPEMOUT


aws ec2 describe-key-pairs --key-name $KEYPAIRNAME 

printf "When done, delete via aws ec2 delete-key-pair --key-name $KEYPAIRNAME \n\n"



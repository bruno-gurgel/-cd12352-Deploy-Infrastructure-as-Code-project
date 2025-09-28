#!/bin/bash

# Script to delete CloudFormation stacks
# Usage: ./delete.sh <stack-name>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <stack-name>"
    echo "Example: $0 udagram-app"
    exit 1
fi

STACK_NAME=$1

echo "Deleting stack: $STACK_NAME"

aws cloudformation delete-stack --stack-name $STACK_NAME --region=us-east-1

echo "Stack deletion initiated. Use the following command to monitor progress:"
echo "aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region=us-east-1"
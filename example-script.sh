#!/bin/sh

# Add a known table
aws dynamodb create-table \
	--endpoint-url http://localhost:8000 \
	--region us-west-2 \
	--table-name acl \
	--attribute-definitions AttributeName=customer,AttributeType=S AttributeName=resource,AttributeType=S \
	--key-schema AttributeName=customer,KeyType=HASH AttributeName=resource,KeyType=RANGE \
	--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# Add some known state
aws dynamodb put-item \
	--endpoint-url http://localhost:8000 \
	--region us-west-2 \
	--table-name acl \
	--item '{"customer": {"S": "Bob"}, "resource": {"S": "ACCOUNT-1234"}, "access": {"S": "Admin"}}'
aws dynamodb put-item \
	--endpoint-url http://localhost:8000 \
	--region us-west-2 \
	--table-name acl \
	--item '{"customer": {"S": "Bob"}, "resource": {"S": "ACCOUNT-4321"}, "access": {"S": "User"}}'
aws dynamodb put-item \
	--endpoint-url http://localhost:8000 \
	--region us-west-2 \
	--table-name acl \
	--item '{"customer": {"S": "Ray"}, "resource": {"S": "ACCOUNT-4321"}, "access": {"S": "Admin"}}'

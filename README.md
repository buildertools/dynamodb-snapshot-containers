# DynamoDB Testing Snapshot

Functional testing a stateful system because your tests typically mutate the state of the system under test. This leads to all sorts of "dirty state" problems where tests fail because the system under test was not started from a known state. The matter is made much worse when your software leverages managed services or proprietary database technology like DynamoDB. I love DynamoDB, but introducing a network dependency on development environments and functional tests is a bad idea. AWS released a [local DynamoDB devkit](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html) sometime ago. This project both wraps that [DynamoDB devkit in a container](https://hub.docker.com/buildertools/dynamodb-local) and provides a mechanism for capturing snapshots that can be attached to dependent services at test time to launch from well known states.

## Dependencies

1. A POSIX shell
2. Docker (for Linux containers)

## Getting Started

If you're familiar with the AWS CLI then you can write a script to build up the state your tests require. This is the provided example-script.sh:

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

With your state described as a script you can use the ````build-snap.sh```` script to write that state to a DynamoDB container and save that state for use later. This command uses ````example-script.sh```` to build the database state and store the results in a Docker repository named: ````myproject/db-test-suite:acl-case2````. The image will be tagged with an author and a message provided by the second and third arguments.

    ./build-snap.sh example-script.sh awesomeproject/db-test-suite:acl-case2 "jeff@allingeek.com" "ACL project testing: 2 admin, 1 user"

## Using the Snapshots

The snapshots that are created run on port 8000 inside containers. If you want to use the AWS CLI to explore one and verify that it works run:

    docker run -d -p 8000:8000 --name dynamo-example <SNAPSHOT_REPOSITORY>
    aws dynamodb list-tables --endpoint-url http://localhost:8000 --region us-west-2

If your AWS CLI environment is configured correctly the ````aws```` command will list the tables that you created in your script.

These snapshots are much more interesting when you use them as service dependencies in CI/CD pipelines for functional testing.

## LICENSE

This repository contains a vendored copy of [https://s3-us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.tar.gz](https://s3-us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.tar.gz). That vendored copy has not been modified in any form. Any an all licences associated with that source and its dependencies are included. This project makes no copyright or license assertions on that material. All source outside of the ````dynamodb_local_latest```` directory is licensed under MIT (See [LICENSE](./LICENSE).

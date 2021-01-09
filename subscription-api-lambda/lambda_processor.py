import boto3
import os
import json
import logging
from datetime import datetime

LOG = logging.getLogger()
LOG.setLevel('DEBUG')

DYNAMO_DB = os.environ['subscriberTable']

dynamodb_client = boto3.resource('dynamodb')


def lambda_handler(event, context):
    LOG.info("event received.... ", event)

    response = {
        "body": json.dumps({"message": ""}),
        "headers": {
            "content-type": "application/json"
        },
        "statusCode": 405,
        "isBase64Encoded": False,
    }

    path, method = event.get('path'), event.get('httpMethod')
    data = event['body']

    LOG.info('Received HTTP %s request for path %s' % (method, path))

    if path == '/add-subscription' and method == 'POST':
        response["body"], response["statusCode"] = perform_operation(data, DYNAMO_DB)
    if path == '/get-subscription' and method == 'GET':
        response["body"], response["statusCode"] = perform_get_subscription(data, DYNAMO_DB)
    if path == '/delete-subscription' and method == 'DELETE':
        response["body"], response["statusCode"] = perform_delete_subscription(data, DYNAMO_DB)

    else:
        msg = '%s %s not allowed' % (method, path)
        response["statusCode"] = 405
        response["body"] = json.dumps({"error": msg})
        LOG.error(msg)

    return response


def perform_operation(data, subscribers_Table):
    LOG.info("Processing payload to add new subscriber %s" % data)
    LOG.info(type(data))
    payload = json.loads(data)

    try:
        subscriber_arn = payload['SubscriberARN']
        resource_type = payload['ResourceType']
        resource_name = payload['ResourceName']
        subscriber_dataType = payload['DataType']

        item = {
            'SubscriberARN': {'S': subscriber_arn},
            'ResourceType': {'S': resource_type},
            'ResourceName': {'S': resource_name},
            'DataType': {'S': subscriber_dataType}
        }

        dynamodb_client.put_item(
            TableName=subscribers_Table,
            Item=item
        )

        return json.dumps({"message": "Successfully delivered!"}), 200
    except Exception as error:
        LOG.error("Something went wrong: %s" % error)
        return json.dumps({"message": str(error)}), 500


def perform_get_subscription(data, subscribers_Table):
    LOG.info("Processing payload to get subscriber %s" % data)
    LOG.info(type(data))
    payload = json.loads(data)

    try:
        resource_name = payload['ResourceName']

        response = dynamodb_client.query(
            TableName=subscribers_Table,
            KeyConditionExpression='ResourceName = :resourceName',
            ExpressionAttributeValues={
                ':resourceName': {'S': resource_name}
            }
        )
        LOG.info(response['Items'])
        return json.dumps({"message": "Successfully delivered!"}), 200
    except Exception as error:
        LOG.error("Something went wrong: %s" % error)
        return json.dumps({"message": str(error)}), 500


def perform_delete_subscription(data, subscribers_Table):
    return json.dumps({"message": "Successfully delivered!"}), 200

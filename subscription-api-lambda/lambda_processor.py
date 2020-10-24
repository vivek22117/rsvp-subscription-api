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

    subscribers_Table = dynamodb_client.Table(DYNAMO_DB)

    if path == '/add-subscription' and method == 'POST':
        response["body"], response["statusCode"] = perform_operation(data, subscribers_Table)
    if path == '/get-subscription' and method == 'GET':
        response["body"], response["statusCode"] = perform__get_subscription(data, subscribers_Table)

    else:
        msg = '%s %s not allowed' % (method, path)
        response["statusCode"] = 405
        response["body"] = json.dumps({"error": msg})
        LOG.error(msg)

    return response


def perform_operation(data, subscribers_Table):
    LOG.info("Processing payload %s" % data)
    LOG.info(type(data))
    payload = json.loads(data)

    try:
        subscriber_arn = payload['SubscriberARN']
        resource_type = payload['ResourceType']
        resource_name = payload['ResourceName']
        subscriber_dataType = payload['DataType']

        subscribers_Table.put_item(
            Item={
                'SubscriberARN': subscriber_arn,
                'ResourceType': resource_type,
                'ResourceName': resource_name,
                'DataType': subscriber_dataType
            }
        )

        return json.dumps({"message": "Successfully delivered!"}), 200
    except Exception as error:
        LOG.error("Something went wrong: %s" % error)
        return json.dumps({"message": str(error)}), 500


def perform__get_subscription(data, subscribers_Table):
    return json.dumps({"message": "Successfully delivered!"}), 200

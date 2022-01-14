import boto3
import os
import json
import logging
from datetime import datetime

LOG = logging.getLogger()
LOG.setLevel('DEBUG')

DYNAMO_DB = os.environ['subscriberTable']

dynamodb_client = boto3.client('dynamodb')


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

    try:
        path, method = event.get('path'), event.get('httpMethod')
        data = event['body']

        LOG.info('Received HTTP %s request for path %s' % (method, path))

        if path == '/add-subscription' and method == 'POST':
            status_message, status_code = perform_put_operation(data, DYNAMO_DB)
            response["body"] = status_message
            response["statusCode"] = status_code
        elif path == '/get-subscription' and method == 'GET':
            status_message, status_code = perform_get_subscription(data, DYNAMO_DB)
            response["body"] = status_message
            response["statusCode"] = status_code
        elif path == '/delete-subscription' and method == 'DELETE':
            status_message, status_code = perform_delete_subscription(data, DYNAMO_DB)
            response["body"] = status_message
            response["statusCode"] = status_code
        else:
            msg = '%s %s not allowed' % (method, path)
            response["statusCode"] = 405
            response["body"] = json.dumps({"error": msg})
            LOG.info(msg)
    except Exception as ex:
        LOG.error(str(ex))

    return response


def perform_put_operation(data, subscribers_table):
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

        response = dynamodb_client.put_item(
            TableName=subscribers_table,
            Item=item
        )
        LOG.debug(response)
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
        return json.dumps({"message": "Successfully!"}), 200
    except Exception as error:
        LOG.error("Something went wrong: %s" % error)
        return json.dumps({"message": str(error)}), 500


def perform_delete_subscription(data, subscribers_Table):
    LOG.info("Processing payload to delete subscriber %s" % data)
    payload = json.loads(data)

    try:
        resource_name = payload['ResourceName']

        response = dynamodb_client.delete_item(
            Key={
                'ResourceName': {
                    'S': resource_name,
                }
            },
            TableName=DYNAMO_DB,
        )
        LOG.info(response['Items'])
        return json.dumps({"message": "Successfully!"}), 200
    except Exception as error:
        LOG.error("Something went wrong: %s" % error)
        return json.dumps({"message": str(error)}), 500

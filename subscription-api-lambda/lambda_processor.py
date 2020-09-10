import boto3
import os
import json
import logging
from datetime import datetime

LOG = logging.getLogger()
LOG.setLevel('DEBUG')


def lambda_handler(event, context):
    LOG.info("event received.... ", event)

    dynamodb = boto3.resource('dynamodb')
    client = boto3.client('dynamodb')

    subscribersTalble = dynamodb.Table('subscripbers-table')

    response = {
        "body": json.dumps({"message": ""}),
        "headers": {
            "content-type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "statusCode": 405,
        "isBase64Encoded": False,
    }

    path, method = event.get('path'), event.get('httpMethod')
    data = event['body']

    LOG.info('Received HTTP %s request for path %s' % (method, path))

    if path == '/messages' and method == 'POST':
        response["body"], response["statusCode"] = perform_operation(data)

    else:
        msg = '%s %s not allowed' % (method, path)
        response["statusCode"] = 405
        response["body"] = json.dumps({"error": msg})
        LOG.error(msg)

    return response


def perform_operation(data):
    LOG.info("Processing payload %s" % data)

    try:
        ses.send_email(
            Source=VERIFIED_EMAIL,
            Destination={
                'ToAddresses': [VERIFIED_EMAIL]  # Also a verified email
            },
            Message={
                'Subject': {'Data': 'A message from professional website!!'},
                'Body': {'Text': {'Data': data}}
            }
        )
        return json.dumps({"message": "Successfully delivered!"}), 200
    except Exception as error:
        LOG.error("Something went wrong: %s" % error)
        return json.dumps({"message": str(error)}), 500

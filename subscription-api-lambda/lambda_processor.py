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

    resource_arn = event['resourceARN']
    resource_type = event['resourceType']

    # Putting a try/catch to log to user when some error occurs
    try:

        subscribersTalble.put_item(
            Item={
                'eventDateTime': eventDateTime,
                'deviceId': deviceId,
                'temperature': int(temperature)
            }
        )

        return {
            'statusCode': 200,
            'body': json.dumps('Successfully inserted Subscriber!')
        }
    except Exception as ex:
        print('Closing lambda function')
        return {
            'statusCode': 400,
            'body': json.dumps('Error saving the Subscriber')
        }


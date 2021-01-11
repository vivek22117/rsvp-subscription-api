from src import app

import boto3
import datetime
import json
import logging
import os
import requests
import sys

from flask import Response, request

LOG_FILENAME = 'subscription_api_logs.out'
CURRENT_VERSION = "v0.1"

logging.basicConfig(filename=LOG_FILENAME, format='%(asctime)s %(levelname)-8s %(message)s', level=logging.DEBUG,
                    datefmt='%Y-%m-%d %H:%M:%S')
logger = logging.getLogger(__name__)


@app.route('/api/<string:version>/health', methods=['GET'])
def health(version):
    if version == CURRENT_VERSION:
        status = 200
        response = {"health": "ok", "response": "ok"}
    else:
        status = 400
        response = {"error": "invalid API version", "response": "ok"}
    return Response(json.dumps(response), status=status, mimetype='application/json')
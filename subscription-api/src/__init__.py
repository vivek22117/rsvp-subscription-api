"""Main App Module"""

import os
from flask import Flask, make_response, jsonify, request
from prometheus_flask_exporter import PrometheusMetrics

from util.config import app_config

config_name = os.environ.get("APP_CONFIG", "production")
app = Flask(__name__)
metrics = PrometheusMetrics(app)

app.config.from_object(app_config[config_name])


# override 404 error handler
@app.errorhandler(404)
def resource_not_found(error):
    """
    This will be response returned if the user attempts to access
    a non-existent resource or url.
    """
    response_payload = dict(
        message="The requested URL was not found on the server. " +
                "If you entered the URL manually please check your spelling and try again."
    )
    return make_response(jsonify(response_payload), 404)


# Import and add namespaces for the endpoints
from src import api_routes

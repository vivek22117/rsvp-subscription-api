"""App instance configs"""

import os

basedir = os.path.abspath(os.path.dirname(__file__))
dynamodb_table = os.environ.get('DYNAMODB_TABLE', 'rsvp-subscriber-table')
running_in_local = os.environ.get('IS_RUNNING_LOCAL', 'false')


class BaseConfig:
    """Base configuration."""
    # Flask APP configs
    SECRET_KEY = os.environ.get("SECRET_KEY", "\xe6.]`\x99\x07\x1ap\xff\xb7c\xf0\xea*\xba{")
    DEBUG = False
    # Flask-RESTPlus Configs
    ERROR_404_HELP = False


class DevelopmentConfig(BaseConfig):
    """Development configuration."""
    DEBUG = True
    IS_RUNNING_LOCAL = 'true'


class TestingConfig(BaseConfig):
    """Testing configuration."""
    DEBUG = True
    TESTING = True
    PRESERVE_CONTEXT_ON_EXCEPTION = False
    IS_RUNNING_LOCAL = 'true'


class ProductionConfig(BaseConfig):
    """Production configuration."""
    DEBUG = True
    DYNAMODB_TABLE = dynamodb_table
    IS_RUNNING_LOCAL = running_in_local


app_config = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
}

import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f'start updating {event}')
    source_bucket = os.environ['source_bucket']
    target_bucket = os.environ['target_bucket']
    s3 = boto3.resource('s3')
    # ToDo: get task json
    # ToDo: get jobs
    # ToDo: write job tasks to target


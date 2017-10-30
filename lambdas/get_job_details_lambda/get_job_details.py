import boto3
import os
import logging
import json
import importlib
import datetime as dt

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f'start work on {event}')
    target_bucket_name = os.environ['target_bucket']
    source_bucket_name = event['Records'][0]['s3']['bucket']['name']
    source_key = event['Records'][0]['s3']['object']['key']
    s3 = boto3.resource('s3')
    source_object = s3.Object(source_bucket_name, source_key)
    task = json.loads(source_object.get()['Body'].read().decode('utf-8'))
    company = task['company']
    date = task['date']
    job_resource = task['job_resource']
    task_uuid = task['task_uuid']

    scraper = importlib.import_module(f'scrapers.{company}')
    job_details = scraper.get_details(job_resource)
    target_bucket = s3.Bucket(target_bucket_name)
    task['job_details'] = job_details
    job_snap = json.dumps(task)
    target_bucket.put_object(Key=date+'/'+company+'/'+task_uuid+'.json',
                  Body=job_snap.encode())
    logger.info(f'created task {task_uuid}')

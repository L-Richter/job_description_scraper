import boto3
import os
import logging
import json
import importlib
import datetime as dt
import uuid

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f'start updating {event}')
    target_bucket_name = os.environ['target_bucket']
    source_bucket_name = event['Records'][0]['s3']['bucket']['name']
    source_key = event['Records'][0]['s3']['object']['key']
    s3 = boto3.resource('s3')
    source_object = s3.Object(source_bucket_name, source_key)
    task = json.loads(source_object.get()['Body'].read().decode('utf-8'))
    company = task['company']
    date = task['date']

    logger.info(f'performing task {task}')
    scraper = importlib.import_module(f'scrapers.{company}')
    jobs = scraper.get_jobs()
    target_bucket = s3.Bucket(target_bucket_name)
    for job in jobs:
        task_uuid = uuid.uuid4().hex
        job_task = json.dumps({'company': company,
                               'date': date,
                               'created_at': dt.datetime.now().isoformat(),
                               'task_uuid': task_uuid,
                               'job_resource': job,
                               'version': 1})
        target_bucket.put_object(Key=date+'/'+company+'/'+task_uuid+'.json',
                      Body=job_task.encode())
        logger.info(f'created task {job_task}')


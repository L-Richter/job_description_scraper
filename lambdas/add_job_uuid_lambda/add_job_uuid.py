import boto3
import os
import logging
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f'start work on {event}')
    target_bucket_name = os.environ['target_bucket']
    source_bucket_name = event['Records'][0]['s3']['bucket']['name']
    source_key = event['Records'][0]['s3']['object']['key']
    s3 = boto3.resource('s3')
    source_object = s3.Object(source_bucket_name, source_key)
    job = json.loads(source_object.get()['Body'].read().decode('utf-8'))
    company = job['company']
    date = job['date']
    job_details = job['job_details']
    task_uuid = job['task_uuid']
    
    #ToDo: get uuid from dynamodb
    job_uuid = task_uuid
    
    storage_key = 'v1/' + job_uuid + '/' + date + '.json'
    job['job_details']['job_uuid'] = job_uuid
    job['job_details']['company'] = company
    target_bucket = s3.Bucket(target_bucket_name)
    job_snap = json.dumps(job['job_details'])
    target_bucket.put_object(Key=storage_key,
                  Body=job_snap.encode())
    logger.info(f'added {storage_key}')

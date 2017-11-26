import boto3
import os
import logging
import json
import psycopg2
from collections import defaultdict

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f'start pushing {event} to db')
    
    db_host = os.environ['DB_HOST']
    db_username = os.environ['DB_USERNAME']
    db_password = os.environ['DB_PASSWORD']
    db_name = os.environ['DB_NAME']

    source_bucket_name = event['Records'][0]['s3']['bucket']['name']
    source_key = event['Records'][0]['s3']['object']['key']
    s3 = boto3.resource('s3')
    source_object = s3.Object(source_bucket_name, source_key)
    logger.info(f'getting s3 object')
    job = json.loads(source_object.get()['Body'].read().decode('utf-8'))
    job = defaultdict(lambda : None, job)
    job['job_details'] = defaultdict(lambda : None, job['job_details'])
    conn = psycopg2.connect(host=db_host,
                            user=db_username,
                            password=db_password,
                            dbname=db_name)
    cur = conn.cursor()
    qry = """INSERT INTO job_descriptions_staging (
            	created_at,
	            trigger_date,
	            company,
	            company_name,
	            version,
	            storage_key,
	            natural_id,
	            job_title,
	            job_description_hash,
	            location,
	            department)
	          VALUES (
	            %(created_at)s,
	            %(trigger_date)s,
	            %(company)s,
	            %(company_name)s,
	            %(version)s,
	            %(storage_key)s,
	            %(natural_id)s,
	            %(job_title)s,
	            %(job_description_hash)s,
	            %(location)s,
	            %(department)s);"""
    departments = job['job_details']['department']
    department = None
    if departments:
        department = ''.join(departments)
    values = {  'created_at': job['created_at'],
                'trigger_date': job['date'],
                'company': job['company'],
                'company_name': job['job_details']['company_name'],
                'version': job['version'],
                'storage_key': source_key,
                'natural_id': job['job_details']['natural_id'],
                'job_title': job['job_details']['job_title'],
                'job_description_hash': job['job_details']['job_description_id'],
                'location': job['job_details']['location'],
                'department': department
              }
    cur.execute(qry, values)
    conn.commit()
    cur.close()
    conn.close()


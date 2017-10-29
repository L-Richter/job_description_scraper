import boto3
import datetime as dt
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    company_list_bucket = os.environ['company_list_bucket']
    company_list_key = os.environ['company_list_key']
    target_bucket = os.environ['target_bucket']
    date = dt.date.today().strftime('%Y%m%d')
    s3 = boto3.resource('s3')
    company_list_object = s3.Object(company_list_bucket, company_list_key)
    company_list = (company_list_object.get()['Body']
                                       .read()
                                       .decode('utf-8')
                                       .split('\n'))
    company_list = [company for company in company_list if company != '']
    logger.info(f'{len(company_list)} companies to update')
    target = s3.Bucket(target_bucket)
    for company in company_list:
        data = f'''{{"date":"{date}","company":"{company}","created_at":"{dt.datetime.now()}"}}\n'''
        target.put_object(Key=date + '/' + company + '.json',
                      Body=data.encode())
        logger.info(f'created {company} on {date}')


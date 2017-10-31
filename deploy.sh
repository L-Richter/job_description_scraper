#!/bin/bash

echo "preparing deployment packages"
zip -j lambdas/daily_lambda/daily_lambda.zip lambdas/daily_lambda/daily_lambda.py
zip -j lambdas/add_job_uuid_lambda/add_job_uuid.zip lambdas/add_job_uuid_lambda/add_job_uuid.py

cd lambdas/create_job_lambda/
zip -r create_job.zip .
cd ../..

cd lambdas/get_job_details_lambda/
zip -r get_job_details.zip .
cd ../..

echo "install required packages"
pip install requests -t tmp/requests

cd tmp/requests/
zip -ur ../../lambdas/create_job_lambda/create_job.zip .
zip -ur ../../lambdas/get_job_details_lambda/get_job_details.zip .
cd ../..

echo "uploading lambdas to S3"
aws s3 cp lambdas/daily_lambda/daily_lambda.zip s3://lambdas-all/scraper-daily.zip
aws s3 cp lambdas/create_job_lambda/create_job.zip s3://lambdas-all/create-job.zip
aws s3 cp lambdas/get_job_details_lambda/get_job_details.zip s3://lambdas-all/get-job-details.zip
aws s3 cp lambdas/add_job_uuid_lambda/add_job_uuid.zip s3://lambdas-all/add-job-uuid.zip

echo "updating lambdas"
aws lambda update-function-code \
--function-name scraper-daily-lambda \
--s3-bucket lambdas-all \
--s3-key scraper-daily.zip \
--publish

aws lambda update-function-code \
--function-name create-job-lambda \
--s3-bucket lambdas-all \
--s3-key create-job.zip \
--publish

aws lambda update-function-code \
--function-name get-job-details-lambda \
--s3-bucket lambdas-all \
--s3-key get-job-details.zip \
--publish

aws lambda update-function-code \
--function-name add-job-uuid-lambda \
--s3-bucket lambdas-all \
--s3-key add-job-uuid.zip \
--publish

echo "upload configs"
aws s3 cp config/companies.txt s3://scraper-companies/companies.txt




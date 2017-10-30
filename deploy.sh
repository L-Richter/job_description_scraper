#!/bin/bash

echo "preparing deployment packages"
zip -j lambdas/daily_lambda/daily_lambda.zip lambdas/daily_lambda/daily_lambda.py

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



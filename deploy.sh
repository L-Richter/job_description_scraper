#!/bin/bash

echo "preparing deployment packages"
zip -j lambdas/daily_lambda/daily_lambda.zip lambdas/daily_lambda/daily_lambda.py

cd lambdas/create_job_lambda/
pip install requests -t .
zip -r create_job.zip .
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



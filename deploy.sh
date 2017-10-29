#!/bin/bash

echo "zipping lambdas"
zip -j lambdas/daily_lambda/daily_lambda.zip lambdas/daily_lambda/daily_lambda.py

echo "uploading lambdas to S3"
aws s3 cp lambdas/daily_lambda/daily_lambda.zip s3://lambdas-all/scraper-daily.zip

echo "updating lambdas"
aws lambda update-function-code \
--function-name scraper-daily-lambda \
--s3-bucket lambdas-all \
--s3-key scraper-daily.zip \
--publish



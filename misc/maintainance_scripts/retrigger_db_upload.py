"""Script to trigger the lambda sending the job descriptions to the database."""
import boto3
import json

s3 = boto3.resource('s3')
bucket = s3.Bucket('job-descriptions-daily')
objects = bucket.objects.all()
for obj in objects:
    event = {
              "Records": [
                {
                  "s3": {
                    "bucket": {
                      "name": "job-descriptions-daily"
                    },
                    "object": {
                      "key": obj.key
                    }
                  }
                }
              ]
            }
    lambda_client = boto3.client('lambda')
    response = lambda_client.invoke(
        FunctionName='to-database-lambda',
        Payload=json.dumps(event))


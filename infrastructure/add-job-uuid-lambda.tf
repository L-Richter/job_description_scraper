resource "aws_s3_bucket_object" "add-job-uuid-lambda-object" {
  bucket = "${aws_s3_bucket.lambdas.bucket}"
  key    = "add-job-uuid.zip"
  source = "../lambdas/add_job_uuid_lambda/add_job_uuid.zip"
  etag   = "${md5(file("../lambdas/add_job_uuid_lambda/add_job_uuid.zip"))}"
}

resource "aws_iam_role" "iam_for_add_job_uuid_lambda" {
  name = "iam_for_add_job_uuid_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "add_job_uuid_lambda_policy" {
  name = "add_job_uuid_lambda_policy"
  role = "${aws_iam_role.iam_for_add_job_uuid_lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
       "Effect": "Allow",
       "Action": [
         "s3:PutObject"
       ],
       "Resource": ["arn:aws:s3:::${aws_s3_bucket.job-descriptions.bucket}/*"]
     },
    {
       "Effect": "Allow",
       "Action": [
         "s3:GetObject"
       ],
       "Resource": ["arn:aws:s3:::${aws_s3_bucket.raw-job-details.bucket}/*"]
     },
     {
        "Effect": "Allow",
        "Action": [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:Scan"
        ],
        "Resource": ["arn:aws:dynamodb:*:*:table/${aws_dynamodb_table.jobs.name}"]
    },
    {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
        ],
        "Resource": [
            "arn:aws:logs:*:*:*"
        ]
    }
  ]
}
EOF
}


resource "aws_lambda_permission" "allow_add_job_uuid_from_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.add-job-uuid-lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.raw-job-details.arn}"
}


resource "aws_s3_bucket_notification" "raw_job_details_bucket_notification" {
  bucket = "${aws_s3_bucket.raw-job-details.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.add-job-uuid-lambda.arn}"
    events              = ["s3:ObjectCreated:Put"]
    filter_suffix       = ".json"
  }
}


resource "aws_lambda_function" "add-job-uuid-lambda" {
  s3_bucket         = "${aws_s3_bucket_object.add-job-uuid-lambda-object.bucket}"
  s3_key            = "${aws_s3_bucket_object.add-job-uuid-lambda-object.key}"
  s3_object_version = "${aws_s3_bucket_object.add-job-uuid-lambda-object.version_id}"
  function_name     = "add-job-uuid-lambda"
  role              = "${aws_iam_role.iam_for_add_job_uuid_lambda.arn}"
  handler           = "create_job.lambda_handler"
  runtime           = "python3.6"
  timeout           = 120
  
  environment {
    variables = {
      target_bucket  = "${aws_s3_bucket.job-descriptions.bucket}"
      DYNAMODB_TABLE = "${aws_dynamodb_table.jobs.name}"
    }
  }

}

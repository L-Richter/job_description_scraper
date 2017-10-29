resource "aws_s3_bucket_object" "create-job-lambda-object" {
  bucket = "${aws_s3_bucket.lambdas.bucket}"
  key    = "create-job.zip"
  source = "../lambdas/create_job_lambda/create_job.zip"
  etag   = "${md5(file("../lambdas/create_job_lambda/create_job.zip"))}"
}

resource "aws_iam_role" "iam_for_create_job_lambda" {
  name = "iam_for_create_job_lambda"
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

resource "aws_iam_role_policy" "create_job_lambda_policy" {
  name = "create_job_lambda_policy"
  role = "${aws_iam_role.iam_for_create_job_lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
       "Effect": "Allow",
       "Action": [
         "s3:PutObject"
       ],
       "Resource": ["arn:aws:s3:::${aws_s3_bucket.jobs.bucket}/*"]
     },
    {
       "Effect": "Allow",
       "Action": [
         "s3:GetObject"
       ],
       "Resource": ["arn:aws:s3:::${aws_s3_bucket.companies.bucket}/*"]
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


resource "aws_lambda_permission" "allow_create_job_from_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.create-job-lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.companies.arn}"
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.companies.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.create-job-lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }
}


resource "aws_lambda_function" "create-job-lambda" {
  s3_bucket         = "${aws_s3_bucket_object.create-job-lambda-object.bucket}"
  s3_key            = "${aws_s3_bucket_object.create-job-lambda-object.key}"
  s3_object_version = "${aws_s3_bucket_object.create-job-lambda-object.version_id}"
  function_name     = "create-job-lambda"
  role              = "${aws_iam_role.iam_for_create_job_lambda.arn}"
  handler           = "create_job.lambda_handler"
  runtime           = "python3.6"
  timeout           = 120
  
  environment {
    variables = {
      source_bucket = "${aws_s3_bucket.companies.bucket}"
      target_bucket = "${aws_s3_bucket.jobs.bucket}"
    }
  }

}

resource "aws_s3_bucket_object" "get-job-details-lambda-object" {
  bucket = "${aws_s3_bucket.lambdas.bucket}"
  key    = "get-job-details.zip"
  source = "../lambdas/get_job_details_lambda/get_job_details.zip"
  etag   = "${md5(file("../lambdas/get_job_details_lambda/get_job_details.zip"))}"
}

resource "aws_iam_role" "iam_for_get_job_details_lambda" {
  name = "iam_for_get_job_details_lambda"
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

resource "aws_iam_role_policy" "get_job_details_lambda_policy" {
  name = "get_job_details_lambda_policy"
  role = "${aws_iam_role.iam_for_get_job_details_lambda.id}"

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
       "Resource": ["arn:aws:s3:::${aws_s3_bucket.jobs.bucket}/*"]
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


resource "aws_lambda_permission" "allow_get_job_details_from_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.get-job-details-lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.jobs.arn}"
}


resource "aws_s3_bucket_notification" "jobs_bucket_notification" {
  bucket = "${aws_s3_bucket.jobs.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.get-job-details-lambda.arn}"
    events              = ["s3:ObjectCreated:Put"]
    filter_suffix       = ".json"
  }
}


resource "aws_lambda_function" "get-job-details-lambda" {
  s3_bucket         = "${aws_s3_bucket_object.get-job-details-lambda-object.bucket}"
  s3_key            = "${aws_s3_bucket_object.get-job-details-lambda-object.key}"
  s3_object_version = "${aws_s3_bucket_object.get-job-details-lambda-object.version_id}"
  function_name     = "get-job-details-lambda"
  role              = "${aws_iam_role.iam_for_get_job_details_lambda.arn}"
  handler           = "get_job_details.lambda_handler"
  runtime           = "python3.6"
  timeout           = 120
  
  environment {
    variables = {
      target_bucket = "${aws_s3_bucket.job-descriptions.bucket}"
    }
  }

}

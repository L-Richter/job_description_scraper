resource "aws_s3_bucket_object" "scraper-daily-lambda-object" {
  bucket = "${aws_s3_bucket.lambdas.bucket}"
  key    = "scraper-daily.zip"
  source = "../lambdas/daily_lambda/daily_lambda.zip"
  etag   = "${md5(file("../lambdas/daily_lambda/daily_lambda.zip"))}"
}

resource "aws_s3_bucket_object" "company-list" {
  bucket = "${aws_s3_bucket.companies.bucket}"
  key    = "companies.txt"
  source = "../config/companies.txt"
  etag   = "${md5(file("../config/companies.txt"))}"
}

resource "aws_iam_role" "iam_for_scraper_daily_lambda" {
  name = "iam_for_scraper_daily_lambda"
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

resource "aws_iam_role_policy" "scraper_daily_lambda_policy" {
  name = "scraper_daily_lambda_policy"
  role = "${aws_iam_role.iam_for_scraper_daily_lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
       "Effect": "Allow",
       "Action": [
         "s3:PutObject"
       ],
       "Resource": ["arn:aws:s3:::${aws_s3_bucket.companies.bucket}/*"]
     },
    {
       "Effect": "Allow",
       "Action": [
         "s3:GetObject"
       ],
       "Resource": ["arn:aws:s3:::${aws_s3_bucket_object.company-list.bucket}/*"]
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


resource "aws_cloudwatch_event_rule" "daily-scraper-update" {
  name        = "daily-at-0525"
  description = "daily at 05:25 utc"
  schedule_expression = "cron(25 5 * * ? *)"
}


resource "aws_cloudwatch_event_target" "daily-scraper-update-target" {
  rule      = "${aws_cloudwatch_event_rule.daily-scraper-update.name}"
  target_id = "daily_scraper_update"
  arn       = "${aws_lambda_function.scraper-daily-lambda.arn}"
}


resource "aws_lambda_permission" "allow-cloudwatch-scraper-update" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.scraper-daily-lambda.function_name}"
  principal      = "events.amazonaws.com"
  source_arn     = "${aws_cloudwatch_event_rule.daily-scraper-update.arn}"
}


resource "aws_lambda_function" "scraper-daily-lambda" {
  s3_bucket         = "${aws_s3_bucket_object.scraper-daily-lambda-object.bucket}"
  s3_key            = "${aws_s3_bucket_object.scraper-daily-lambda-object.key}"
  s3_object_version = "${aws_s3_bucket_object.scraper-daily-lambda-object.version_id}"
  function_name     = "scraper-daily-lambda"
  role              = "${aws_iam_role.iam_for_scraper_daily_lambda.arn}"
  handler           = "daily_lambda.lambda_handler"
  runtime           = "python3.6"
  timeout           = 30
  
  environment {
    variables = {
      company_list_bucket = "${aws_s3_bucket_object.company-list.bucket}"
      company_list_key    = "${aws_s3_bucket_object.company-list.key}"
      target_bucket       = "${aws_s3_bucket.companies.bucket}"
    }
  }

}

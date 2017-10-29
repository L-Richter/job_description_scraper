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
         "Effect":"Allow",
         "Action":"logs:CreateLogGroup",
         "Resource":"arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
      },
     {
         "Effect":"Allow",
         "Action":[
            "logs:CreateLogStream",
            "logs:PutLogEvents"
         ],
         "Resource":[
            "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:[[logGroups]]:*"
         ]
      }
  ]
}
EOF
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

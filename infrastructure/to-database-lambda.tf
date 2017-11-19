resource "aws_s3_bucket_object" "to-database-lambda-object" {
  bucket = "${aws_s3_bucket.lambdas.bucket}"
  key    = "to-database.zip"
  source = "../lambdas/to_database_lambda/to_database.zip"
  etag   = "${md5(file("../lambdas/to_database_lambda/to_database.zip"))}"
}

resource "aws_iam_role" "iam_for_to_database_lambda" {
  name = "iam_for_to_database_lambda"
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

resource "aws_iam_role_policy" "to_database_lambda_policy" {
  name = "to_database_lambda_policy"
  role = "${aws_iam_role.iam_for_to_database_lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
       "Effect": "Allow",
       "Action": [
         "s3:GetObject"
       ],
       "Resource": ["arn:aws:s3:::${aws_s3_bucket.job-descriptions.bucket}/*"]
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
    },
    {
        "Effect": "Allow",
        "Action": [
                "ec2:DescribeInstances",
                "ec2:CreateNetworkInterface",
                "ec2:AttachNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "ec2:DetachNetworkInterface",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:ResetNetworkInterfaceAttribute",
                "autoscaling:CompleteLifecycleAction"
            ],
        "Resource": [
            "*"
        ]
    }
  ]
}
EOF
}


resource "aws_lambda_permission" "allow_to_database_from_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.to-database-lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.job-descriptions.arn}"
}


resource "aws_s3_bucket_notification" "descriptions_bucket_notification" {
  bucket = "${aws_s3_bucket.job-descriptions.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.to-database-lambda.arn}"
    events              = ["s3:ObjectCreated:Put"]
    filter_suffix       = ".json"
  }
}


resource "aws_lambda_function" "to-database-lambda" {
  s3_bucket         = "${aws_s3_bucket_object.to-database-lambda-object.bucket}"
  s3_key            = "${aws_s3_bucket_object.to-database-lambda-object.key}"
  s3_object_version = "${aws_s3_bucket_object.to-database-lambda-object.version_id}"
  function_name     = "to-database-lambda"
  role              = "${aws_iam_role.iam_for_to_database_lambda.arn}"
  handler           = "to_database.lambda_handler"
  runtime           = "python3.6"
  timeout           = 120
  
  environment {
    variables = {
      DB_HOST = "${aws_db_instance.postgresql.address}"
      DB_USERNAME = "${aws_db_instance.postgresql.username}"
      DB_PASSWORD = "${aws_db_instance.postgresql.password}"
      DB_NAME = "${aws_db_instance.postgresql.name}"
    }
  }

  vpc_config = {
    subnet_ids = ["${aws_subnet.data_backend_1.id}",
                  "${aws_subnet.data_backend_2.id}"]
    security_group_ids = ["${aws_security_group.allow_db_connect.id}"]
  }
}


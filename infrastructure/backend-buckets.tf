resource "aws_s3_bucket" "job-descriptions" {
  bucket = "job-descriptions-daily"
  acl    = "private"
}

resource "aws_s3_bucket" "lambdas" {
  bucket = "lambdas-all"
  acl    = "private"
}

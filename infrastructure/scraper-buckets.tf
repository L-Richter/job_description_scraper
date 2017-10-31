resource "aws_s3_bucket" "companies" {
  bucket = "scraper-companies"
  acl    = "private"
}

resource "aws_s3_bucket" "jobs" {
  bucket = "scraper-jobs"
  acl    = "private"
}


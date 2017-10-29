resource "aws_dynamodb_table" "jobs" {
  name             = "Jobs"
  read_capacity    = 10
  write_capacity   = 10
  hash_key         = "JobUUID"
  stream_enabled   = false

  attribute {
    name = "JobUUID"
    type = "S"
  }
}


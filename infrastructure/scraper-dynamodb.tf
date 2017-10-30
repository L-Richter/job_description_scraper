resource "aws_dynamodb_table" "jobs" {
  name             = "jobs"
  read_capacity    = 25
  write_capacity   = 15
  hash_key         = "job_uuid"
  stream_enabled   = false

  attribute {
    name = "job_uuid"
    type = "S"
  }
}


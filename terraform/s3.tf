# s3.tf

resource "aws_s3_bucket" "elb_logs" {
  bucket = "elb-logs-bucket-yasserproj"
  tags = {
    Name = "elb-logs-bucket-yasserproj"
  }
}

resource "aws_s3_bucket_public_access_block" "elb_logs_public_access_block" {
  bucket = aws_s3_bucket.elb_logs.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "elb_logs_policy" {
  bucket = aws_s3_bucket.elb_logs.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "delivery.logs.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::elb-logs-bucket-yasserproj/*",
        "Condition": {
          "StringEquals": {
            "s3:x-amz-acl": "bucket-owner-full-control"
          }
        }
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "delivery.logs.amazonaws.com"
        },
        "Action": "s3:GetBucketAcl",
        "Resource": "arn:aws:s3:::elb-logs-bucket-yasserproj"
      }
    ]
  })
}

resource "aws_s3_bucket_versioning" "elb_logs_versioning" {
  bucket = aws_s3_bucket.elb_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

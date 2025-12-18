# # S3 Bucket for VPC Flow Logs
# resource "aws_s3_bucket" "vpc_flow_logs" {
#   bucket = "${var.name_prefix}-vpc-flow-logs"
#   force_destroy = true

#   tags = {
#     Environment = var.environment        
#     Terraformed = "True"   
#   }
# }

# resource "aws_s3_bucket_policy" "vpc_flow_logs_policy" {
#   bucket = aws_s3_bucket.vpc_flow_logs.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid = "AllowVPCAccessLogs",
#         Effect = "Allow",
#         Principal = {
#           Service = "vpc-flow-logs.amazonaws.com"
#         },
#         Action = "s3:PutObject",
#         Resource = "${aws_s3_bucket.vpc_flow_logs.arn}/*",
#         Condition = {
#           StringEquals = {
#             "aws:SourceAccount" = data.aws_caller_identity.current.account_id,
#              "s3:x-amz-acl"     = "bucket-owner-full-control"
#           },
#           ArnLike = {
#             "aws:SourceArn" = "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc/*"
#           }
#         }
#       },
#       {
#         Sid = "AllowVPCAccessLogsFromDeliveryLogs",
#         Effect = "Allow",
#         Principal = {
#           Service = "delivery.logs.amazonaws.com"
#         },
#         Action = "s3:PutObject",
#         Resource = "${aws_s3_bucket.vpc_flow_logs.arn}/*",
#         Condition = {
#           StringEquals = {
#             "aws:SourceAccount" = data.aws_caller_identity.current.account_id,
#             "s3:x-amz-acl"       = "bucket-owner-full-control"
#           },
#           ArnLike = {
#             "aws:SourceArn" = "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc/*"
#           }
#         }
#       },
#       {
#         Sid = "AWSLogDeliveryWrite",
#         Effect = "Allow",
#         Principal = {
#           Service = "delivery.logs.amazonaws.com"
#         },
#         Action = "s3:PutObject",
#         Resource = "${aws_s3_bucket.vpc_flow_logs.arn}/*",
#         Condition = {
#           StringEquals = {
#             "aws:SourceAccount" = data.aws_caller_identity.current.account_id,
#             "s3:x-amz-acl"       = "bucket-owner-full-control"
#           },
#           ArnLike = {
#             "aws:SourceArn" = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
#           }
#         }
#       },
#       {
#         Sid = "AWSLogDeliveryAclCheck",
#         Effect = "Allow",
#         Principal = {
#           Service = "delivery.logs.amazonaws.com"
#         },
#         Action = "s3:GetBucketAcl",
#         Resource = aws_s3_bucket.vpc_flow_logs.arn,
#         Condition = {
#           StringEquals = {
#             "aws:SourceAccount" = data.aws_caller_identity.current.account_id
#           },
#           ArnLike = {
#             "aws:SourceArn" = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
#           }
#         }
#       }
#     ]
#   })
# }

# # Get current account ID
# data "aws_caller_identity" "current" {}

# # IAM Role (not required for S3 but retained for consistency)
# resource "aws_iam_role" "flow_log_role" {
#   name = "vpc-flow-log-role-${var.environment}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [ {
#       Action = "sts:AssumeRole",
#       Effect = "Allow",
#       Principal = {
#         Service = "vpc-flow-logs.amazonaws.com"
#       }
#     }]
#   })

#   tags = {
#     Environment = var.environment
#   }
# }

# # VPC Flow Log resource (S3 configuration)
# resource "aws_flow_log" "vpc_flow_logs" {
#   vpc_id               = aws_vpc.vpc[0].id
#   traffic_type         = var.vpc_flow_logs["traffic_type"]
#   log_destination_type = "s3"
#   log_destination      = aws_s3_bucket.vpc_flow_logs.arn

#   tags = {
#     Environment = var.environment 
#   }

#   depends_on = [
#     aws_s3_bucket.vpc_flow_logs,
#     aws_s3_bucket_policy.vpc_flow_logs_policy
#   ]
# }


# resource "aws_s3_bucket_lifecycle_configuration" "vpc_flow_logs_lifecycle" {
#   bucket = aws_s3_bucket.vpc_flow_logs.id

#   rule {
#     id     = "vpc-flow-logs-lifecycle"
#     status = "Enabled"
#     filter {
#       prefix = "" #Apply to all objects
#     }

#     transition {
#       days          = 30
#       storage_class = "GLACIER"
#     }

#     expiration {
#       days = 180
#     }

#     noncurrent_version_expiration {
#       noncurrent_days = 90
#     }
#   }
# }
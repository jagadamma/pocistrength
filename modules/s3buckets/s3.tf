resource "aws_s3_bucket" "common_s3" {
  for_each = { for bucket in var.s3bucketslist : bucket.bucket_name => bucket }

  bucket        = each.value.bucket_name
  force_destroy = each.value.force_destroy

  tags = merge(
  var.common_tags,
  {
    Name = each.value.bucket_name
  }
)


#   lifecycle {
#     prevent_destroy = true
#   }
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  for_each = aws_s3_bucket.common_s3

  bucket = each.value.id

  versioning_configuration {
    status = var.s3bucketslist[index(keys(aws_s3_bucket.common_s3), each.key)].versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  for_each = {
    for k, v in aws_s3_bucket.common_s3 : k => v
    if !var.s3bucketslist[index(keys(aws_s3_bucket.common_s3), k)].public_access
  }

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
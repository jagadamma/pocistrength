# SQS Module Outputs - Dynamic

# All queue ARNs
output "queue_arns" {
  value = {
    for k, v in aws_sqs_queue.queue : k => v.arn
  }
}

# All queue URLs
output "queue_urls" {
  value = {
    for k, v in aws_sqs_queue.queue : k => v.url
  }
}

# Backward compatibility outputs
output "avatar_queue_arn" {
  value = contains(keys(var.sqs_queues), "avatar_queue") ? aws_sqs_queue.queue["avatar_queue"].arn : null
}

output "avatar_queue_url" {
  value = contains(keys(var.sqs_queues), "avatar_queue") ? aws_sqs_queue.queue["avatar_queue"].url : null
}

output "pre_enrichment_queue_arn" {
  value = contains(keys(var.sqs_queues), "pre_enrichment_queue") ? aws_sqs_queue.queue["pre_enrichment_queue"].arn : null
}

output "pre_enrichment_queue_url" {
  value = contains(keys(var.sqs_queues), "pre_enrichment_queue") ? aws_sqs_queue.queue["pre_enrichment_queue"].url : null
}

output "vtr_queue_arn" {
  value = contains(keys(var.sqs_queues), "vtr_queue") ? aws_sqs_queue.queue["vtr_queue"].arn : null
}

output "vtr_queue_url" {
  value = contains(keys(var.sqs_queues), "vtr_queue") ? aws_sqs_queue.queue["vtr_queue"].url : null
}

output "backpressure_queue_arn" {
  value = contains(keys(var.sqs_queues), "backpressure") ? aws_sqs_queue.queue["backpressure"].arn : null
}

output "backpressure_queue_url" {
  value = contains(keys(var.sqs_queues), "backpressure") ? aws_sqs_queue.queue["backpressure"].url : null
}

output "enriched_queue_arn" {
  value = contains(keys(var.sqs_queues), "enriched_queue") ? aws_sqs_queue.queue["enriched_queue"].arn : null
}

output "enriched_queue_url" {
  value = contains(keys(var.sqs_queues), "enriched_queue") ? aws_sqs_queue.queue["enriched_queue"].url : null
}
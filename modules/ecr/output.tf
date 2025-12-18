output "repo_urls" {
  description = "ECR repository URLs keyed by repo name"
  value = {
    for repo in aws_ecr_repository.this :
    repo.name => repo.repository_url
  }
}

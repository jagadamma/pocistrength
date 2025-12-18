resource "aws_codebuild_project" "this" {
  name = "${var.project_name}-${var.service_name}"
  service_role = var.service_role

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "AWS_REGION"
      value = var.region
    }

    environment_variable {
      name  = "ECR_REPO"
      value = var.ecr_repo_url
    }
  }

  source {
    type = "CODEPIPELINE"
  }

  tags = var.tags
}

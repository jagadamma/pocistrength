########################################
# CODEPIPELINE ROLE
########################################
resource "aws_iam_role" "codepipeline" {
  name = "${var.name_prefix}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

########################################
# CODESTAR CONNECTION
########################################
resource "aws_iam_policy" "codestar_use_connection" {
  name = "${var.name_prefix}-codestar-use-connection"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "codestar-connections:UseConnection"
      Resource = var.codestar_connection_arn
    }]
  })
}

########################################
# CODEBUILD PERMISSIONS
########################################
resource "aws_iam_policy" "codepipeline_codebuild" {
  name = "${var.name_prefix}-codepipeline-codebuild"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "codebuild:StartBuild",
        "codebuild:BatchGetBuilds"
      ]
      Resource = "*"
    }]
  })
}

########################################
# CODEDEPLOY PERMISSIONS
########################################
resource "aws_iam_policy" "codepipeline_codedeploy" {
  name = "${var.name_prefix}-codepipeline-codedeploy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "codedeploy:GetApplication",
        "codedeploy:GetApplicationRevision",
        "codedeploy:GetDeploymentGroup",
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment",
        "codedeploy:GetDeploymentConfig"
      ]
      Resource = "*"
    }]
  })
}

########################################
# ECS PERMISSIONS (CRITICAL FIX)
########################################
resource "aws_iam_policy" "codepipeline_ecs" {
  name = "${var.name_prefix}-codepipeline-ecs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecs:RegisterTaskDefinition",
        "ecs:DescribeTaskDefinition",
        "ecs:DescribeServices",
        "ecs:UpdateService"
      ]
      Resource = "*"
    }]
  })
}

########################################
# ATTACH POLICIES
########################################
resource "aws_iam_role_policy_attachment" "codepipeline_codestar" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codestar_use_connection.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_codebuild_attach" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codepipeline_codebuild.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_codedeploy_attach" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codepipeline_codedeploy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_ecs_attach" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codepipeline_ecs.arn
}

########################################
# AWS MANAGED POLICIES
########################################
resource "aws_iam_role_policy_attachment" "codepipeline_main" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "codepipeline_passrole" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

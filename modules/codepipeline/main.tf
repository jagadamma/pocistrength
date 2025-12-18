resource "aws_codepipeline" "this" {
  name     = "${var.name_prefix}-${var.environment}-${var.pipeline_name}"
  role_arn = var.role_arn

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"
  }

  ################################
  # SOURCE STAGE (GitHub via CodeStar)
  ################################
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn = var.codestar_connection_arn

        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.github_branch
        DetectChanges    = "true"
      }
    }
  }

  ################################
  # BUILD STAGE
  ################################
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }

  ################################
  # DEPLOY STAGE (ECS / CodeDeploy)
  ################################
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ApplicationName                = var.codedeploy_app_name
        DeploymentGroupName            = var.codedeploy_dg_name
        # ✅ Automatically taken from GitHub build artifact
        TaskDefinitionTemplateArtifact = "build_output"
        #  TaskDefinitionTemplatePath     = each.key == "app1" ? "taskdef.json" : "taskdef-app2.json"
        TaskDefinitionTemplatePath     = var.taskdef_template_path
        AppSpecTemplateArtifact        = "build_output"
        #   AppSpecTemplatePath            = "appspec-${var.service_name}.yaml"
        AppSpecTemplatePath = var.appspec_template_path

      }
    }
  }
}

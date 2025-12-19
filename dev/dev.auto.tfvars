environment = "dev"
region      = "ap-south-1"
name_prefix = "sharadha-dev-us"

common_tags = {
  Terraformed = "True"
  Environment = "dev"
}
#
#
#
#
#aws_account_id  = "200901485389"
#github_repository     = ["Zampfi/pantheon", "Zampfi/infrastructure", "Zampfi/application-platform", "Zampfi/data_platform"]  
#role_name             = "OIDCRole"
#terraform_oidc_policy = "AdministratorAccess"
#gitlab_projects = [
#  "mygroup/myproject",
#  "anothergroup/anotherproject"
#]

########################################################################################################

#bastion = {
#  instance_type       = "t2.medium"
#  bastion_volume_size = "15"
#  bastion_volume_type = "gp3"
#}

########################################################################################################


########################################################################################################

vpcs = [
  {
    name = "Sharadha-dev-us-vpc"
    cidr = "10.0.0.0/16" #VPC CIDR
  }
]

public_subnets = [
  {
    name              = "sharadha-dev-us-public-subnet-1"
    cidr              = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
  },
  {
    name              = "sharadha-dev-us-public-subnet-2"
    cidr              = "10.0.2.0/24"
    availability_zone = "ap-south-1b"
  }
]
private_subnets = [
  {
    name              = "sharadha-dev-us-private-subnet-1"
    cidr              = "10.0.3.0/24"
    availability_zone = "ap-south-1a"
  },
  {
    name              = "sharadha-dev-us-private-subnet-2"
    cidr              = "10.0.4.0/24"
    availability_zone = "ap-south-1b"

  },
]

#db_subnets = [
#  {
#    name              = "sharadha-dev-us-db-subnet-1"
#    cidr              = "10.0.20.0/24"
#    availability_zone = "ap-south-1a"
#  },
#  {
#    name              = "sharadha-dev-us-db-subnet-2"
#    cidr              = "10.0.21.0/24"
#    availability_zone = "ap-south-1b"
#    tags = {
#      "kubernetes.io/cluster/sharadha-dev-us-cluster" = "shared"
#      "kubernetes.io/role/internal-elb"               = "1"
#      SubnetType                                      = "Private"
#      "karpenter.sh/discovery"                        = "sharadha-dev-us-cluster"
#
#    }
#  }
#]

private_subnet_route_tables = [
  {
    name = "sharadha-dev-us-private-rt"
    tags = {
      SubnetType = "Private"

    }
  }
]

public_subnet_route_tables = [
  {
    name = "sharadha-dev-us-public-rt"
    tags = {
      SubnetType = "Public"

    }
  }
]

db_subnet_route_tables = [
  {
    name = "sharadha-dev-us-db-rt"
    tags = {
      SubnetType = "db"
    }
  }
]

nat_gateways = [
  {
    name = "sharadha-dev-us-nat-gw"
  }
]

vpc_flow_logs = {
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  log_group_name       = "sharadha-dev-us-vpc-flow-logs"
  log_retention_days   = 30
  environment          = "dev"
}


# ------------------------------
# ACM Single SAN Certificate
# ------------------------------
multi_domain_cert = {
  domain_name = "harshitha.com"

  subject_alternative_names = [
    "app.harshitha.com",
    "api.harshitha.com"
  ]
}
validation_method = "DNS"


hosted_zones = {
  "harshitha.com" = {
    comment       = "Production domain"
    force_destroy = false
    private_zone  = false
  }

  "alekya.com" = {
    comment       = "Internal"
    force_destroy = true
    private_zone  = false
  }
}

records = {
  app-a-record-harshitha = {
    zone_name = "harshitha.com"
    name      = "app.harshitha.com"
    type      = "A"
    ttl       = 300
    records   = ["10.0.0.10"]
  }

  api-cname-harshitha = {
    zone_name = "harshitha.com"
    name      = "api.harshitha.com"
    type      = "CNAME"
    ttl       = 300
    records   = ["app.harshitha.com"]
  }

  app-a-record-internal = {
    zone_name = "alekya.com"
    name      = "app.alekya.com"
    type      = "A"
    ttl       = 300
    records   = ["10.0.0.10"]
  }

  api-cname-internal = {
    zone_name = "alekya.com"
    name      = "api.alekya.com"
    type      = "CNAME"
    ttl       = 300
    records   = ["app.ialekya.com"]
  }

  # alb-alias = {
  #   zone_name = "harshitha.com"
  #   name      = "web.harshitha.com"
  #   type      = "A"
  #   ttl       = 0
  #   records   = []
  #   alias = {
  #     name                   = "dualstack.my-alb.amazonaws.com"
  #     zone_id                = "Z2FDTNDATAQYW2"
  #     evaluate_target_health = true
  #   }
  # }
}

########################################################################################################

domains = [
  "app.harshitha.com",
  "api.harshitha.com",
  "harshitha.com",
]

rds = {
  mysql = {
    name                                  = "sharadha-dev-us-mysql-db"
    db_identifier                         = "sharadha-mysql-db"
    instance_class                        = "db.t3.medium"
    allocated_storage                     = 30
    engine                                = "mysql"
    engine_version                        = "8.0.43"
    db_name                               = "mysqldb"
    db_username                           = "mysqladmin"
    db_sg_name                            = "sharadha-dev-us-mysql-sg"
    subnet_group_name                     = "sharadha-dev-us-mysql-subnet-group"
    kms_key_name                          = "sharadha-dev-us-mysql-kms-key"
    parameter_group_name                  = "sharadha-dev-us-mysql-parmater-group"
    parameter_group_family                = "mysql8.0"
    auto_minor_version_upgrade            = true
    backup_retention_period               = 7
    port                                  = 3306
    copy_tags_to_snapshot                 = true
    performance_insights_enabled          = true
    performance_insights_retention_period = 7
    multi_az                              = false
    publicly_accessible                   = false
    skip_final_snapshot                   = true
    storage_encrypted                     = true
    storage_type                          = "gp3"
    deletion_protection                   = true
  }
}


sns = {
  "sharadha-dev-us-topic" = {
    display_name = "sharadha-dev-us-topic"

    subscriptions = [
      {
        protocol = "email"
        endpoint = "orders@company.com"
      }
    ]
  }
}

secrets_list = [
  {
    name        = "api-token"
    description = "API token for service"
  },
  {
    name        = "db-password"
    description = "Database password"
  }
]

sqs_queues = {
  orders_queue = {
    name                       = "orders-queue-dev"
    max_message_size           = 262144
    message_retention_seconds  = 345600
    visibility_timeout_seconds = 30
    delay_seconds              = 0
    receive_wait_time_seconds  = 10
    sqs_managed_sse_enabled    = true
  }

  payments_queue = {
    name                       = "payments-queue-dev"
    max_message_size           = 262144
    message_retention_seconds  = 86400
    visibility_timeout_seconds = 45
    delay_seconds              = 5
    receive_wait_time_seconds  = 10
    sqs_managed_sse_enabled    = true
  }
}

distributions = {
  app1 = {
    domain_name    = "skyclouds.live"
    hosted_zone_id = "Z04470213W5YJ2PYTYHK"
    origin_path    = "/static"
    tags = {
      Environment = "dev"
      App         = "app1"
    }
  }
}


########################################################################################################


########################################################################################################

ecr_repositories = [
  {
    name              = "sharadha-dev-us-ecr"
    enable_scanning   = true
    tag_mutability    = "MUTABLE"
    enable_encryption = true
    enable_lifecycle  = true
  },
#  {
#    name              = "sharadha-dev-us-ecr1"
#    enable_scanning   = true
#    tag_mutability    = "MUTABLE"
#    enable_encryption = true
#    enable_lifecycle  = true
#  }
]

lifecycle_policy = {
  rulePriority = 1
  description  = "Keep only the last 10 images"
  tagStatus    = "any"
  countType    = "imageCountMoreThan"
  countNumber  = 10
  actionType   = "expire"
}

kms_key_alias = "alias/sharadha-dev-us-ecr-kms-key"

########################################################################################################

ecs = {
  container_image = "132398229882.dkr.ecr.us-east-2.amazonaws.com/sharadha-dev-us-ecr:latest"
  container_port  = 80
  container_name  = "app1"

  task_cpu         = 256
  task_memory      = 512
  desired_count    = 1
  alb_idle_timeout = 60

  assign_public_ip = false
}
security_groups = {
  alb = {
    ingress = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }

  ecs = {
    ingress = [
      {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        security_groups = ["alb"] # reference ALB SG dynamically
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}

task_definition = {
  app1 = {

    image  = "132398229882.dkr.ecr.us-east-2.amazonaws.com/sharadha-dev-us-ecr"
    port   = 80
    cpu    = 256
    memory = 512
  }
  app2 = {
    image  = "132398229882.dkr.ecr.us-east-2.amazonaws.com/sharadha-dev-us-ecr1"
    port   = 8080
    cpu    = 256
    memory = 512
  }
}

cicd = {
  pipeline_name   = "sharadha-dev-pipeline"
  artifact_bucket = "sharadha-dev-us-codepipeline-artifacts"

  github = {
    owner          = "jagadamma"
    repo           = "nginx-dockerdile-deployment"
    branch         = "master"
    connection_arn = "arn:aws:codeconnections:us-east-2:132398229882:connection/01c78266-df87-4b67-9b03-352a1bb1a3fe"
  }

  codebuild = {
    project_name = "sharadha-dev-codebuild"
    image        = "aws/codebuild/standard:7.0"
    compute_type = "BUILD_GENERAL1_SMALL"
  }

  codedeploy = {
    application_name = "sharadha-dev-ecs-app"
    deployment_groups = {
      app1 = { name = "sharadha-dev-app1-dg" }
      app2 = { name = "sharadha-dev-app2-dg" }
    }
  }
}
artifact_bucket = "sharadha-dev-us-codepipeline-artifacts"

service_ecr_map = {
  app1 = "sharadha-dev-us-ecr"
  app2 = "sharadha-dev-us-ecr"
}

########################################################################################################

s3bucketslist = [
  {
    bucket_name   = "sharadha-dev-us-codepipeline-artifacts"
    force_destroy = true
    versioning    = true
    public_access = true
  },
]


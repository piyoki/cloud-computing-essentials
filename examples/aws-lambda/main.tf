variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "image_tag" {
  type        = string
  description = "The version tag to the container image"
  default     = "latest"
}

provider "aws" {
  region                  = var.region
  profile                 = "default"
  shared_credentials_file = "~/.aws/credentials"
}

locals {
  prefix              = "dev"
  account_id          = "<account_id>"
  role                = "lambda-role"
  ecr_repository_name = "${local.prefix}-demo-lambda-container"
  ecr_image_tag       = var.image_tag
}

### ECR

resource "aws_ecr_repository" "repo" {
  name                     = local.ecr_repository_name
  image_tag_mutability     = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    # use custom KMS
    # encryption_type: "KMS"
    # kms_key: ""
    encryption_type = "AES256"
  }
  tags = {
    Version = "${var.image_tag}"
  }
}

resource "null_resource" "ecr_image" {
  triggers = {
    docker_file = md5(file("./Dockerfile"))
    image_tag   = var.image_tag
  }

  provisioner "local-exec" {
    command = <<EOF
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com
      cd ${path.module}/
      docker build -t ${aws_ecr_repository.repo.repository_url}:${local.ecr_image_tag} .
      docker push ${aws_ecr_repository.repo.repository_url}:${local.ecr_image_tag}
    EOF
 }
}

data "aws_ecr_image" "lambda_image" {
  depends_on = [
    null_resource.ecr_image
  ]
  repository_name = local.ecr_repository_name
  image_tag       = local.ecr_image_tag
}

### IAM

resource "aws_iam_role" "lambda" {
  name = "${local.prefix}-lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow"
       }
  ]
}
EOF
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [ "*" ]
    sid = "CreateCloudWatchLogs"
  }

  statement {
    actions = [
      "apigateway:*"
    ]
    effect = "Allow"
    resources = [ "arn:aws:apigateway:*::/*" ]
    sid = "APIGatewayControl"
  }

  statement {
    actions = [
      "execute-api:Invoke",
      "execute-api:ManageConnections"
    ]
    effect = "Allow"
    resources = [ "arn:aws:execute-api:*:*:*" ]
    sid = "InvokeAPI"
  }

  statement {
    actions = [
      "ecr:SetRepositoryPolicy",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload"
    ]
    effect = "Allow"
    resources = [ "arn:aws:ecr:${var.region}:${local.account_id}:repository/${local.ecr_repository_name}" ]
    sid = "GetRepository"
  }
}

resource "aws_iam_policy" "lambda" {
  name = "${local.prefix}-lambda-policy"
  path = "/"
  policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_policy_attachment" "lambda" {
  name       = "${local.prefix}-lambda-policy"
  roles      = [aws_iam_role.lambda.name]
  policy_arn = aws_iam_policy.lambda.arn
}

### Lambda Function

resource "aws_lambda_function" "dev_go_lambda" {
  function_name = "dev_go_lambda"
  role          = aws_iam_role.lambda.arn
  image_uri     = "${aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type  = "Image"
  memory_size   = 128
  timeout       = 300
  tags          = {
    Version = "${var.image_tag}"
  }
}

### API Gateway

resource "aws_api_gateway_rest_api" "api" {
  name        = "api_dev_go_lambda"
  description = "default lambda function gateway"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.method.http_method

  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.dev_go_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.integration,
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "dev"
}

resource "aws_lambda_permission" "api_invoke_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dev_go_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*"
}


### Outputs

output "lambda_name" {
  value = aws_lambda_function.dev_go_lambda.id
}

output "version" {
  value = var.image_tag
}

output "base_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}

variable region {
  default = "ap-northeast-1"
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
  ecr_image_tag       = "0.0.1"
}

resource aws_ecr_repository repo {
  name = local.ecr_repository_name
}

resource null_resource ecr_image {
 triggers = {
   docker_file = md5(file("./Dockerfile"))
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

data aws_ecr_image lambda_image {
  depends_on = [
    null_resource.ecr_image
  ]
  repository_name = local.ecr_repository_name
  image_tag       = local.ecr_image_tag
}

resource "aws_lambda_function" "dev-go-lambda" {
  function_name     = "dev-go-lambda"
  role              = "arn:aws:iam::${local.account_id}:role/${local.role}"
  image_uri         = "${aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type      = "Image"
  memory_size       = 128
  timeout           = 300
}

output "lambda_name" {
  value = aws_lambda_function.dev-go-lambda.id
}

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

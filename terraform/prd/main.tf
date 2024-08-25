terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.51.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-backend-nextjs-app-2024"
    key            = "state/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }

  required_version = "~> 1.9.0"
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      environment = "Prod"
      app         = "Blog"
    }
  }
}

variable "image_id" {
  type      = string
  sensitive = true
}

resource "aws_lambda_function" "backend" {
  function_name = "dockerized-blog"
  timeout       = 5
  image_uri     = var.image_id
  package_type  = "Image"
  role          = aws_iam_role.lambda_sts.arn
}

resource "aws_iam_role" "lambda_sts" {
  name = "lambda"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.blog.execution_arn}/*/*"
}

resource "aws_apigatewayv2_api" "blog" {
  name          = "blog-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.blog.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda-proxy" {
  api_id = aws_apigatewayv2_api.blog.id

  integration_uri        = aws_lambda_function.backend.invoke_arn
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.blog.id
  route_key = "$default"

  target = "integrations/${aws_apigatewayv2_integration.lambda-proxy.id}"
}

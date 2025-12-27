resource "aws_dynamodb_table" "counter" {
  name         = "resume_visits"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

}
resource "aws_iam_role" "lambda_role" {
  name = "ResumeVisitorCounter-role-bnyatr88"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  lifecycle {
    # During takeover, ignore path drift if AWS/provider normalization fights us.
    ignore_changes = [path, managed_policy_arns]
  }
}


resource "aws_iam_role_policy_attachment" "ddb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::831926599193:policy/ResumeVisitsDynamoPolicy"
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::831926599193:policy/service-role/AWSLambdaBasicExecutionRole-8969c120-a17d-4c9a-9141-64f69e3778a6"
}

resource "aws_lambda_function" "counter" {
  function_name = "ResumeVisitorCounter"     # exact name
  role          = aws_iam_role.lambda_role.arn

  runtime = "python3.12"                     # match your live runtime
  handler = "app.lambda_handler"             # match your live handler
  
  filename = "${path.module}/placeholder.zip"

  timeout     = 3                            # match
  memory_size = 128                          # match

  environment {
    variables = {
      TABLE_NAME = "resume_visits"           # match your live env vars
    }
  }
  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
      last_modified,
      version,
      qualified_arn,
      publish,
      layers,
      architectures
    ]
  }

 
}

resource "aws_apigatewayv2_api" "api" {
  name          = "ResumeVisitorCounter_API"
  protocol_type = "HTTP"
  
   cors_configuration {
    allow_credentials = false
    allow_headers     = ["content-type"]
    allow_methods     = ["GET", "OPTIONS"]
    allow_origins     = ["https://harry-sivasambu.com"]
    expose_headers    = []
    max_age           = 0
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.counter.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "count" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /count" # match your real route key
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default" # match
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "1376bcd4-505e-5c9b-9b1b-d098f5500d35"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.counter.function_name
  principal     = "apigateway.amazonaws.com"

  # match AWS exactly: .../*/*/count
  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*/count"
}





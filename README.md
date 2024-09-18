# Terraform module to provision an AWS API Gateway REST API with OpenAPI and lambda integrations

This module is designed for lambda integrations and provides cloudwatch logging.
Resources, endpoints and integrations are specified with an OpenAPI specification.

# Example
In this example, a REST API with Cognito authorizer and a single lambda integration is used to present `GET` and `OPTIONS` methods for a `/widgets` endpoint.
This OpenAPI document should be created as `openapi.yaml.tftpl` so that Terraform can inject in Cognito and Lambda ARNs.
```yaml
openapi: 3.0.1
info:
  title: Widgets API
  version: 1.0.0
components:
  securitySchemes:
   cognito:
    type: apiKey
    name: Authorization
    in: header
    x-amazon-apigateway-authtype: cognito_user_pools
    x-amazon-apigateway-authorizer:
      type: cognito_user_pools
      providerARNs:
        - ${cognito_arn}
  responses:
    Options:
      description: Return available methods for this resource
      headers:
        Access-Control-Allow-Methods:
          description: The allowed methods for this resource
          schema:
            type: string
            example: OPTIONS, GET, HEAD, POST, PATCH, DELETE
        Access-Control-Allow-Origin:
          description: The allowed origins for this resource
          schema:
            type: string
            example: '*'
        Access-Control-Allow-Headers:
          description: The allowed headers for this resource
          schema:
            type: string
            example: 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'
  schemas:
    # Base schemas
    Entity:
      type: object
      properties:
        uid:
          description: Universally Unique identifier for this entity
          type: string
          format: uuid
          readOnly: true
    PaginatedResponse:
      type: object
      properties:
        metadata:
          description: Metadata describing all available entities of this resource
          type: object
          properties:
            pagination:
              description: Pagination metadata block describing records and pages
              type: object
              properties:
                total:
                  type: integer
                  format: int64
                  description: The total number of records that match the current filters
                limit:
                  type: integer
                  format: int64
                  description: The maximum number of records shown per page
                page:
                  type: integer
                  format: int64
                  description: The current page of records
                pages:
                  type: integer
                  format: int64
                  description: The total number of pages
                start:
                  type: integer
                  format: int64
                  description: The starting item number in total
                end:
                  type: integer
                  format: int64
                  description: The ending item number in total
    # Paginated response schemas
    PaginatedResponseWidgets:
      type: object
      allOf:
      - $ref: '#/components/schemas/PaginatedResponse'
      - type: object
        properties:
          records:
            type: array
            items:
              $ref: '#/components/schemas/Widget'
    # Individual schemas
    Widget:
      type: object
      allOf:
      - $ref: '#/components/schemas/Entity'
      properties:
        widgetDate:
          type: string
          format: datetime
        widgetRef:
          type: string
# Apply security scheme to all endpoints
security:
  - cognito: []
# Paths
paths:
  /widgets:
    get:
      description: Returns paginated list of widgets
      responses:
        '200':
          description: A paginated list of widgets.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PaginatedResponseWidgets'
      x-amazon-apigateway-integration:
        contentHandling: CONVERT_TO_TEXT
        httpMethod: POST # Lambdas must be POST
        passthroughBehavior: never # Ensure a 415 unsupported media type error is returned
        payloadFormatVersion: "1.0"
        requestParameters: body
        type: aws_proxy
        uri: ${python_rest_api_arn}
        timeoutInMillis: 29000
    options:
      security: []
      responses:
        '200':
          $ref: '#/components/responses/Options'
      x-amazon-apigateway-integration:
        contentHandling: CONVERT_TO_TEXT
        httpMethod: POST # Lambdas must be POST
        passthroughBehavior: never # Ensure a 415 unsupported media type error is returned
        payloadFormatVersion: "1.0"
        requestParameters: body
        type: aws_proxy
        uri: ${python_rest_api_arn}
        timeoutInMillis: 29000
```

Example lambda function packed and deployed locally as a zip file that is used for the REST API below.
It is assumed that data lookups for Cognito, Security groups and Subnets are provided.
```terraform
resource "null_resource" "package_lambda" {

  triggers = {
    timestamp : timestamp()
  }

  provisioner "local-exec" {
    command = "pip install -r ../../../../../apps/python/rest-api/requirements.txt --target ./tmp/package"
  }

  provisioner "local-exec" {
    command = "cp -r ../../../../../apps/python/rest-api/src ./tmp/package"
  }

  provisioner "local-exec" {
    command = "cp -r ../../../../../apps/python/rest-api/lambda_handler.py ./tmp/package"
  }
}

data "archive_file" "api" {
  type        = "zip"
  output_path = "${path.cwd}/tmp/python-rest-api.zip"
  source_dir  = "${path.cwd}/tmp/package"

  depends_on = [
    null_resource.package_lambda
  ]
}

module "lambda_python_rest_api" {
  source  = "voquis/lambda-cloudwatch/aws"
  version = "1.0.1"

  filename         = data.archive_file.api.output_path
  source_code_hash = data.archive_file.api.output_base64sha256
  function_name    = "python-rest-api"
  handler          = "lambda_handler.lambda_handler"
  runtime          = "python3.12"
  role_name        = "lambda-python-rest-api"
  vpc_policy_name  = "lambda-python-rest-api-vpc"
  log_policy_name  = "lambda-python-rest-api-log"
  timeout          = 300

  vpc_config = {
    security_group_ids = [
      data.aws_security_group.this.id
    ]

    subnet_ids = data.aws_subnets.app.ids
  }
}

```


```terraform
module "rest_api" {
  source  = "voquis/rest-api-gateway/aws"
  version = "0.1.0"

  rest_api_body = jsonencode(yamldecode(templatefile(
    "${path.cwd}/../../../../../api/openapi.yaml.tftpl",
    {
      cognito_arn         = data.aws_cognito_user_pools.this.arns[0],
      python_rest_api_arn = module.lambda_python_rest_api.lambda_function.invoke_arn
    }
  )))

  lambdas_to_invoke_names = [
    module.lambda_python_rest_api.lambda_function.function_name
  ]
}

```

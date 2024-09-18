# Account (for CloudWatch logging)
variable "lambdas_to_invoke_names" {
  type        = list(string)
  description = "A list of lambda function names to be granted permission for invoking"
  default     = []
}

# REST API
variable "rest_api_body" {
  type        = string
  description = "OpenAPI JSON document with all extension values interpolated"
}

variable "rest_api_name" {
  type        = string
  description = "name of REST API"
  default     = "app"
}

variable "rest_api_put_rest_api_mode" {
  type        = string
  description = "How multiple versions of OpenAPI changes are handled"
  default     = "merge"
}

variable "rest_api_endpoint_configuration_types" {
  type        = list(string)
  description = "Endpoint configuration types"
  default     = ["REGIONAL"]
}

# Stage
variable "stage_name" {
  type        = string
  description = "Stage name"
  default     = "v1"
}

# Method settings
variable "method_setting_path" {
  type        = string
  description = "Path to which logging settings apply"
  default     = "*/*"
}

variable "method_settings_metrics_enabled" {
  type        = bool
  description = "Whether metrics are enabled for method"
  default     = false
}

variable "method_settings_data_trace_enabled" {
  type        = bool
  description = "Whether data traces are enabled for method"
  default     = false
}

variable "method_settings_logging_level" {
  type        = string
  description = "CloudWatch Logging level"
  default     = "INFO"
}

# IAM Policy (log)
variable "iam_policy_log_name" {
  type        = string
  description = "IAM Policy name for logging"
  default     = "rest-api-log"
}

# IAM Policy
variable "iam_role_name" {
  type        = string
  description = "IAM Role name"
  default     = "rest-api"
}

# Define AWS provider configuration
provider "aws" {
  # Specify the AWS region where resources will be provisioned
  region     = "us-east-1"
  
  # Provide your AWS access key
  access_key = "ACCESS_KEY"
  
  # Provide your AWS secret key
  secret_key = "SECRET_KEY"
}
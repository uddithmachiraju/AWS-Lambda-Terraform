This project sets up a Lambda function to deploy a Nimbus app with environment variable and integrated via REST API Gateway.

# Nimbus App Deployment using Terraform and AWS

This Terraform project automates the deployment of the **Nimbus App** using **AWS Lambda** and integrates it with **REST API Gateway**.

## What This Project Does

- Deploys an AWS Lambda Function
- Uses environment variables for configuration
- Creates and configures the REST API Gateway
    - Sets up routes, methods, CORS, and integrates them with Lambda
- Manages and creates necessary IAM roles and policies
- Creates and configures an S3 bucket

## How to Use This Project

1. **Clone the repository**

2. **Prepare your Lambda code**
   - Update the `function.zip` with your Lambda function code
   - Or replace it with your own zip file

3. **Configure variables**
   - Update the `variables.tf` file if needed and add the `env` variables in `.tfvars` file.
   - Ensure environment variables used in Terraform are also present in your Lambda code

4. **Deploy with Terraform**
   - Review and use the `Makefile` if available
   - Or run the following commands:

        ```bash
        terraform init
        terraform plan
        terraform apply
        ```

# Terraform & Packer Deployment Workflow

This repository contains infrastructure and platform code that uses Terraform and Packer to deploy AWS resources, create AMIs, and provision applications. The following instructions outline how to run each step using Docker Compose.

---

## Prerequisites

- Docker and Docker Compose installed
- AWS credentials configured, Terraform, Packer and HCP environment variables in `.env` file
- Permissions to create IAM roles, S3 buckets, and EC2 resources in your AWS account

---

## Execution Steps: 
**Important: Before executing any of these commands, you will need to change the working directory location of the terraform service inside the docker-compose.yaml file so you can build the correct terraform project.**

1. Create locally an AWS IAM role so HCP agents -> AWS
docker compose run --rm --name build-aws-role terraform

2. HCP and AWS Testing (OIDC - Dynamic Credentials)
docker compose run --rm --name oidc-test terraform

3. Build the s3 bucket and networking for packer
docker compose run --rm --name pre-req terraform

4. Build the ami using packer
docker compose run --rm --name build-ami packer

5. Deploy the infrastructure
docker compose run --rm --name infra terraform

6. Deploy the platform
docker compose run --rm --name platform terraform

7. Deploy the webapps
docker compose run --rm --name webapps terraform

# Build an Image
docker build -t flask-mongo-app .
docker run -p 8000:8000 flask-mongo-app

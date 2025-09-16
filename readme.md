# Wiz Infrastructure & WebApp Project 🌟

Welcome to the Wiz Infrastructure & WebApp Project! 🚀 This repository showcases a complete end-to-end infrastructure setup using Terraform, a Python web application, Docker, and Kubernetes on AWS.

This project was built to demonstrate high-availability architecture, Terraform automation, and Kubernetes deployment workflows—all managed through HCP Terraform with short-lived OIDC credentials.

## 🌐 Project Overview

In this project, I built a resilient and scalable infrastructure on AWS, along with a test web application:

### 🏗 Architecture Diagram

Here’s a simplified view of the infrastructure:

                 ┌───────────────┐
                 │  Internet     │
                 └─────┬─────────┘
                       │
                 ┌───────────────┐
                 │  Internet GW  │
                 └─────┬─────────┘
                       │
              ┌────────┴────────┐
              │  Public Subnet  │
        ┌─────┴──────┐     ┌────┴─────┐
        │  EC2 Mongo │     │ EC2 Mongo│
        └────────────┘     └──────────┘
              │                 │
        ┌─────┴─────────────────┴─────┐
        │         Route Tables        │
        └─────┬─────────────────┬─────┘
              │                 │
      ┌───────┴──────────┐ ┌────┴─────────────┐
      │ Private Subnet 1 │ │ Private Subnet 2 │
      │  (EKS Nodes)     │ │  (EKS Nodes)     │
      └──────────────────┘ └──────────────────┘
              │                      │
              └───── Kubernetes ─────┘
                        │
                  ┌─────┴─────┐
                  │ Web App   │
                  │ Container │
                  └───────────┘


### Networking:

VPC spanning 2 Availability Zones (AZs)

2 public and 2 private subnets

Public subnets connected to an Internet Gateway

Private subnets connected to a NAT Gateway

Route tables configured for proper traffic flow

### Database Layer:

2 EC2 instances running MongoDB in public subnets

SSH access enabled for maintenance

Connection allowed from the EKS cluster in private subnets

High availability ensured by spreading across multiple AZs

### Application Layer:

Dockerized Python web app deployed using Kubernetes

External traffic routed to the web app

Web app connects securely to MongoDB instances

### Infrastructure Automation:

Terraform manages networking, compute, and Kubernetes resources

HCP Terraform workspaces and variable sets used for environment management

AWS OIDC provider enables short-lived credentials for secure access

## ⚡ Prerequisites

Before running the project, make sure you have:

Docker & Docker Compose installed

Terraform, Packer, and HCP CLI installed

AWS credentials with permissions to create IAM roles, EC2, S3 buckets, and networking resources

.env file containing your AWS, Terraform, and HCP environment variables

## 🛠 Execution Workflow

Important: Update the working directory of the Terraform service in docker-compose.yaml to point to the correct project path.

```commandline
docker compose run --rm --name aws-role terraform
docker compose run --rm --name oidc-test terraform

docker compose run --rm --name pre-req terraform
docker compose run --rm --name build-ami packer

docker compose run --rm --name infra terraform
docker compose run --rm --name platform terraform
docker compose run --rm --name apps terraform
```

## 🐳 Build & Run Docker Image Locally

```commandline
docker build -t webapp:latest .
docker run -p 5000:5000 webapp:latest
docker tag webapp:latest ghcr.io/rainer85ah/wiz-webapp:latest
docker push ghcr.io/rainer85ah/wiz-webapp:latest
```

## CI/CD Piepline

| Branch / Event            | Init | Fmt | Validate | Plan | Apply                    |
| ------------------------- | ---- | --- | -------- | ---- | ------------------------ |
| `feature/*` push          | ✅    | ✅   | ✅        | ✅    | ❌                        |
| PR to `dev`               | ✅    | ✅   | ✅        | ✅    | ❌                        |
| Push to `dev`             | ✅    | ✅   | ✅        | ✅    | ✅                        |
| PR to `stag` / `main`     | ✅    | ✅   | ✅        | ✅    | ❌                        |
| Push to `stag` / `main`   | ✅    | ✅   | ✅        | ✅    | ✅                        |
| Manual workflow\_dispatch | ✅    | ✅   | ✅        | ✅    | ✅ (if environment != ci) |


## 📌 Highlights

Fully automated infrastructure provisioning with Terraform

High availability design with multiple AZs

Dockerized web app integrated with Kubernetes

Secure AWS access using OIDC short-lived credentials

Practical end-to-end workflow for DevOps and SRE projects

## 🚀 Next Steps / Improvements

Add monitoring and alerting for EC2 and EKS workloads

Implement CI/CD pipeline for automatic web app deployment

Move MongoDB to private subnets with secure access

Enable Terraform module testing with terraform plan and validate

## 📚 References

Terraform Documentation
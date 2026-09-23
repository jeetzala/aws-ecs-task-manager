# ☁️ AWS ECS Fargate Task Manager

This project demonstrates the design and deployment of a containerized application on **Amazon Web Services (AWS)** using **Docker, Amazon ECR, Amazon ECS Fargate, an Application Load Balancer (ALB), AWS Secrets Manager, IAM, Amazon CloudWatch, AWS CodePipeline, AWS CodeBuild, AWS CodeConnections, Amazon S3, and Terraform**.

The application is a Python Flask web application containerized with Docker and deployed to **Amazon ECS Fargate** behind an Application Load Balancer.

The project was built and validated in the **AWS US East (N. Virginia) Region (`us-east-1`)**.

---

# 🚀 Project Highlights

✅ Python Flask Application

✅ Docker Containerization

✅ Non-Root Docker User

✅ Docker Health Check

✅ Amazon ECR Container Registry

✅ Amazon ECS Fargate

✅ Application Load Balancer

✅ ECS Target Group Health Checks

✅ ECS Service Rolling Deployments

✅ AWS Secrets Manager

✅ IAM Least-Privilege Access

✅ Amazon CloudWatch Logs

✅ GitHub Integration

✅ AWS CodeConnections

✅ AWS CodePipeline

✅ AWS CodeBuild

✅ Automated Docker Build & Health Test

✅ Automated ECR Image Push

✅ Automated ECS Deployment

✅ Terraform Infrastructure as Code

✅ Existing AWS Resource Import

✅ Terraform Drift Validation

✅ End-to-End Application Validation

---

# 🏗️ Architecture Overview

## Architecture Diagram

![AWS ECS Fargate Architecture](screenshots/architechture-diagram.png)

The application and deployment infrastructure follows this flow:

```text
                         GitHub
                            │
                            ▼
                    AWS CodePipeline
                            │
                            ▼
                     AWS CodeBuild
                            │
                  ┌─────────┴─────────┐
                  │                   │
             Docker Build        Health Test
                  │
                  ▼
              Amazon ECR
                  │
                  ▼
          ECS Task Definition
                  │
                  ▼
           ECS Fargate Service
                  │
                  ▼
       Application Load Balancer
                  │
                  │ HTTP :80
                  ▼
          Flask Application
              Container :5000
```

Supporting AWS services provide security and observability:

```text
ECS Fargate Task
      │
      ├── AWS Secrets Manager
      │       └── TASK_MANAGER_TOKEN
      │
      ├── IAM Execution Role
      │       └── secretsmanager:GetSecretValue
      │
      └── CloudWatch Logs
              └── /aws/ecs/task-manager
```

Terraform is used to represent and manage the deployed infrastructure as code.

---

# 🧱 Infrastructure Components

### Application

* Python Flask
* `/` application endpoint
* `/health` health endpoint
* Gunicorn
* Non-root container user

### Container Platform

* Docker
* Amazon ECR
* Amazon ECS
* AWS Fargate
* ECS Task Definition
* ECS Service

### Load Balancing

* Application Load Balancer
* HTTP Listener
* IP Target Group
* ALB Health Checks

### Security & Operations

* Security Groups
* IAM
* AWS Secrets Manager
* Amazon CloudWatch Logs

### CI/CD

* GitHub
* AWS CodeConnections
* AWS CodePipeline
* AWS CodeBuild
* Amazon S3 artifact storage

### Infrastructure as Code

* Terraform
* Terraform variables
* Terraform outputs
* Terraform resource imports
* Terraform state management
* Infrastructure drift validation

---

# 🧰 AWS Services Used

* Amazon ECS
* AWS Fargate
* Amazon ECR
* Application Load Balancer
* Amazon VPC
* Security Groups
* AWS Secrets Manager
* AWS IAM
* Amazon CloudWatch
* AWS CodePipeline
* AWS CodeBuild
* AWS CodeConnections
* Amazon S3

### Infrastructure as Code

* Terraform

---

# 🔐 Security Architecture

The application is publicly accessible through the Application Load Balancer while the container application port is restricted to ALB traffic.

```text
Internet
   │
   │ HTTP :80
   ▼
ALB Security Group
   │
   ▼
Application Load Balancer
   │
   │ TCP :5000
   ▼
ECS Security Group
   │
   ▼
ECS Fargate Task
```

### Security Group Rules

**ALB Security Group**

```text
HTTP :80
Source: 0.0.0.0/0
```

**ECS Security Group**

```text
TCP :5000
Source: ALB Security Group
```

This prevents direct Internet access to the application container port.

The ECS task uses outbound access for communication with required AWS services and external endpoints.

---

# 🔑 Secrets Management

The application uses **AWS Secrets Manager** instead of storing the application token in source code.

Secret:

```text
task-manager/app-token
```

The value is injected into the ECS container as:

```text
TASK_MANAGER_TOKEN
```

The application verifies whether the variable is present through the `/health` endpoint without exposing the secret value.

Example response:

```json
{
  "status": "healthy",
  "secret_loaded": true
}
```

The secret value is not stored in:

* GitHub
* Dockerfile
* Application source code
* ECS task-definition template
* `buildspec.yml`

The ECS task execution role has the required:

```text
secretsmanager:GetSecretValue
```

permission scoped to the specific application secret.

---

# 📊 CloudWatch Logging

CloudWatch Logs is used for ECS container and application logging.

Log Group:

```text
/aws/ecs/task-manager
```

Retention:

```text
7 days
```

The ECS task definition uses the AWS Logs driver and sends container logs to CloudWatch.

---

# 🔄 CI/CD Pipeline

The project includes an automated GitHub-to-ECS deployment pipeline.

```text
GitHub
   │
   ▼
AWS CodeConnections
   │
   ▼
AWS CodePipeline
   │
   ▼
AWS CodeBuild
   │
   ├── Docker build
   ├── Local health test
   ├── ECR image push
   ├── ECS task-definition registration
   └── ECS service update
             │
             ▼
        ECS Fargate
             │
             ▼
        Application ALB
```

## CodePipeline

Pipeline:

```text
task-manager-pipeline
```

Source repository:

```text
jeetzala/aws-ecs-task-manager
```

Branch:

```text
main
```

The GitHub connection is configured through AWS CodeConnections.

## CodeBuild

Build project:

```text
task-manager-build
```

The CodeBuild environment uses Docker privileged mode to build the application image.

The build process:

1. Authenticate to Amazon ECR
2. Build the Docker image
3. Start the image locally inside CodeBuild
4. Test the `/health` endpoint
5. Stop the test container
6. Push the image to Amazon ECR
7. Render the ECS task definition
8. Register a new ECS task-definition revision
9. Update the ECS service
10. Wait for the ECS service to become stable

---

# 🐳 Docker Image Versioning

Images were initially pushed manually during development:

```text
v1.0.0
v1.0.1
```

The automated CodeBuild pipeline creates versioned image tags based on the CodeBuild build number:

```text
v2.0.x
```

The image version is also passed to ECS through:

```text
APP_VERSION
```

Amazon ECR uses a lifecycle policy that keeps the latest three tagged images matching the `v` prefix.

---

# 🚀 ECS Fargate Deployment

The application runs on:

```text
ECS Cluster:
task-manager-cluster-v2

ECS Service:
task-manager-service

Launch Type:
FARGATE

CPU:
256

Memory:
512 MB

Container Port:
5000
```

The service is configured with one desired running task for the portfolio environment.

### Task Definition

The task definition includes:

```text
Container Image
CPU & Memory
Port Mapping
Environment Variables
Secrets Manager Injection
Container Health Check
CloudWatch Logging
```

The active deployment reached:

```text
task-manager:6
```

---

# ❤️ Health Checks

Health is validated at multiple layers:

```text
Docker HEALTHCHECK
        │
        ▼
ECS Container Health
        │
        ▼
ALB Target Group Health Check
        │
        ▼
Flask /health
```

The ALB health check uses:

```text
Protocol: HTTP
Port: 5000
Path: /health
Expected Code: 200
```

The final deployed application returned:

```text
status: healthy
secret_loaded: true
```

---

# 🔁 Rolling Deployment

The ECS service uses rolling deployments.

The deployment process is:

```text
Old ECS Task
     │
     ▼
New Task Starts
     │
     ▼
Container Health Check
     │
     ▼
ALB Target Becomes Healthy
     │
     ▼
Old Target Drains
     │
     ▼
Old Task Stops
```

The service uses an ECS deployment circuit breaker with rollback enabled.

During validation, the new task became healthy while the previous target entered:

```text
draining
```

The new task then became the active running task.

This validated the ECS rolling deployment process.

---

# 📁 Project Structure

```text
aws-ecs-task-manager/
│
├── app.py
├── requirements.txt
├── Dockerfile
├── buildspec.yml
├── task-definition-template.json
├── README.md
├── .dockerignore
├── .gitignore
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── resources.tf
│   ├── outputs.tf
│   └── .terraform.lock.hcl
│
└── screenshots/
    ├── architecture-diagram.png
    ├── alb-created.png
    ├── docker-image-built.png
    ├── ecr-image-pushed.png
    ├── ecr-image-visible.png
    ├── ecr-repository-created.png
    ├── ecs-cluster-created.png
    ├── ecs-cluster-overview.png
    ├── ecs-live-application.png
    ├── ecs-service-running.png
    ├── ecs-task-running.png
    ├── local-container-running.png
    └── task-definition-created.png
```

Terraform state files and the `.terraform` working directory are excluded from the repository.

---

# 📸 Screenshots

## 🌐 1. Application Load Balancer

![Application Load Balancer](screenshots/alb-created.png)

The Application Load Balancer provides the public HTTP entry point for the ECS application.

---

## 🐳 2. Local Container Running

![Local Container Running](screenshots/local-container-running.png)

The Flask application was validated locally inside a Docker container.

---

## 🏗️ 3. Docker Image Built Successfully

![Docker Image Built](screenshots/docker-image-built.png)

The Docker image was built successfully using the project Dockerfile.

---

## 📦 4. ECR Repository Created

![ECR Repository Created](screenshots/ecr-repository-created.png)

The `task-manager` container repository was created in Amazon ECR.

---

## ⬆️ 5. Docker Image Pushed to ECR

![Docker Image Pushed](screenshots/ecr-image-pushed.png)

The Docker image was successfully pushed to Amazon ECR.

---

## 🔎 6. Docker Image Visible in ECR

![ECR Image Visible](screenshots/ecr-image-visible.png)

The application image is available in the ECR repository.

---

## ☁️ 7. ECS Cluster Created

![ECS Cluster Created](screenshots/ecs-cluster-created.png)

The ECS cluster was created for the Fargate application.

---

## 📊 8. ECS Cluster Overview

![ECS Cluster Overview](screenshots/ecs-cluster-overview.png)

The ECS cluster and service configuration can be reviewed from the ECS console.

---

## 📋 9. Task Definition

![Task Definition Created](screenshots/task-definition-created.png)

The task definition configures the container image, CPU, memory, port mapping, health check, logging, and runtime configuration.

---

## 🚀 10. ECS Service Running

![ECS Service Running](screenshots/ecs-service-running.png)

The ECS service maintains the desired running task and is connected to the ALB target group.

---

## 🟢 11. ECS Task Running

![ECS Task Running](screenshots/ecs-task-running.png)

The Fargate task was verified as running and healthy.

---

## 🌍 12. Live Application

![Live Application](screenshots/ecs-live-application.png)

The application is publicly accessible through the Application Load Balancer.

---

# 🧩 Infrastructure as Code with Terraform

The existing AWS infrastructure was imported into **Terraform** rather than recreated.

Terraform configuration is stored in:

```text
terraform/
```

### Terraform Files

```text
main.tf
variables.tf
resources.tf
outputs.tf
.terraform.lock.hcl
```

### Terraform-Managed Resources

Terraform represents:

```text
ECS Cluster
ECS Service
Application Load Balancer
ALB Listener
Target Group
ALB Security Group
ECS Security Group
ECR Repository
ECR Lifecycle Policy
CloudWatch Log Group
Secrets Manager Secret
IAM Secret Access Policy
```

### Terraform and CI/CD Separation

Terraform manages the infrastructure configuration.

GitHub → CodePipeline → CodeBuild manages the changing ECS task-definition revisions generated during application deployments.

The ECS service therefore ignores task-definition changes in Terraform so the CI/CD pipeline can deploy new application revisions without Terraform attempting to replace them.

### Terraform Validation

The infrastructure was validated using:

```bash
terraform fmt
terraform validate
terraform plan
```

Terraform returned:

```text
Success! The configuration is valid.
```

The final infrastructure plan showed no resource actions:

```text
0 to add
0 to change
0 to destroy
```

The plan only showed new Terraform output values that could be saved to state; it did not propose creating, modifying, or destroying AWS infrastructure.

This confirms that the Terraform configuration matches the imported live infrastructure.

---

# 📘 How This Project Works

## ✔️ Step 1 — Create the Flask Application

Created a Python Flask application with:

```text
/
/health
```

The `/health` endpoint reports application health and confirms that the runtime secret has been injected.

---

## ✔️ Step 2 — Containerize the Application

Created a Docker image using a custom Dockerfile.

The container includes:

* Flask
* Gunicorn
* Docker health check
* Non-root application user

The application listens on:

```text
TCP :5000
```

---

## ✔️ Step 3 — Test the Container Locally

The application was tested locally using Docker.

Validation included:

```text
Container running
Application accessible
/health → healthy
Docker health → healthy
```

The secret-aware application was also tested locally using a temporary test environment variable.

---

## ✔️ Step 4 — Push the Image to Amazon ECR

Created the ECR repository:

```text
task-manager
```

Images were pushed using versioned tags.

The repository includes an image lifecycle policy to limit retained tagged images.

---

## ✔️ Step 5 — Create ECS Fargate Infrastructure

Created:

```text
ECS Cluster
ECS Service
Fargate Task Definition
Application Load Balancer
Target Group
HTTP Listener
Security Groups
```

The Fargate task runs with:

```text
256 CPU
512 MB Memory
Port 5000
```

---

## ✔️ Step 6 — Configure Application Health Checks

Configured health checks at:

```text
Docker
ECS
ALB
Application
```

The ALB checks:

```text
/health
```

and expects:

```text
HTTP 200
```

---

## ✔️ Step 7 — Secure Application Secrets

Created:

```text
task-manager/app-token
```

in AWS Secrets Manager.

The secret is injected into the container as:

```text
TASK_MANAGER_TOKEN
```

The secret value remains outside the application source code and GitHub repository.

---

## ✔️ Step 8 — Configure CloudWatch Logging

Created:

```text
/aws/ecs/task-manager
```

with:

```text
7-day retention
```

The ECS container sends application logs to CloudWatch.

---

## ✔️ Step 9 — Build the CI/CD Pipeline

Connected:

```text
GitHub
   ↓
AWS CodeConnections
   ↓
AWS CodePipeline
   ↓
AWS CodeBuild
```

The pipeline automates:

```text
Docker build
Health test
ECR image push
ECS task-definition registration
ECS service update
ECS service stabilization
```

---

## ✔️ Step 10 — Validate Rolling Deployment

The ECS service was successfully updated through the CI/CD pipeline.

The new task became:

```text
RUNNING
HEALTHY
```

The new ALB target became:

```text
healthy
```

The previous target entered:

```text
draining
```

The previous task was then removed after the new deployment became healthy.

---

## ✔️ Step 11 — Manage Infrastructure with Terraform

The existing AWS infrastructure was imported into Terraform.

Terraform was validated using:

```bash
terraform fmt
terraform validate
terraform plan
```

✅ Terraform configuration validated

✅ Existing AWS resources imported

✅ Infrastructure drift checked

✅ No infrastructure resources proposed for creation, modification, or destruction

---

# 🧪 Validation Results

| Component                 | Status     |
| ------------------------- | ---------- |
| Docker Container          | ✅ Verified |
| Docker Health Check       | ✅ Verified |
| Amazon ECR                | ✅ Verified |
| ECS Cluster               | ✅ Verified |
| ECS Fargate Task          | ✅ Verified |
| ECS Container Health      | ✅ Verified |
| Application Load Balancer | ✅ Verified |
| ALB Target Health         | ✅ Verified |
| `/health` Endpoint        | ✅ Verified |
| Secrets Manager           | ✅ Verified |
| IAM Least Privilege       | ✅ Verified |
| CloudWatch Logs           | ✅ Verified |
| AWS CodeConnections       | ✅ Verified |
| AWS CodePipeline          | ✅ Verified |
| AWS CodeBuild             | ✅ Verified |
| Automated ECR Push        | ✅ Verified |
| Automated ECS Deployment  | ✅ Verified |
| ECS Rolling Deployment    | ✅ Verified |
| Terraform Configuration   | ✅ Verified |
| Terraform Infrastructure  | ✅ Verified |
| End-to-End Application    | ✅ Verified |

---

# 💼 What I Learned

* Building and containerizing Python applications
* Writing Dockerfiles for cloud deployment
* Running and validating Docker containers locally
* Using non-root Docker users
* Implementing Docker health checks
* Managing container images with Amazon ECR
* Deploying containers with Amazon ECS Fargate
* Configuring Application Load Balancers
* Configuring ECS target groups and health checks
* Implementing restricted Security Group communication
* Managing application secrets with AWS Secrets Manager
* Applying IAM least-privilege principles
* Sending ECS logs to CloudWatch
* Building GitHub-to-ECS CI/CD pipelines
* Using AWS CodePipeline and CodeBuild
* Automating Docker image builds
* Automating ECR image publishing
* Automating ECS task-definition registration
* Performing ECS rolling deployments
* Troubleshooting CodePipeline and CodeBuild IAM permissions
* Using AWS CLI for infrastructure management
* Importing existing AWS resources into Terraform
* Using Terraform variables and outputs
* Detecting infrastructure drift
* Separating infrastructure management from application deployment
* Documenting AWS infrastructure for a technical portfolio

---

# 🧩 Future Improvements

### High Availability

* Multiple ECS tasks
* ECS Service Auto Scaling
* Multi-AZ task placement
* Load testing

### Security

* HTTPS with ACM
* HTTPS listener on ALB
* Route 53 DNS
* AWS WAF
* Further IAM policy refinement
* Automated secret rotation

### CI/CD

* Automated unit tests
* Integration tests
* Deployment approval stage
* Blue/green deployment
* Automated rollback testing

### Terraform

* Reusable Terraform modules
* Environment-specific configurations
* Remote Terraform state
* Terraform CI validation
* Pull-request Terraform plan checks
* Terraform management of the remaining CI/CD resources

### Observability

* CloudWatch dashboard
* Application-level metrics
* ECS alarms
* ALB error alarms
* Centralized operational dashboards

---

# 🏷️ Project Tags

**AWS • Amazon ECS • AWS Fargate • Amazon ECR • Docker • Flask • Application Load Balancer • CodePipeline • CodeBuild • CodeConnections • Amazon S3 • Secrets Manager • IAM • CloudWatch • Terraform • CI/CD • Containerization • Infrastructure as Code • Cloud Infrastructure • DevOps • AWS Architecture**

---

# 🔗 Connect With Me

GitHub:

https://github.com/jeetzala

LinkedIn:

https://www.linkedin.com/in/jeet-zala-6633832ba/

---

# 🏆 Credits

Built by **Jeet Zala** as part of my AWS Cloud learning journey and cloud infrastructure portfolio.

## Author

**Jeet Zala**

AWS Cloud & DevOps Portfolio Project

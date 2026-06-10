🚀 AWS ECS Fargate Containerized Task Manager

A production-style containerized web application deployed on Amazon ECS Fargate using Docker, Amazon ECR, and an Application Load Balancer (ALB).

This project demonstrates modern cloud-native deployment practices by containerizing a Python Flask application, storing the image in Amazon ECR, and running it serverlessly on ECS Fargate without managing any EC2 servers.

📌 Project Overview

The application was:

Developed using Python Flask
Containerized using Docker
Stored in Amazon Elastic Container Registry (ECR)
Deployed using Amazon ECS Fargate
Exposed publicly through an Application Load Balancer
Monitored using ECS health checks and target groups

This project showcases real-world container orchestration and serverless container deployment on AWS.

🏗️ Architecture Diagram
User
  │
  ▼
Application Load Balancer
  │
  ▼
Amazon ECS Fargate Service
  │
  ▼
Docker Container (Flask App)
  │
  ▼
Amazon ECR Repository
☁️ AWS Services Used
Service	Purpose
Amazon ECS	Container orchestration
AWS Fargate	Serverless container hosting
Amazon ECR	Docker image repository
Application Load Balancer	Traffic distribution
IAM	Permissions management
VPC	Networking
Security Groups	Network security
CloudWatch	Container logs
🐳 Docker Container
Build Image
docker build -t task-manager .
Run Container Locally
docker run -p 5000:5000 task-manager
Access Application
http://localhost:5000
🚀 Deployment Workflow
1️⃣ Create Flask Application

Created a simple Python Flask web application.

2️⃣ Create Docker Image

Containerized the application using Docker.

3️⃣ Push Image to Amazon ECR

Created a private ECR repository and uploaded the Docker image.

4️⃣ Create ECS Cluster

Provisioned an ECS cluster using AWS Fargate.

5️⃣ Create Task Definition

Configured:

Container Image
CPU & Memory
Port Mapping
Network Settings
6️⃣ Deploy ECS Service

Created an ECS Service connected to:

Application Load Balancer
Target Group
Security Groups
7️⃣ Validate Deployment

Verified:

Healthy Targets
Running ECS Tasks
Public Accessibility through ALB
📷 Project Screenshots
Local Container Running

Docker Image Successfully Built

ECR Repository Created

Docker Image Pushed to ECR

Image Available in ECR

ECS Cluster Created

ECS Cluster Overview

Task Definition Created

ECS Service Running

ECS Task Running

Application Load Balancer

Live Application Running on ECS Fargate

🎯 Key Learning Outcomes
Docker Containerization
Amazon ECR Image Management
ECS Task Definitions
ECS Services
AWS Fargate Deployments
Application Load Balancers
Target Groups & Health Checks
Cloud Networking
Security Groups
Container Troubleshooting
📈 Portfolio Skills Demonstrated
Cloud Computing
AWS Architecture
Containerization
DevOps Fundamentals
Infrastructure as Code Concepts
Cloud Networking
Troubleshooting & Monitoring
🧹 AWS Cleanup

To avoid unnecessary AWS charges after testing:

Delete ECS Service
Amazon ECS → Clusters → Services → Delete
Delete ECS Cluster
Amazon ECS → Clusters → Delete
Delete Task Definitions
Amazon ECS → Task Definitions → Deregister
Delete Application Load Balancer
EC2 → Load Balancers → Delete
Delete Target Group
EC2 → Target Groups → Delete
Delete ECR Repository
Amazon ECR → Repository → Delete
👨‍💻 Author

Jeet Zala

AWS Cloud & DevOps Portfolio Project
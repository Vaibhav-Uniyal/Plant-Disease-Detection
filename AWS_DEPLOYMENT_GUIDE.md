# 🚀 AWS Production Deployment Guide

This guide covers deploying your Plant Disease Detection application to AWS using Docker images stored in AWS ECR (Elastic Container Registry).

## 📋 Table of Contents

1. [Overview](#overview)
2. [AWS ECR Setup](#aws-ecr-setup)
3. [CI/CD Integration](#cicd-integration)
4. [Deployment Options](#deployment-options)
5. [Production Best Practices](#production-best-practices)
6. [Cost Optimization](#cost-optimization)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

### Why AWS ECR?

- **Native AWS Integration**: Seamlessly integrates with ECS, EKS, Lambda, App Runner
- **Security**: IAM-based access control, image scanning, encryption at rest
- **Cost-Effective**: Pay only for storage (first 500MB/month free)
- **Performance**: Fast image pulls from same region as your services
- **Compliance**: Supports image scanning for vulnerabilities

### Architecture Options

```
┌─────────────────┐
│  GitHub Actions │
│     (CI/CD)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  AWS ECR        │
│  (Docker Images)│
└────────┬────────┘
         │
    ┌────┴────┬──────────┬──────────┐
    ▼         ▼          ▼          ▼
┌─────┐  ┌─────┐   ┌─────┐   ┌─────────┐
│ ECS │  │ EKS │   │ EC2 │   │ AppRunner│
└─────┘  └─────┘   └─────┘   └─────────┘
```

---

## 🔧 AWS ECR Setup

### Step 1: Create ECR Repository

#### Option A: Using AWS Console

1. Go to **Amazon ECR** in AWS Console
2. Click **Create repository**
3. Repository name: `plant-disease-detector`
4. Visibility: **Private** (recommended for production)
5. Enable **Image scanning** (recommended)
6. Click **Create repository**

#### Option B: Using AWS CLI

```bash
# Install AWS CLI if not installed
# Windows: choco install awscli
# Mac: brew install awscli
# Linux: sudo apt-get install awscli

# Configure AWS credentials
aws configure

# Create ECR repository
aws ecr create-repository \
    --repository-name plant-disease-detector \
    --region us-east-1 \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256

# Get repository URI (save this!)
aws ecr describe-repositories \
    --repository-names plant-disease-detector \
    --region us-east-1 \
    --query 'repositories[0].repositoryUri' \
    --output text
```

#### Option C: Using Provided Script

```bash
# Run the setup script
./scripts/setup_ecr.sh

# Or on Windows PowerShell
.\scripts\setup_ecr.ps1
```

### Step 2: Get Repository URI

Your ECR repository URI will look like:
```
123456789012.dkr.ecr.us-east-1.amazonaws.com/plant-disease-detector
```

**Format**: `{account-id}.dkr.ecr.{region}.amazonaws.com/{repository-name}`

### Step 3: Configure IAM Permissions

#### For CI/CD (GitHub Actions)

Create an IAM user with these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    }
  ]
}
```

Or use the AWS managed policy: `AmazonEC2ContainerRegistryPowerUser`

### Step 4: Add GitHub Secrets

Add these secrets to your GitHub repository:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add the following secrets:
   - `AWS_ACCESS_KEY_ID` (already exists)
   - `AWS_SECRET_ACCESS_KEY` (already exists)
   - `AWS_REGION` (e.g., `us-east-1`)
   - `ECR_REPOSITORY_URI` (your ECR repository URI)

---

## 🔄 CI/CD Integration

The CI/CD pipeline has been updated to push to both Docker Hub and AWS ECR.

### Updated Workflow Features

- ✅ Builds Docker image once
- ✅ Pushes to Docker Hub (existing)
- ✅ Pushes to AWS ECR (new)
- ✅ Tags images with `latest` and commit SHA
- ✅ Uses GitHub Actions cache for faster builds

### Manual Push to ECR

If you want to push manually:

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

# Build image
docker build -t plant-disease-detector .

# Tag image
docker tag plant-disease-detector:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/plant-disease-detector:latest

# Push image
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/plant-disease-detector:latest
```

---

## 🚢 Deployment Options

### Option 1: AWS App Runner (Easiest - Recommended for Start)

**Best for**: Simple deployments, automatic scaling, managed infrastructure

**Pros**:
- ✅ Fully managed
- ✅ Automatic scaling
- ✅ Built-in CI/CD
- ✅ Low maintenance
- ✅ Pay-per-use pricing

**Cons**:
- ❌ Less control over infrastructure
- ❌ Limited customization

**Setup**:
```bash
# Using AWS Console
1. Go to App Runner
2. Create service
3. Source: ECR
4. Select your ECR repository
5. Configure port: 8501
6. Deploy!
```

**Cost**: ~$0.007 per GB-hour + $0.000008 per request

### Option 2: Amazon ECS (Elastic Container Service)

**Best for**: Production workloads, need service orchestration

**Pros**:
- ✅ Fully managed container orchestration
- ✅ Auto-scaling
- ✅ Load balancing
- ✅ Service discovery
- ✅ Task definitions for configuration

**Cons**:
- ❌ More complex setup
- ❌ Requires ALB/NLB for HTTPS

**Quick Setup**:
```bash
# Create ECS cluster
aws ecs create-cluster --cluster-name plant-disease-cluster

# Create task definition (see scripts/ecs_task_definition.json)
aws ecs register-task-definition --cli-input-json file://scripts/ecs_task_definition.json

# Create service
aws ecs create-service \
    --cluster plant-disease-cluster \
    --service-name plant-disease-service \
    --task-definition plant-disease-detector:1 \
    --desired-count 1 \
    --launch-type FARGATE
```

**Cost**: Fargate pricing (~$0.04 per vCPU-hour, ~$0.004 per GB-hour)

### Option 3: Amazon EKS (Kubernetes)

**Best for**: Complex multi-service applications, Kubernetes expertise

**Pros**:
- ✅ Full Kubernetes control
- ✅ Advanced scheduling
- ✅ Multi-cloud compatibility
- ✅ Extensive ecosystem

**Cons**:
- ❌ Complex setup
- ❌ Higher cost
- ❌ Requires Kubernetes knowledge

**Not recommended** for a single Streamlit app unless you have specific Kubernetes requirements.

### Option 4: EC2 with Docker

**Best for**: Full control, custom configurations

**Pros**:
- ✅ Full control
- ✅ Can use existing infrastructure
- ✅ Cost-effective for predictable workloads

**Cons**:
- ❌ Manual management
- ❌ No auto-scaling (without setup)
- ❌ You manage updates/security

**Setup**:
```bash
# Launch EC2 instance (t3.medium recommended)
# Install Docker
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ECR_URI

# Pull and run
docker pull YOUR_ECR_URI:latest
docker run -d -p 8501:8501 --name plant-app YOUR_ECR_URI:latest
```

**Cost**: EC2 instance pricing (t3.medium: ~$0.0416/hour)

### Option 5: AWS Lambda (Serverless)

**Note**: Lambda has limitations for ML models (10GB max, 15min timeout). Not ideal for Streamlit apps, but possible with adaptations.

---

## 🏆 Production Best Practices

### 1. Image Tagging Strategy

```bash
# Use semantic versioning
plant-disease-detector:v1.0.0
plant-disease-detector:v1.0.1

# Use commit SHA for traceability
plant-disease-detector:abc1234

# Use environment tags
plant-disease-detector:production
plant-disease-detector:staging
```

### 2. Security Best Practices

- ✅ Enable **image scanning** in ECR
- ✅ Use **IAM roles** instead of access keys when possible
- ✅ Enable **encryption at rest**
- ✅ Use **VPC endpoints** for private access
- ✅ Implement **least privilege** IAM policies
- ✅ Regularly update base images
- ✅ Scan for vulnerabilities

### 3. Monitoring & Logging

**CloudWatch Integration**:
```bash
# View logs
aws logs tail /ecs/plant-disease-service --follow

# Set up alarms
aws cloudwatch put-metric-alarm \
    --alarm-name high-cpu-plant-app \
    --alarm-description "Alert when CPU > 80%" \
    --metric-name CPUUtilization \
    --namespace AWS/ECS \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold
```

**Application Metrics**:
- Response time
- Error rate
- Request count
- Model inference time
- Resource utilization

### 4. High Availability

- Deploy to **multiple Availability Zones**
- Use **Application Load Balancer** for traffic distribution
- Configure **auto-scaling** (min: 2, max: 10)
- Set up **health checks**

### 5. Cost Optimization

- Use **Fargate Spot** for non-critical workloads (70% savings)
- Right-size containers (don't over-provision)
- Use **Scheduled Scaling** for predictable traffic
- Enable **ECR Lifecycle Policies** to delete old images

### 6. Environment Variables

Store sensitive data in:
- **AWS Secrets Manager** (recommended)
- **AWS Systems Manager Parameter Store**
- **ECS Task Definition secrets** (encrypted)

```json
{
  "secrets": [
    {
      "name": "MODEL_PATH",
      "valueFrom": "arn:aws:secretsmanager:region:account:secret:model-path"
    }
  ]
}
```

---

## 💰 Cost Optimization

### ECR Costs

- **Storage**: $0.10 per GB/month (first 500MB free)
- **Data Transfer**: Free within same region
- **Image Scanning**: Free for first 1M images/month

**Estimated Monthly Cost** (for your use case):
- Storage (111MB image): ~$0.01/month
- Scanning: Free
- **Total ECR**: ~$0.01/month

### Deployment Costs Comparison

| Service | Monthly Cost (1 instance) | Auto-scaling |
|---------|---------------------------|--------------|
| **App Runner** | ~$5-15 | ✅ Yes |
| **ECS Fargate** | ~$30-50 | ✅ Yes |
| **EC2 t3.medium** | ~$30 | ❌ Manual |
| **EKS** | ~$72 (cluster) + compute | ✅ Yes |

**Recommendation**: Start with **App Runner** for simplicity, migrate to **ECS** if you need more control.

### Cost Optimization Tips

1. **Use Fargate Spot** (70% savings) for dev/staging
2. **Right-size containers**: Start with 1 vCPU, 2GB RAM
3. **Enable auto-scaling**: Scale down during low traffic
4. **Use Reserved Instances** (EC2) for predictable workloads
5. **Clean up old images**: Use ECR lifecycle policies

---

## 🔍 Troubleshooting

### Common Issues

#### 1. Authentication Failed

```bash
# Error: "no basic auth credentials"
# Solution: Re-authenticate
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ECR_URI
```

#### 2. Image Push Failed

```bash
# Check IAM permissions
aws iam get-user-policy --user-name github-actions --policy-name ECRPolicy

# Verify repository exists
aws ecr describe-repositories --repository-names plant-disease-detector
```

#### 3. Image Pull Failed in ECS

```bash
# Check task execution role has ECR permissions
# Ensure security groups allow ECR access
# Verify network configuration (VPC, subnets)
```

#### 4. High Latency

- Use **ECR in same region** as compute
- Enable **VPC endpoints** for private access
- Use **image layer caching**

#### 5. Out of Storage

```bash
# List old images
aws ecr list-images --repository-name plant-disease-detector

# Delete old images
aws ecr batch-delete-image --repository-name plant-disease-detector --image-ids imageTag=old-tag
```

---

## 📚 Additional Resources

- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS App Runner Documentation](https://docs.aws.amazon.com/apprunner/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

## ✅ Next Steps

1. ✅ Create ECR repository
2. ✅ Update CI/CD pipeline (already done)
3. ✅ Test image push to ECR
4. ✅ Choose deployment option
5. ✅ Set up monitoring
6. ✅ Configure auto-scaling
7. ✅ Set up custom domain (optional)

---

**Ready to deploy? Start with App Runner for the easiest setup! 🚀**


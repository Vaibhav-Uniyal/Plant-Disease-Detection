#!/bin/bash

# AWS ECR Setup Script
# This script creates an ECR repository for the plant-disease-detector project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
REPOSITORY_NAME="plant-disease-detector"
REGION="${AWS_REGION:-us-east-1}"
ENABLE_SCANNING=true

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first:"
    echo "  Windows: choco install awscli"
    echo "  Mac: brew install awscli"
    echo "  Linux: sudo apt-get install awscli"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Please run 'aws configure'"
    exit 1
fi

print_info "Setting up ECR repository for $REPOSITORY_NAME"

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
print_info "AWS Account ID: $ACCOUNT_ID"
print_info "Region: $REGION"

# Check if repository already exists
if aws ecr describe-repositories --repository-names "$REPOSITORY_NAME" --region "$REGION" &> /dev/null; then
    print_warning "Repository $REPOSITORY_NAME already exists"
    REPO_URI=$(aws ecr describe-repositories \
        --repository-names "$REPOSITORY_NAME" \
        --region "$REGION" \
        --query 'repositories[0].repositoryUri' \
        --output text)
    print_info "Repository URI: $REPO_URI"
else
    # Create repository
    print_info "Creating ECR repository..."
    
    if aws ecr create-repository \
        --repository-name "$REPOSITORY_NAME" \
        --region "$REGION" \
        --image-scanning-configuration scanOnPush=$ENABLE_SCANNING \
        --encryption-configuration encryptionType=AES256 \
        --image-tag-mutability MUTABLE \
        --output json > /dev/null 2>&1; then
        
        print_info "Repository created successfully!"
        
        # Get repository URI
        REPO_URI=$(aws ecr describe-repositories \
            --repository-names "$REPOSITORY_NAME" \
            --region "$REGION" \
            --query 'repositories[0].repositoryUri' \
            --output text)
        
        print_info "Repository URI: $REPO_URI"
    else
        print_error "Failed to create repository"
        echo ""
        print_error "Permission Error: Your IAM user doesn't have permission to create ECR repositories."
        echo ""
        print_warning "SOLUTIONS:"
        echo "  1. Add IAM permissions (see IAM_PERMISSIONS_SETUP.md)"
        echo "  2. Create repository manually in AWS Console"
        echo "  3. Use admin account to create repository"
        echo ""
        print_info "Quick fix: Create repository manually:"
        echo "  - Go to AWS Console → ECR → Create repository"
        echo "  - Name: $REPOSITORY_NAME"
        echo "  - Then get the URI and add to GitHub Secrets"
        echo ""
        print_info "See IAM_PERMISSIONS_SETUP.md for detailed instructions"
        exit 1
    fi
fi

# Set up lifecycle policy to clean up old images
print_info "Setting up lifecycle policy..."
cat > /tmp/lifecycle-policy.json <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF

aws ecr put-lifecycle-policy \
    --repository-name "$REPOSITORY_NAME" \
    --region "$REGION" \
    --lifecycle-policy-text file:///tmp/lifecycle-policy.json

if [ $? -eq 0 ]; then
    print_info "Lifecycle policy configured (keeps last 10 images)"
fi

# Get login command
print_info "To login to ECR, run:"
echo ""
echo "  aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REPO_URI"
echo ""

# Display summary
echo ""
echo "=========================================="
print_info "ECR Setup Complete!"
echo "=========================================="
echo "Repository Name: $REPOSITORY_NAME"
echo "Repository URI:  $REPO_URI"
echo "Region:          $REGION"
echo ""
print_info "Add this to your GitHub Secrets:"
echo "  ECR_REPOSITORY_URI=$REPO_URI"
echo ""
print_info "To push an image manually:"
echo "  docker tag plant-disease-detector:latest $REPO_URI:latest"
echo "  docker push $REPO_URI:latest"
echo ""

# Clean up
rm -f /tmp/lifecycle-policy.json


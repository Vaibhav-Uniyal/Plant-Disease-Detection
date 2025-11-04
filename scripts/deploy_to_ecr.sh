#!/bin/bash

# Manual deployment script to push Docker image to AWS ECR
# Usage: ./scripts/deploy_to_ecr.sh [tag]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default values
TAG="${1:-latest}"
REGION="${AWS_REGION:-us-east-1}"
REPOSITORY_NAME="plant-disease-detector"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    exit 1
fi

# Get ECR repository URI
echo -e "${YELLOW}[INFO]${NC} Getting ECR repository URI..."
REPO_URI=$(aws ecr describe-repositories \
    --repository-names "$REPOSITORY_NAME" \
    --region "$REGION" \
    --query 'repositories[0].repositoryUri' \
    --output text 2>/dev/null)

if [ -z "$REPO_URI" ]; then
    echo "❌ Repository not found. Run ./scripts/setup_ecr.sh first"
    exit 1
fi

echo -e "${GREEN}[INFO]${NC} Repository URI: $REPO_URI"

# Login to ECR
echo -e "${YELLOW}[INFO]${NC} Logging in to ECR..."
aws ecr get-login-password --region "$REGION" | \
    docker login --username AWS --password-stdin "$REPO_URI"

# Build image
echo -e "${YELLOW}[INFO]${NC} Building Docker image..."
docker build -t plant-disease-detector:"$TAG" .

# Tag image
echo -e "${YELLOW}[INFO]${NC} Tagging image..."
docker tag plant-disease-detector:"$TAG" "$REPO_URI:$TAG"

# Push image
echo -e "${YELLOW}[INFO]${NC} Pushing image to ECR..."
docker push "$REPO_URI:$TAG"

echo ""
echo -e "${GREEN}✅ Successfully pushed image to ECR!${NC}"
echo -e "${GREEN}   Image: $REPO_URI:$TAG${NC}"


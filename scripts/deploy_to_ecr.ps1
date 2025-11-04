# Manual deployment script to push Docker image to AWS ECR (PowerShell)
# Usage: .\scripts\deploy_to_ecr.ps1 [tag]

param(
    [string]$Tag = "latest",
    [string]$Region = $env:AWS_REGION,
    [string]$RepositoryName = "plant-disease-detector"
)

# Set default region if not provided
if (-not $Region) {
    $Region = "us-east-1"
}

Write-Host "[INFO] Deploying to ECR with tag: $Tag" -ForegroundColor Yellow

# Check if AWS CLI is installed
try {
    $null = aws --version
} catch {
    Write-Host "[ERROR] AWS CLI is not installed" -ForegroundColor Red
    exit 1
}

# Check if Docker is installed
try {
    $null = docker --version
} catch {
    Write-Host "[ERROR] Docker is not installed" -ForegroundColor Red
    exit 1
}

# Get ECR repository URI
Write-Host "[INFO] Getting ECR repository URI..." -ForegroundColor Yellow
try {
    $RepoUri = (aws ecr describe-repositories `
        --repository-names $RepositoryName `
        --region $Region `
        --query 'repositories[0].repositoryUri' `
        --output text).Trim()
    
    if (-not $RepoUri) {
        Write-Host "[ERROR] Repository not found. Run .\scripts\setup_ecr.ps1 first" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Failed to get repository URI" -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Repository URI: $RepoUri" -ForegroundColor Green

# Login to ECR
Write-Host "[INFO] Logging in to ECR..." -ForegroundColor Yellow
aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $RepoUri

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to login to ECR" -ForegroundColor Red
    exit 1
}

# Build image
Write-Host "[INFO] Building Docker image..." -ForegroundColor Yellow
docker build -t "plant-disease-detector:$Tag" .

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to build image" -ForegroundColor Red
    exit 1
}

# Tag image
Write-Host "[INFO] Tagging image..." -ForegroundColor Yellow
docker tag "plant-disease-detector:$Tag" "$RepoUri`:$Tag"

# Push image
Write-Host "[INFO] Pushing image to ECR..." -ForegroundColor Yellow
docker push "$RepoUri`:$Tag"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[SUCCESS] Successfully pushed image to ECR!" -ForegroundColor Green
    Write-Host "   Image: $RepoUri`:$Tag" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Failed to push image" -ForegroundColor Red
    exit 1
}


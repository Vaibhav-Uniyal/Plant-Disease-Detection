# AWS ECR Setup Script for PowerShell
# This script creates an ECR repository for the plant-disease-detector project

param(
    [string]$RepositoryName = "plant-disease-detector",
    [string]$Region = $env:AWS_REGION,
    [switch]$EnableScanning = $true
)

# Set default region if not provided
if (-not $Region) {
    $Region = "us-east-1"
}

Write-Host "[INFO] Setting up ECR repository for $RepositoryName" -ForegroundColor Green
Write-Host "[INFO] Region: $Region" -ForegroundColor Green

# Check if AWS CLI is installed
try {
    $null = aws --version
} catch {
    Write-Host "[ERROR] AWS CLI is not installed. Please install it first:" -ForegroundColor Red
    Write-Host "  choco install awscli" -ForegroundColor Yellow
    exit 1
}

# Check AWS credentials
try {
    $null = aws sts get-caller-identity 2>&1
} catch {
    Write-Host "[ERROR] AWS credentials not configured. Please run 'aws configure'" -ForegroundColor Red
    exit 1
}

# Get AWS account ID
$AccountId = (aws sts get-caller-identity --query Account --output text).Trim()
Write-Host "[INFO] AWS Account ID: $AccountId" -ForegroundColor Green

# Check if repository already exists
try {
    $null = aws ecr describe-repositories --repository-names $RepositoryName --region $Region 2>&1
    Write-Host "[WARNING] Repository $RepositoryName already exists" -ForegroundColor Yellow
    
    $RepoUri = (aws ecr describe-repositories `
        --repository-names $RepositoryName `
        --region $Region `
        --query 'repositories[0].repositoryUri' `
        --output text).Trim()
    
    Write-Host "[INFO] Repository URI: $RepoUri" -ForegroundColor Green
} catch {
    # Create repository
    Write-Host "[INFO] Creating ECR repository..." -ForegroundColor Green
    
    $scanOnPush = if ($EnableScanning) { "true" } else { "false" }
    
    aws ecr create-repository `
        --repository-name $RepositoryName `
        --region $Region `
        --image-scanning-configuration scanOnPush=$scanOnPush `
        --encryption-configuration encryptionType=AES256 `
        --image-tag-mutability MUTABLE
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[INFO] Repository created successfully!" -ForegroundColor Green
        
        # Get repository URI
        $RepoUri = (aws ecr describe-repositories `
            --repository-names $RepositoryName `
            --region $Region `
            --query 'repositories[0].repositoryUri' `
            --output text).Trim()
        
        Write-Host "[INFO] Repository URI: $RepoUri" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Failed to create repository" -ForegroundColor Red
        exit 1
    }
}

# Set up lifecycle policy
Write-Host "[INFO] Setting up lifecycle policy..." -ForegroundColor Green

$lifecyclePolicy = @"
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
"@

$lifecyclePolicy | Out-File -FilePath "$env:TEMP\lifecycle-policy.json" -Encoding utf8

aws ecr put-lifecycle-policy `
    --repository-name $RepositoryName `
    --region $Region `
    --lifecycle-policy-text "file://$env:TEMP\lifecycle-policy.json"

if ($LASTEXITCODE -eq 0) {
    Write-Host "[INFO] Lifecycle policy configured (keeps last 10 images)" -ForegroundColor Green
}

# Clean up
Remove-Item "$env:TEMP\lifecycle-policy.json" -ErrorAction SilentlyContinue

# Display summary
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "[INFO] ECR Setup Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Repository Name: $RepositoryName"
Write-Host "Repository URI:  $RepoUri"
Write-Host "Region:          $Region"
Write-Host ""
Write-Host "[INFO] Add this to your GitHub Secrets:" -ForegroundColor Green
Write-Host "  ECR_REPOSITORY_URI=$RepoUri" -ForegroundColor Yellow
Write-Host ""
Write-Host "[INFO] To push an image manually:" -ForegroundColor Green
Write-Host "  aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $RepoUri" -ForegroundColor Yellow
Write-Host "  docker tag plant-disease-detector:latest $RepoUri`:latest" -ForegroundColor Yellow
Write-Host "  docker push $RepoUri`:latest" -ForegroundColor Yellow
Write-Host ""


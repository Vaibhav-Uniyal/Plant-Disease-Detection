# 🚀 AWS Deployment - Quick Summary

## ✅ What's Been Set Up

1. **CI/CD Pipeline Updated** - Now pushes to both Docker Hub and AWS ECR
2. **Setup Scripts Created** - Automated ECR repository creation
3. **Deployment Scripts** - Manual push scripts for local testing
4. **Comprehensive Guide** - See `AWS_DEPLOYMENT_GUIDE.md` for full details

## ⚠️ Important: IAM Permissions

**Before running the setup script**, ensure your IAM user has ECR permissions. If you get an `AccessDeniedException`, see **`IAM_PERMISSIONS_SETUP.md`** for detailed instructions.

**Quick fix options:**
1. **Add permissions** (recommended): Attach `AmazonEC2ContainerRegistryFullAccess` policy to your IAM user
2. **Create manually**: Use AWS Console to create the repository (one-time setup)
3. **Use admin account**: Create repository with an account that has admin permissions

## 🎯 Quick Start (3 Steps)

### Step 1: Create ECR Repository

```bash
# Windows PowerShell (run from PowerShell, not WSL)
.\scripts\setup_ecr.ps1

# Linux/Mac/WSL (if you're in WSL, use this!)
bash scripts/setup_ecr.sh
# OR make it executable first:
chmod +x scripts/setup_ecr.sh
./scripts/setup_ecr.sh
```

This will:
- Create ECR repository `plant-disease-detector`
- Enable image scanning
- Set up lifecycle policies
- Display your repository URI

### Step 2: Add GitHub Secret

1. Go to GitHub → Settings → Secrets and variables → Actions
2. Add new secret:
   - Name: `ECR_REPOSITORY_URI`
   - Value: Your ECR URI (from Step 1)
   - Example: `123456789012.dkr.ecr.us-east-1.amazonaws.com/plant-disease-detector`

### Step 3: Push to Main Branch

```bash
git add .
git commit -m "Add AWS ECR deployment support"
git push origin main
```

The CI/CD pipeline will automatically:
- ✅ Build Docker image
- ✅ Push to Docker Hub (existing)
- ✅ Push to AWS ECR (new!)

## 📦 Deployment Options

### Option 1: AWS App Runner (Easiest) ⭐ Recommended

**Time**: 5 minutes
**Cost**: ~$5-15/month

1. Go to AWS Console → App Runner
2. Create service → Container registry → ECR
3. Select your repository
4. Port: 8501
5. Deploy!

### Option 2: Amazon ECS

**Time**: 15 minutes
**Cost**: ~$30-50/month

See `AWS_DEPLOYMENT_GUIDE.md` for detailed steps.

### Option 3: EC2

**Time**: 10 minutes
**Cost**: ~$30/month

```bash
# On EC2 instance
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ECR_URI
docker pull YOUR_ECR_URI:latest
docker run -d -p 8501:8501 --name plant-app YOUR_ECR_URI:latest
```

## 🔧 Manual Testing

Test pushing to ECR manually:

```bash
# Windows
.\scripts\deploy_to_ecr.ps1

# Linux/Mac
./scripts/deploy_to_ecr.sh
```

## 📋 Required IAM Permissions

Your AWS user needs these permissions:
- `ecr:GetAuthorizationToken`
- `ecr:BatchCheckLayerAvailability`
- `ecr:GetDownloadUrlForLayer`
- `ecr:BatchGetImage`
- `ecr:PutImage`
- `ecr:InitiateLayerUpload`
- `ecr:UploadLayerPart`
- `ecr:CompleteLayerUpload`

Or use the managed policy: `AmazonEC2ContainerRegistryPowerUser`

## 📚 Next Steps

1. ✅ Create ECR repository (Step 1 above)
2. ✅ Add GitHub secret (Step 2 above)
3. ✅ Test CI/CD pipeline (Step 3 above)
4. ✅ Choose deployment option (App Runner recommended)
5. ✅ Set up monitoring (CloudWatch)
6. ✅ Configure custom domain (optional)

## 📖 Full Documentation

See `AWS_DEPLOYMENT_GUIDE.md` for:
- Detailed setup instructions
- All deployment options
- Production best practices
- Cost optimization tips
- Troubleshooting guide

---

**Need help?** Check the troubleshooting section in `AWS_DEPLOYMENT_GUIDE.md`


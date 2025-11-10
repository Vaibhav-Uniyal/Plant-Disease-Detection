# 🔐 IAM Permissions Setup for AWS ECR

Your IAM user `mlops-ci-user` needs additional permissions to create and manage ECR repositories.

## 🎯 Quick Fix Options

### Option 1: Add IAM Policy (Recommended)

Attach the ECR permissions policy to your IAM user:

#### Using AWS Console:

1. Go to **IAM Console** → **Users** → `mlops-ci-user`
2. Click **Add permissions** → **Attach policies directly**
3. Search for **"AmazonEC2ContainerRegistryFullAccess"**
4. Check the box and click **Next** → **Add permissions**

**OR** attach a custom policy:

1. Go to **IAM Console** → **Users** → `mlops-ci-user`
2. Click **Add permissions** → **Create inline policy**
3. Click **JSON** tab
4. Copy the contents from `scripts/iam_policy_ecr.json`
5. Paste it and click **Next**
6. Name it: `ECRFullAccess`
7. Click **Create policy**

#### Using AWS CLI:

```bash
# Attach the managed policy (easiest)
aws iam attach-user-policy \
    --user-name mlops-ci-user \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess

# OR attach custom policy (from scripts/iam_policy_ecr.json)
# First create the policy:
aws iam put-user-policy \
    --user-name mlops-ci-user \
    --policy-name ECRFullAccess \
    --policy-document file://scripts/iam_policy_ecr.json
```

### Option 2: Create Repository Manually (Quick Workaround)

If you can't modify IAM permissions, create the repository manually:

#### Using AWS Console:

1. Go to **Amazon ECR** in AWS Console
2. Click **Create repository**
3. Repository name: `plant-disease-detector`
4. Visibility: **Private**
5. Enable **Image scanning**: ✅
6. Click **Create repository**
7. Copy the repository URI (you'll need it for GitHub secrets)

#### Using AWS CLI (with admin account):

```bash
# Login with an account that has admin permissions
aws ecr create-repository \
    --repository-name plant-disease-detector \
    --region us-east-1 \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256

# Get the repository URI
aws ecr describe-repositories \
    --repository-names plant-disease-detector \
    --region us-east-1 \
    --query 'repositories[0].repositoryUri' \
    --output text
```

### Option 3: Use Admin Account for Setup

If you have admin access:

1. Create the repository using admin account (Option 2 above)
2. Your `mlops-ci-user` already has permissions to **push/pull** images (that's what CI/CD needs)
3. The user just needs **CreateRepository** permission for the setup script

## 📋 Required Permissions Breakdown

### For CI/CD Pipeline (Push/Pull Images):
- ✅ `ecr:GetAuthorizationToken`
- ✅ `ecr:BatchCheckLayerAvailability`
- ✅ `ecr:GetDownloadUrlForLayer`
- ✅ `ecr:BatchGetImage`
- ✅ `ecr:PutImage`
- ✅ `ecr:InitiateLayerUpload`
- ✅ `ecr:UploadLayerPart`
- ✅ `ecr:CompleteLayerUpload`

**Your user likely already has these!** ✅

### For Setup Script (Create Repository):
- ❌ `ecr:CreateRepository` ← **You're missing this**
- ❌ `ecr:PutLifecyclePolicy`
- ❌ `ecr:DescribeRepositories`

## 🚀 After Fixing Permissions

Once you've added the permissions:

1. **Wait 1-2 minutes** for permissions to propagate
2. Run the setup script again:
   ```bash
   bash scripts/setup_ecr.sh
   ```
3. If you created the repository manually, you can skip the script and just add the URI to GitHub secrets

## ✅ Verify Permissions

Check if your user has the right permissions:

```bash
# Test if you can list repositories
aws ecr describe-repositories --region us-east-1

# Test if you can create (this will fail if no permission)
aws ecr create-repository \
    --repository-name test-repo \
    --region us-east-1

# If test succeeds, delete the test repo
aws ecr delete-repository \
    --repository-name test-repo \
    --region us-east-1 \
    --force
```

## 🎯 Recommended Approach

**For Production:**
1. Create the repository manually (one-time setup)
2. Your CI/CD user only needs push/pull permissions (more secure)
3. Use the setup script for future repositories or if you have admin access

**For Development:**
1. Add full ECR permissions to your user (easier for testing)

## 📝 Next Steps

After fixing permissions:

1. ✅ Create ECR repository (manually or via script)
2. ✅ Get repository URI
3. ✅ Add `ECR_REPOSITORY_URI` to GitHub Secrets
4. ✅ Test CI/CD pipeline

---

**Need help?** The setup script will work once you have `ecr:CreateRepository` permission, or you can create the repository manually and skip the script entirely!


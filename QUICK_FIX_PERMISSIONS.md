# ⚡ Quick Fix: IAM Permissions Error

## 🚨 Your Error
```
AccessDeniedException: User is not authorized to perform: ecr:CreateRepository
```

## ✅ Solution 1: Add IAM Policy (Easiest)

### Option A: Using AWS Console (Recommended)

1. Go to: https://console.aws.amazon.com/iam/
2. Click **Users** → Find `mlops-ci-user`
3. Click on the user name
4. Click **Add permissions** → **Attach policies directly**
5. Search for: **`AmazonEC2ContainerRegistryFullAccess`**
6. ✅ Check the box
7. Click **Next** → **Add permissions**

**Done!** Wait 1-2 minutes, then run the setup script again.

### Option B: Using AWS CLI

```bash
# Attach the managed policy
aws iam attach-user-policy \
    --user-name mlops-ci-user \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
```

## ✅ Solution 2: Create Repository Manually (Quick Workaround)

If you can't modify IAM permissions, create the repository manually:

1. Go to: https://console.aws.amazon.com/ecr/
2. Click **Create repository**
3. Repository name: `plant-disease-detector`
4. Visibility: **Private**
5. Enable **Image scanning**: ✅
6. Click **Create repository**
7. Copy the repository URI (looks like: `058264388492.dkr.ecr.us-east-1.amazonaws.com/plant-disease-detector`)

**Then:**
- Add this URI to GitHub Secrets as `ECR_REPOSITORY_URI`
- Skip the setup script - you're done!

## ✅ Solution 3: Use Admin Account

If you have access to an admin account:

```bash
# Login with admin account
aws configure

# Create repository
aws ecr create-repository \
    --repository-name plant-disease-detector \
    --region us-east-1 \
    --image-scanning-configuration scanOnPush=true

# Get URI
aws ecr describe-repositories \
    --repository-names plant-disease-detector \
    --region us-east-1 \
    --query 'repositories[0].repositoryUri' \
    --output text
```

Then add the URI to GitHub Secrets.

## 🎯 Recommended Approach

**For Production:**
- ✅ Create repository manually (one-time, more secure)
- Your CI/CD user only needs push/pull (already has it)

**For Development:**
- ✅ Add full ECR permissions (easier for testing)

## 📝 After Fixing

1. **If you added permissions**: Wait 1-2 min, then run:
   ```bash
   bash scripts/setup_ecr.sh
   ```

2. **If you created manually**: 
   - Get the repository URI from AWS Console
   - Add to GitHub Secrets as `ECR_REPOSITORY_URI`
   - Skip the setup script

3. **Continue with Step 2** in DEPLOYMENT_SUMMARY.md

---

**Need more details?** See `IAM_PERMISSIONS_SETUP.md` for comprehensive instructions.


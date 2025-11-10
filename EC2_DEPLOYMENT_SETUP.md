# 🚀 EC2 Deployment Setup for CI/CD

This guide explains how to set up automated EC2 deployment as part of your CI/CD pipeline.

## 📋 What the CI/CD Pipeline Does

After building and pushing your Docker image to ECR, the pipeline will:
1. ✅ SSH into your EC2 instance
2. ✅ Install Docker and AWS CLI (if needed)
3. ✅ Login to ECR
4. ✅ Stop old container (if exists)
5. ✅ Pull latest image from ECR
6. ✅ Run new container
7. ✅ Verify deployment

## 🔧 Required GitHub Secrets

Add these secrets to your GitHub repository:

### Step 1: Go to GitHub Secrets
1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

### Step 2: Add These Secrets

#### 1. `EC2_HOST`
- **Value**: Your EC2 instance's public IP or public DNS
- **Example**: `54.123.45.67` or `ec2-54-123-45-67.compute-1.amazonaws.com`

#### 2. `EC2_USER`
- **Value**: Your EC2 instance username
- **For Amazon Linux**: `ec2-user`
- **For Ubuntu**: `ubuntu`
- **For CentOS/RHEL**: `ec2-user` or `centos`

#### 3. `EC2_SSH_KEY`
- **Value**: Contents of your EC2 private key file (`.pem` file)
- **How to get it**:
  ```bash
  # On your local machine, read the key file
  cat your-key-file.pem
  # Copy the entire output (including -----BEGIN and -----END lines)
  ```

**Important**: Copy the entire key file content, including:
```
-----BEGIN RSA PRIVATE KEY-----
...key content...
-----END RSA PRIVATE KEY-----
```

### Existing Secrets (Already Set)
- `AWS_ACCESS_KEY_ID` ✅
- `AWS_SECRET_ACCESS_KEY` ✅
- `AWS_REGION` ✅
- `ECR_REPOSITORY_URI` ✅

## 🖥️ EC2 Instance Setup

### Step 1: Launch EC2 Instance

1. Go to AWS Console → EC2 → Launch Instance
2. Configure:
   - **AMI**: Amazon Linux 2023 or Ubuntu 22.04
   - **Instance Type**: `t3.medium` or `t3.large` (recommended)
   - **Key Pair**: Create or select existing
   - **Security Group**: 
     - Allow SSH (port 22) from your IP or `0.0.0.0/0`
     - Allow HTTP (port 8501) from `0.0.0.0/0` (or your IP)
   - **Launch**

### Step 2: Configure EC2 Instance

#### Option A: Use IAM Role (Recommended - More Secure)

1. Create IAM Role with these policies:
   - `AmazonEC2ContainerRegistryReadOnly` (to pull from ECR)
   - Or attach the same policy as your CI/CD user

2. Attach role to EC2:
   - EC2 Console → Your Instance → Actions → Security → Modify IAM role
   - Select the role you created

**Benefits**: No need to store AWS credentials on EC2!

#### Option B: Configure AWS Credentials on EC2

```bash
# SSH into EC2
ssh -i your-key.pem ec2-user@<EC2_IP>

# Configure AWS credentials
aws configure
# Enter your AWS Access Key ID and Secret Access Key
```

### Step 3: Initial Docker Setup (One-Time)

The CI/CD pipeline will install Docker automatically, but you can also do it manually:

```bash
# For Amazon Linux
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Log out and log back in for group changes
exit
```

## 🔐 Security Best Practices

### 1. Use IAM Role Instead of Credentials
- More secure
- No credentials to manage
- Automatically rotates

### 2. Restrict SSH Access
- Only allow SSH from your IP in security group
- Use key-based authentication (already done)

### 3. Restrict Port 8501
- Only allow from specific IPs if possible
- Or use `0.0.0.0/0` for public access

### 4. Use Security Groups
- Create dedicated security group for your app
- Only open necessary ports

## ✅ Testing the Deployment

### Manual Test

Test the deployment manually first:

```bash
# On your local machine
ssh -i your-key.pem ec2-user@<EC2_IP>

# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin 058264388492.dkr.ecr.us-east-1.amazonaws.com

# Pull and run
docker pull 058264388492.dkr.ecr.us-east-1.amazonaws.com/plant-disease-detector:latest
docker run -d --name plant-disease-app -p 8501:8501 \
  058264388492.dkr.ecr.us-east-1.amazonaws.com/plant-disease-detector:latest
```

### Test CI/CD Pipeline

1. Push to `main` branch
2. Go to GitHub → Actions tab
3. Watch the workflow run
4. Check the "Deploy to EC2" job logs
5. Access your app at `http://<EC2_IP>:8501`

## 🐛 Troubleshooting

### Issue: SSH Connection Failed
- **Check**: EC2 security group allows SSH from GitHub Actions IPs
- **Check**: Key file content is correctly copied to GitHub secret
- **Check**: EC2_HOST is correct (IP or DNS)

### Issue: Docker Permission Denied
- **Fix**: Add user to docker group: `sudo usermod -a -G docker $USER`
- **Fix**: Log out and log back in

### Issue: ECR Login Failed
- **Check**: AWS credentials are configured on EC2 (or IAM role attached)
- **Check**: IAM permissions allow ECR access

### Issue: Container Won't Start
- **Check logs**: `docker logs plant-disease-app`
- **Check**: Port 8501 is not already in use
- **Check**: Security group allows port 8501

### Issue: Deployment Skipped
- **Check**: You're pushing to `main` branch
- **Check**: All required secrets are set
- **Check**: Previous job (build-and-deploy) succeeded

## 📊 Monitoring

### View Container Logs
```bash
# SSH into EC2
docker logs plant-disease-app

# Follow logs
docker logs -f plant-disease-app
```

### Check Container Status
```bash
docker ps
docker ps -a  # Show all containers including stopped
```

### Restart Container
```bash
docker restart plant-disease-app
```

## 🔄 Workflow Behavior

The deployment job will:
- ✅ Only run on `main` branch pushes
- ✅ Only run if ECR_REPOSITORY_URI is set
- ✅ Only run if EC2_HOST is set
- ✅ Wait for build-and-deploy job to complete
- ✅ Automatically stop old container before starting new one
- ✅ Set container to auto-restart on EC2 reboot

## 🎯 Next Steps

1. ✅ Launch EC2 instance
2. ✅ Configure security groups
3. ✅ Set up IAM role (recommended) or AWS credentials
4. ✅ Add GitHub secrets (EC2_HOST, EC2_USER, EC2_SSH_KEY)
5. ✅ Push to main branch
6. ✅ Watch deployment happen automatically!

---

**Your app will be automatically deployed to EC2 on every push to main! 🚀**


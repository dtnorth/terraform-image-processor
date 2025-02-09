# 📸 AWS Image Management Platform

This demo project is a **full-stack image management platform** deployed on AWS. It allows users to **upload, manage, share, and access images globally** using **CloudFront CDN**. The entire infrastructure is automated with **Terraform**, while **GitHub Actions** ensures continuous deployment. The architecture is optimized for **cost-effectiveness**, utilizing AWS's free-tier offerings and minimizing unnecessary expenses.

---

## 🚀 Features
- **Frontend:** Next.js hosted on AWS S3 & served via CloudFront CDN for low-cost, high-speed delivery  
- **Backend:** AWS Lambda (Node.js/Express) behind an API Gateway with pay-as-you-go pricing  
- **Storage:** AWS S3 for storing original and resized images with lifecycle policies to delete unused files  
- **Database:** AWS DynamoDB with on-demand mode to minimize costs for metadata storage  
- **Auto-Scaling:** Leverages AWS **Lambda's serverless scaling** to handle traffic spikes automatically  
- **Sharing:** Users can generate **public shareable links** for images without increasing infrastructure costs  
- **Link Shortening:** Shortened URLs for shared images using AWS DynamoDB and API Gateway  
- **CI/CD:** GitHub Actions for automated deployments without additional infrastructure expenses  
- **Security:** IAM roles for access control & API Gateway securing API requests efficiently  
- **Monitoring:** AWS CloudWatch for logs & performance tracking with basic monitoring to reduce logging costs  
- **Pull Request Authorization:** All Git pushes require approval via pull requests before merging to the main branch  
- **Terraform Security Scanning:** Uses **tfsec** for static analysis security scanning of Terraform code in GitHub Actions  
- **Cost Estimation:** Uses **Infracost** to estimate and track AWS infrastructure costs in GitHub Actions  
- **CloudFront Cache Invalidation:** AWS Lambda function to automatically clear the CloudFront cache for changed files only  

---

## 📂 Project Structure
```plaintext
📦 image-management-platform
 ┣ 📂 backend        # AWS Lambda function (Express API)
 ┃ ┣ 📜 server.js    # Handles image uploads, metadata, listing, sharing, and link shortening
 ┣ 📂 frontend       # Next.js (Fancy UI)
 ┃ ┣ 📂 pages
 ┃ ┣ 📂 components
 ┣ 📂 terraform      # AWS Infrastructure (S3, Lambda, CloudFront, API Gateway, DynamoDB)
 ┃ ┣ 📜 backend.tf
 ┃ ┣ 📜 frontend.tf
 ┃ ┣ 📜 cloudfront.tf
 ┃ ┣ 📜 lambda.tf
 ┃ ┣ 📜 iam.tf
 ┃ ┣ 📜 outputs.tf
 ┃ ┣ 📜 variables.tf
 ┃ ┗ 📜 providers.tf
 ┣ 📂 .github
 ┃ ┗ 📂 workflows   # CI/CD automation with GitHub Actions
 ┃   ┗ 📜 deploy.yml
 ┗ 📜 README.md
```

---

## 🏗️ Infrastructure Overview

### **Frontend (Next.js + S3 + CloudFront)**
- The Next.js application is **statically exported** and stored in **S3**.
- CloudFront serves the site globally with **HTTPS & caching**, reducing bandwidth costs.
- **S3 Lifecycle policies** ensure old, unused assets are deleted automatically.
- **Lambda Function clears only changed files from the CloudFront cache**, reducing unnecessary cache invalidations.

### **Backend (Lambda + API Gateway + S3 + DynamoDB)**
- API Gateway processes **image upload requests**, using caching to reduce request costs.
- AWS Lambda functions handle image uploads, sharing, metadata storage, and **link shortening** in **DynamoDB**.
- S3 stores **both original and resized images**, with an **auto-delete policy** to manage storage costs.
- **DynamoDB is set to on-demand mode**, reducing costs by avoiding unnecessary provisioned throughput.
- **Lambda scales automatically** to accommodate sudden spikes in image uploads without manual intervention.

### **CI/CD (GitHub Actions + Terraform + tfsec + Infracost + CloudFront Cache Invalidation)**
- GitHub Actions automates **Terraform infrastructure deployment** without running persistent infrastructure.
- Any new code push triggers **automatic backend & frontend deployment**, reducing manual effort and costs.
- **Pull request authorization is enforced**, ensuring all changes undergo review before merging into production.
- **tfsec is integrated** into GitHub Actions to scan Terraform code for security vulnerabilities before deployment.
- **Infracost is integrated** to provide cost estimation before deploying Terraform changes.
- **AWS Lambda function detects changed files and invalidates only those files in CloudFront**, preventing full cache invalidation.

---

## 🔧 Deployment Steps

### **1️⃣ Set Up AWS Credentials in GitHub Actions**
- Go to **GitHub > Settings > Secrets** and add:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

### **2️⃣ Deploy Infrastructure with Terraform**
```sh
cd terraform
tfsec .  # Run tfsec security checks
infracost breakdown --path .  # Run cost estimation
terraform init
terraform apply -auto-approve
```

### **3️⃣ Submit a Pull Request for Code Changes**
- Push your changes to a **feature branch**:
```sh
git add .
git commit -m "🚀 New feature implementation"
git push origin feature-branch
```
- Open a pull request in GitHub and request a review before merging.

### **4️⃣ Merge Approved Pull Request & Deploy**
Once the pull request is approved and merged to `main`, GitHub Actions will **automatically deploy** the backend & frontend:
```sh
git push origin main
```
- After deployment, the **AWS Lambda function will detect changed files and clear only those files from CloudFront cache**.

### **5️⃣ Access Your Deployed App**
Run:
```sh
terraform output
```
Then open:
```plaintext
Frontend: https://your-cloudfront-id.cloudfront.net
Backend API: https://your-api-id.execute-api.eu-north-1.amazonaws.com/prod
```

---

## 🔥 Cost Optimization Strategies
- ✅ **Use AWS Free Tier** for S3, Lambda, API Gateway, and DynamoDB where possible.
- ✅ **Enable S3 Lifecycle Policies** to automatically delete unused images.
- ✅ **Use On-Demand DynamoDB** to minimize unnecessary storage costs.
- ✅ **Use CloudFront caching** to reduce S3 bandwidth usage.
- ✅ **Monitor Lambda usage with CloudWatch** and optimize execution time to stay within free-tier limits.
- ✅ **Leverage AWS Lambda Auto-Scaling** to handle predictable upload traffic spikes efficiently.
- ✅ **Utilize short links** to reduce unnecessary API calls and storage costs.
- ✅ **Enforce pull request authorization** to prevent unintended deployments and maintain high code quality.
- ✅ **Integrate tfsec** for Terraform security scanning to detect misconfigurations before deployment.
- ✅ **Use Infracost** to estimate and monitor AWS infrastructure costs before applying Terraform changes.
- ✅ **Optimize CloudFront cache invalidation** by clearing only changed files using AWS Lambda.

---



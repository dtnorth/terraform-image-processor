# 📸 AWS Image Management Platform

This demo project is a **full-stack image management platform** deployed on AWS. 

It allows users to **upload, manage, change image resolution, share and access images globally** utilising **CloudFront CDN**. 

The entire infrastructure is automated with **Terraform**, while **GitHub Actions** ensures continuous deployment upon successful
workflow consideration of the **github actions** pull request review, ##tfsec static analysis## to defined guidelines and ##Infracost infrastructure AWS costing steps.

For simplicity and cost reduction no VPC, EC2, ECS OR EKS or traditional cloud structures are required.

The architecture is optimized for **cost-effectiveness**, utilizing AWS's free-tier offerings and minimizing unnecessary expense.

---

## 🚀 Features

- **Frontend:** Next.js hosted on AWS S3 & served via CloudFront CDN for low-cost, high-speed delivery  
- **Backend:** AWS Lambda (Node.js/Express) behind an API Gateway with pay-as-you-go pricing  
- **Storage:** AWS S3 for storing original and resized images with lifecycle policies to delete unused files  
- **Database:** AWS DynamoDB with on-demand mode to minimize costs for metadata storage  
- **Auto-Scaling:** Leverages AWS **Lambda's serverless scaling** to handle traffic spikes automatically.  
- **Sharing:** Users can generate **public shareable links** for images without increasing infrastructure costs  
- **Link Shortening:** Shortened URLs for shared images using AWS DynamoDB and API Gateway  
- **CI/CD:** GitHub Actions for automated deployments without additional infrastructure expenses  
- **Security:** IAM roles for access control & API Gateway securing API requests efficiently  
- **Monitoring:** AWS CloudWatch for logs & performance tracking with basic monitoring to reduce logging costs  
- **Pull Request Authorization:** All Git pushes require approval via pull requests before merging to the main branch  
- **Terraform Security Scanning:** Uses **tfsec** for static analysis security scanning of Terraform code in GitHub Actions, failure causing the workflow to fail.  
- **Cost Estimation:** Uses **Infracost** to estimate and track AWS infrastructure costs in GitHub Actions  
- **CloudFront Cache Invalidation:** AWS Lambda function to automatically clear the CloudFront cache for changed files only
- **Terraform State Storage**: Terraform state is stored in an AWS S3 bucket with DynamoDB state locking to prevent conflicts

---

## 📂 Project Structure
```plaintext
📦 image-management-platform
 ┣ 📂 backend              # AWS Lambda function (Express API)
 ┃ ┣ 📜 server.js          # Handle API requests
 ┃ ┣ 📜 imageProcessor.js  # Handles image resizing
 ┃ ┣ 📜 urlShortener.js    # Handles URL shortening
 ┃ ┣ 📜 package.json       # Configure React and Node dependencies.  
 ┃ ┣ 📜 lambda.zip         # Deployable AWS Lambda
 ┣ 📂 frontend             # Next.js UI
 ┃ ┣ 📂 pages              
 ┃ ┣ 📜 package.json       # Configure React and Node dependencies. 
 ┃ ┣ 📜 index.js           # API Endpoints
 ┣ 📂 terraform            # AWS Infrastructure (S3, Lambda, CloudFront, API Gateway, DynamoDB)
 ┃ ┣ 📜 backend.tf
 ┃ ┣ 📜 frontend.tf
 ┃ ┣ 📜 cloudfront.tf
 ┃ ┣ 📜 lambda.tf
 ┃ ┣ 📜 iam.tf
 ┃ ┣ 📜 outputs.tf
 ┃ ┣ 📜 variables.tf
 ┃ ┣ 📜 providers.tf       # Fefine AWS Terraform providers
 ┃ ┣ 📜 backend-config.tf  # Save Terraform State to S3 
 ┣ 📂 .github              # CI/CD GitHub Actions
 ┃ ┣ 📜 deploy.yml
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

### GitHub Actions Workflow Steps:
```plaintext
name: CI/CD Pipeline for AWS Image Management Platform

on:
  push:
    branches:
      - main

jobs:
  security_scan:
    name: Run tfsec Security Scan
    runs-on: self-hosted
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
      - name: Run tfsec
        uses: aquasecurity/tfsec-action@v1
        with:
          working_directory: terraform/

  cost_estimation:
    name: Run Infracost Cost Estimation
    runs-on: self-hosted
    needs: security_scan
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
      - name: Setup Infracost
        uses: infracost/actions/setup@v2
      - name: Run Infracost
        run: |
          infracost breakdown --path terraform/ --format json --out-file infracost.json
          cat infracost.json

  deploy_infrastructure:
    name: Deploy Infrastructure with Terraform
    runs-on: self-hosted
    needs: cost_estimation
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Terraform Init & Apply
        run: |
          cd terraform
          terraform init
          terraform apply -auto-approve

  deploy_application:
    name: Deploy Backend & Frontend
    runs-on: self-hosted
    needs: deploy_infrastructure
    steps:
      - name: Deploy Backend (Lambda, API Gateway)
        run: echo "Deploying backend..."
      - name: Deploy Frontend (S3, CloudFront)
        run: echo "Deploying frontend..."

  cloudfront_invalidation:
    name: Invalidate CloudFront Cache for Changed Files
    runs-on: self-hosted
    needs: deploy_application
    steps:
      - name: Detect Changed Files
        id: changed_files
        run: |
          CHANGED_FILES=$(git diff --name-only HEAD^ HEAD | grep frontend/out/ || echo "")
          echo "Changed files: $CHANGED_FILES"
          echo "::set-output name=files::$CHANGED_FILES"
      - name: Invalidate CloudFront Cache
        if: steps.changed_files.outputs.files != ''
        run: |
          DISTRIBUTION_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[0].Id" --output text)
          aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths ${{ steps.changed_files.outputs.files }}
```
---

## 🔧 Deployment Steps

### **1️⃣ Set Up AWS Credentials in GitHub Actions**
- Go to **GitHub > Settings > Secrets** and add:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

### **3️⃣ Submit a Pull Request for Code Changes**
- Push your changes to a **feature branch**:
```sh
git add .
git commit -m "🚀 New feature implementation"
git push origin <feature-branch>
```
- Open a pull request in GitHub and request a peer review before merging.

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
Frontend: https://<cloudfront-id>.cloudfront.net
Backend API: https://<api-id>.execute-api.eu-north-1.amazonaws.com/prod
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

## 🔥 Cost Breakdown (Pay-As-You-Go Pricing)
Service	Cost Model
- AWS Lambda	Pay per execution + memory usage
- API Gateway	Pay per API request
- S3 Storage	Pay per GB stored
- DynamoDB	Pay per read/write request
- CloudFront	Pay per data transfer
  
## 🔥 Estimated Costs
Usage	Estimated Monthly Cost
- 10,000 API Requests	~$1.00
- 1 GB S3 Storage	~$0.023
- 100,000 Lambda Executions	~$0.20
- DynamoDB (1GB Data)	~$0.25
- Total estimated cost: ~$1.50 to $5.00 per month, depending on usage!

---



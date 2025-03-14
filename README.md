# AWS Image Management Platform

This demo project is a **full-stack image management platform** deployable on AWS in support of my application.

It allows users to **upload, manage, change image resolution, share and access images** whilst allowing for security, cost management, minimal app footprint and handles spikes in the apps usage utilising:

- **CloudFront CDN** UI presentation optimised for both Computer and Mobile users.
  
- **AWS S3 Storage** All Image and Terraform state / Terraform lock file storage
  
- **AWS API Gateway** Routes User Requests to AWS Lambda and Provides a Public HTTP API, Secures API Requests and caches responses
  to reduce unnecessary Lambda executions whilst supporting rate limiting to prevent API abuse

- **AWS DynamoDB** Image metadata and Terraform State
  
- **AWS Lambda**
  
```plaintext
- User uploads an image via an API call (POST / UI upload).
- API Gateway routes request to image_upload_lambda.
- image_upload_lambda: Saves the original image in S3.
- Calls image_resize_lambda to create multiple sizes to user resolution specification.
- Calls url_shortener_lambda to generate a short link.
- User retrieves the image using a shortened URL (GET /short/{id}) via UI.
- CloudFront serves the images globally for fast performance.
```
- **NodeJS**
  
```plaintext
- User uploads an image via API Gateway (POST /upload).
- API Gateway routes request to AWS Lambda, which is running Node.js (Express.js).
- Node.js (Express.js) in AWS Lambda:
- Uses NodeJS ##Multer## to process file uploads.
- Saves original image in Amazon S3.
- Calls NodeJS ##sharp## to create resized images.
- Calls AWS DynamoDB to store short URLs.
- Node.js sends JSON response back to API Gateway with:
- Original image URL
- Resized image URLs
- Shortened URL
```
- **Github Actions**
```plaintext

- Code Checkout	and branch creation fetches the latest version of the repository
- Terraform Security Scan (tfsec)	Checks for security misconfigurations in Terraform based on the inhouse configuration of allowable practises in the tools config file.
- Cost Estimation (Infracost)	Estimates AWS infrastructure cost before deployment based on the inhouse configuration of allowable practises in the tools config file.
- Terraform Apply	Deploys AWS infrastructure (S3, Lambda, API Gateway, DynamoDB)
- Build & Package Lambda	Installs NodeJS dependencies and creates lambda.zip
- Upload Lambda to S3	Stores the ZIP package in an S3 bucket
- Update Lambda Code	Deploys the latest function version to AWS
- CloudFront Cache Invalidation	ensures the latest frontend is served whilst only invalidating changed code in the cache to ensure cost minimisation.
```
- **AWS Serverless Scaling**
```plaintext
  ##Scenario: A Sudden Surge in Image Uploads
- A user uploads an image, triggering POST /upload.
- API Gateway forwards the request to AWS Lambda.
- AWS Lambda runs the function and processes the image.
- More users upload images, so AWS Lambda scales automatically:
- Starts with zero instances.
- Scales up to multiple instances if traffic increases.
- Scales down to zero when demand drops.
- DynamoDB scales up to handle more shortened URL lookups.
- S3 stores all images, handling high traffic automatically.
- CloudFront caches images, reducing the need for redundant Lambda invocations.

Result: The system scales without downtime or manual intervention!
```
- **Cloudwatch**
```plaintext
  ##Scenario: Monitoring a High-Traffic Image Upload##

- User uploads an image via API Gateway (POST /upload).
- API Gateway logs the request in CloudWatch.
- AWS Lambda runs the function, and CloudWatch records execution time, errors, and memory usage.
- If Lambda execution time exceeds x seconds, CloudWatch triggers an alert via SNS (Email, Slack, etc.).
- DynamoDB auto-scales, and CloudWatch logs throughput usage.
- CloudFront caches images, and CloudWatch tracks cache hit rates.

Result: Real-time monitoring of system performance and automatic scaling adjustments.
```
The entire infrastructure is automated with **Terraform**, while **GitHub Actions** in this example ensures continuous deployment upon successful
workflow consideration of the **github actions** pull request review, ##tfsec static analysis## to defined guidelines and ##Infracost## infrastructure AWS costing steps.

For simplicity and cost reduction no VPC, EC2, ECS OR EKS or traditional cloud structures are required.

The architecture is optimized for **cost-effectiveness**, **performance optimisation## utilizing AWS's free-tier offerings and minimizing unnecessary expense.

---
## Features

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
- **Route53** costs would apply if not using AWS generated URLs. If using Custom API Domains, Custom Image Sharing Domain names or Custom Frontend Domain names.

---
## Project Structure
```plaintext
📦 image-management-platform
 ┣ 📂 backend              # AWS Lambda function (Express API)
 ┃ ┣ 📜 server.js          # Handle API requests
 ┃ ┣ 📜 imageProcessor.js  # Handles image resizing
 ┃ ┣ 📜 urlShortener.js    # Handles URL shortening
 ┃ ┣ 📜 package.json       # Configure React and Node dependencies.  
 ┃ ┣ 📜 lambda.zip         # Deployable zipped AWS Lambda for Terraform upload.
 ┣ 📂 frontend             # Next.js UI
 ┃ ┣ 📂 pages              
 ┃ ┣ 📜 package.json       # Configure React and Node dependencies. 
 ┃ ┣ 📜 index.js           # API Endpoints
 ┣ 📂 terraform            # AWS Infrastructure (S3, Lambda, CloudFront, API Gateway, DynamoDB, IAM etc)
 ┃ ┣ 📜 backend.tf         # Runs the backend logic (image processing, resizing, URL shortening).  Generates the index.html served page.
- Exposes the Lambda function as a RESTful API
- Stores shortened URLs in conjuction with DynamoDB for image sharing
- Grants permissions for Lambda to access S3, DynamoDB, and API Gateway
  ┃ ┣ 📜 frontend.tf        # S3 Bucket Stores the Next.js static files (frontend) cloudFront Distribution	Serves the website
= securely & globally Bucket Policy	Makes the S3 content publicly accessible via CloudFront
 ┃ ┣ 📜 cloudfront.tf      # CloudFront for S3	Serves the frontend (Next.js, Express.js, index.js and associated CSS files, prettyfying the UI)
 ┃ ┣ 📜 lambda.tf          # Deploy Github built Lambdas as zip files to S3 storage.
 ┃ ┣ 📜 iam.tf             # Define security controls.
 ┃ ┣ 📜 outputs.tf         # Show AWS API endpoint and URL's
 ┃ ┣ 📜 variables.tf       # Define aws_region, s3_bucket_name, lambda_function_name, api_gateway_stage, dynamodb_table_name. 
 ┃ ┣ 📜 providers.tf       # Define AWS Terraform providers
 ┃ ┣ 📜 backend-config.tf  # Save Terraform State to S3 
 ┣ 📂 .github              # CI/CD GitHub Actions
 ┃ ┣ 📜 deploy.yml
 ┗ 📜 README.md

```
## Infrastructure Overview

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

## Deployment Steps

### **Set Up AWS Credentials in GitHub Actions**
- Go to **GitHub > Settings > Secrets** and add:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
 
### **Create a development branch referencing change ticket number in branch name**##

### **Submit a Pull Request for Code Changes**
- Push your changes to a **feature branch**:
```sh
git add .
git commit -m "New feature implementation"
git push origin <feature-branch>
```
- Open a pull request in GitHub request peer review before merging.

### **Merge Approved Pull Request & Deploy**
Once the pull request is approved and merged to `main/master`, GitHub Actions will **automatically deploy** the backend & frontend:
```sh
git push origin main
```
- After deployment, the **AWS Lambda function will detect changed files and clear only those files from CloudFront cache**.

### **Access Your Deployed App**
Run:
```sh
terraform output
```
Then open:
```plaintext
Frontend: https://<cloudfront-id>.cloudfront.net
Backend API: https://<api-id>.execute-api.eu-north-1.amazonaws.com/prod
```

The pipeline can be re-written for other such CI/CD products such as Gitlab / Bitbucket / CircleCI / Jenkins etc within the 
constraints and pipeline amendments unique to each VCS platform.

---

## Cost Optimization Strategies
- **Use AWS Free Tier** for S3, Lambda, API Gateway, and DynamoDB where possible.
- **Enable S3 Lifecycle Policies** to automatically delete unused images.
- **Use On-Demand DynamoDB** to minimize unnecessary storage costs.
- **Use CloudFront caching** to reduce S3 bandwidth usage.
- **Monitor Lambda usage with CloudWatch** and optimize execution time to stay within free-tier limits.
- **Leverage AWS Lambda Auto-Scaling** to handle predictable upload traffic spikes efficiently.
- **Utilize short links** to reduce unnecessary API calls and storage costs.
- **Enforce pull request authorization** to prevent unintended deployments and maintain high code quality.
- **Integrate tfsec** into github workflow for Terraform security scanning to detect misconfigurations before deployment.
- **Use Infracost** into github workflow to estimate and monitor AWS infrastructure costs before applying Terraform changes.
- **Optimize CloudFront cache invalidation** by clearing only cache changed files using AWS Lambda.

---
## Mobile Compatibility Enhancements

- CORS & Preflight (OPTIONS)	Fixes API access issues in mobile browsers
- WebP Format for Mobile loads images 40% faster on mobile platfoems.
- CloudFront User-Agent Detection	Optimizes caching per device type
- Auto Image Conversion in Lambda	Ensures best image quality without user effort
- API Gateway with WebSockets (Future)	Enables real-time uploads for mobile apps

## Route53 Considerations

- Route 53 is NOT required if using AWS-provided default URLs.
- Route 53 is required if we want a custom domain name like api.example.com or app.example.com.

                 +---------------------------+
                 |          Users            |
                 |  (Web, Mobile App)        |
                 |  (iOS, Android, Browser)  |
                 +------------+--------------+
                              |
                 +------------+----------------+
                 |   Amazon CloudFront (CDN)   |
                 |  - Caches frontend & images |
                 |  - Accelerates API requests |
                 |  - Optimized for Mobile     |
                 +------------+----------------+
                              |
              +---------------+-------------------+
              |            API Gateway            |
              |  - Exposes REST API for uploads   |
              |  - Routes traffic to Lambda       |
              |  - Supports CORS for Mobile       |
              +---------------+-------------------+
                              |
                +-------------+-----------------+
                |       AWS Lambda (Backend)    |
                |  - Handles image uploads      |
                |  - Resizes images             |
                |  - Generates short URLs       |
                |  - Detects Mobile User-Agent  |
                +---+-+--------------+----------+
                    | |              |
                    | |              |
      +-------------+-+---+     +----+--------------+
      |   Amazon S3       |     |  Amazon DynamoDB  |
      | (Image Storage)   |     | (Short URLs Data) |
      | - Stores WebP/JPEG|     | - Maps short IDs  |
      | - Mobile Optimized|     | - Fast lookups    |
      +-------------------+     +-------------------+

### **TFsec output**

![image](https://github.com/user-attachments/assets/dd4a8488-542c-42db-aeae-c7fc4546e119)

```plaintext
### **Infracost Output**

derek@DEREK-VIVOBOOK:~/terraform-image-demo$ **infracost breakdown --path .**
INFO Autodetected 1 Terraform project across 1 root module
INFO Found Terraform project terraform at directory terraform

Project: terraform
Module path: terraform

 Name                                                      Monthly Qty  Unit                  Monthly Cost (GBP)

 aws_wafv2_web_acl.cloudfront_waf
 ├─ Web ACL usage                                                    1  months                             £4.01
 └─ Requests                                       Monthly cost depends on usage: £0.48 per 1M requests

 aws_kms_key.dynamodb_kms
 ├─ Customer master key                                              1  months                             £0.80
 ├─ Requests                                       Monthly cost depends on usage: £0.024057 per 10k requests
 ├─ ECC GenerateDataKeyPair requests               Monthly cost depends on usage: £0.08019 per 10k requests
 └─ RSA GenerateDataKeyPair requests               Monthly cost depends on usage: £0.08019 per 10k requests

 aws_kms_key.frontend_kms_key
 ├─ Customer master key                                              1  months                             £0.80
 ├─ Requests                                       Monthly cost depends on usage: £0.024057 per 10k requests
 ├─ ECC GenerateDataKeyPair requests               Monthly cost depends on usage: £0.08019 per 10k requests
 └─ RSA GenerateDataKeyPair requests               Monthly cost depends on usage: £0.08019 per 10k requests

 aws_kms_key.s3_key
 ├─ Customer master key                                              1  months                             £0.80
 ├─ Requests                                       Monthly cost depends on usage: £0.024057 per 10k requests
 ├─ ECC GenerateDataKeyPair requests               Monthly cost depends on usage: £0.08019 per 10k requests
 └─ RSA GenerateDataKeyPair requests               Monthly cost depends on usage: £0.08019 per 10k requests

 aws_api_gateway_rest_api.image_api
 └─ Requests (first 333M)                          Monthly cost depends on usage: £2.81 per 1M requests

 aws_cloudfront_distribution.cdn
 ├─ Real-time log requests                         Monthly cost depends on usage: £0.008 per 1M lines
 ├─ Invalidation requests (first 1k)               Monthly cost depends on usage: £0.00 per paths
 └─ US, Mexico, Canada
    ├─ Data transfer out to internet (first 10TB)  Monthly cost depends on usage: £0.0681615 per GB
    ├─ Data transfer out to origin                 Monthly cost depends on usage: £0.016038 per GB
    ├─ HTTP requests                               Monthly cost depends on usage: £0.006014 per 10k requests
    └─ HTTPS requests                              Monthly cost depends on usage: £0.008019 per 10k requests

 aws_cloudfront_distribution.imager
 ├─ Real-time log requests                         Monthly cost depends on usage: £0.008 per 1M lines
 ├─ Invalidation requests (first 1k)               Monthly cost depends on usage: £0.00 per paths
 └─ US, Mexico, Canada
    ├─ Data transfer out to internet (first 10TB)  Monthly cost depends on usage: £0.0681615 per GB
    ├─ Data transfer out to origin                 Monthly cost depends on usage: £0.016038 per GB
    ├─ HTTP requests                               Monthly cost depends on usage: £0.006014 per 10k requests
    └─ HTTPS requests                              Monthly cost depends on usage: £0.008019 per 10k requests

 aws_dynamodb_table.urls
 ├─ Write request unit (WRU)                       Monthly cost depends on usage: £0.0000005012 per WRUs
 ├─ Read request unit (RRU)                        Monthly cost depends on usage: £0.0000001002 per RRUs
 ├─ Data storage                                   Monthly cost depends on usage: £0.20 per GB
 ├─ Point-In-Time Recovery (PITR) backup storage   Monthly cost depends on usage: £0.16 per GB
 ├─ On-demand backup storage                       Monthly cost depends on usage: £0.08019 per GB
 ├─ Table data restored                            Monthly cost depends on usage: £0.12 per GB
 └─ Streams read request unit (sRRU)               Monthly cost depends on usage: £0.0000001604 per sRRUs

 aws_lambda_function.image_lambda
 ├─ Requests                                       Monthly cost depends on usage: £0.16 per 1M requests
 ├─ Ephemeral storage                              Monthly cost depends on usage: £0.0000000248 per GB-seconds
 └─ Duration (first 6B)                            Monthly cost depends on usage: £0.000013365 per GB-seconds

 aws_s3_bucket.cloudfront_logs
 └─ Standard
    ├─ Storage                                     Monthly cost depends on usage: £0.0184437 per GB
    ├─ PUT, COPY, POST, LIST requests              Monthly cost depends on usage: £0.0040095 per 1k requests
    ├─ GET, SELECT, and all other requests         Monthly cost depends on usage: £0.0003208 per 1k requests
    ├─ Select data scanned                         Monthly cost depends on usage: £0.0016038 per GB
    └─ Select data returned                        Monthly cost depends on usage: £0.00056133 per GB

 aws_s3_bucket.frontend
 └─ Standard
    ├─ Storage                                     Monthly cost depends on usage: £0.0184437 per GB
    ├─ PUT, COPY, POST, LIST requests              Monthly cost depends on usage: £0.0040095 per 1k requests
    ├─ GET, SELECT, and all other requests         Monthly cost depends on usage: £0.0003208 per 1k requests
    ├─ Select data scanned                         Monthly cost depends on usage: £0.0016038 per GB
    └─ Select data returned                        Monthly cost depends on usage: £0.00056133 per GB

 aws_s3_bucket.frontend_s3
 └─ Standard
    ├─ Storage                                     Monthly cost depends on usage: £0.0184437 per GB
    ├─ PUT, COPY, POST, LIST requests              Monthly cost depends on usage: £0.0040095 per 1k requests
    ├─ GET, SELECT, and all other requests         Monthly cost depends on usage: £0.0003208 per 1k requests
    ├─ Select data scanned                         Monthly cost depends on usage: £0.0016038 per GB
    └─ Select data returned                        Monthly cost depends on usage: £0.00056133 per GB

 aws_s3_bucket.images
 └─ Standard
    ├─ Storage                                     Monthly cost depends on usage: £0.0184437 per GB
    ├─ PUT, COPY, POST, LIST requests              Monthly cost depends on usage: £0.0040095 per 1k requests
    ├─ GET, SELECT, and all other requests         Monthly cost depends on usage: £0.0003208 per 1k requests
    ├─ Select data scanned                         Monthly cost depends on usage: £0.0016038 per GB
    └─ Select data returned                        Monthly cost depends on usage: £0.00056133 per GB

 aws_s3_bucket.logs
 └─ Standard
    ├─ Storage                                     Monthly cost depends on usage: £0.0184437 per GB
    ├─ PUT, COPY, POST, LIST requests              Monthly cost depends on usage: £0.0040095 per 1k requests
    ├─ GET, SELECT, and all other requests         Monthly cost depends on usage: £0.0003208 per 1k requests
    ├─ Select data scanned                         Monthly cost depends on usage: £0.0016038 per GB
    └─ Select data returned                        Monthly cost depends on usage: £0.00056133 per GB

 OVERALL TOTAL (GBP)                                                                                      £6.42

*Usage costs can be estimated by updating Infracost Cloud settings, see docs for other options.

──────────────────────────────────
45 cloud resources were detected:
∙ 14 were estimated
∙ 31 were free

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━┳━━━━━━━━━━━━┓
┃ Project                                            ┃ Baseline cost ┃ Usage cost* ┃ Total cost ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━╋━━━━━━━━━━━━┫
┃ terraform                                          ┃            £6 ┃           - ┃         £6 ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━┻━━━━━━━━━━━━┛
```

### **Illegal Content**

Considertation must be taken into account for illegal content uoploads therefore inclusion of utilisation of AI under https://aws.amazon.com/rekognition/content-moderation/
or using LLM AI at the Lambda level.    

This could be pulled and integrated into the Lambda via https://github.com/awslabs/aws-ai-solution-kit

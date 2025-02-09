# 📸 AWS Image Management Platform

This project is a **full-stack image management platform** deployed on AWS. It allows users to **upload, manage, and access images globally** using **CloudFront CDN**. The entire infrastructure is automated with **Terraform**, while **GitHub Actions** ensures continuous deployment.

---

## 🚀 Features
- **Frontend:** Next.js hosted on AWS S3 & served via CloudFront CDN  
- **Backend:** AWS Lambda (Node.js/Express) behind an API Gateway  
- **Storage:** AWS S3 for storing original and resized images  
- **Database:** AWS DynamoDB for storing metadata (URLs, timestamps, etc.)  
- **CI/CD:** GitHub Actions for automated deployments  
- **Security:** IAM roles for access control & API Gateway securing API requests  
- **Monitoring:** AWS CloudWatch for logs & performance tracking  

---

## 📂 Project Structure
```plaintext
📦 image-management-platform
 ┣ 📂 backend        # AWS Lambda function (Express API)
 ┃ ┣ 📜 server.js    # Handles image uploads, metadata & listing
 ┣ 📂 frontend       # Next.js (Fancy UI)
 ┃ ┣ 📂 pages
 ┃ ┣ 📂 components
 ┣ 📂 terraform      # AWS Infrastructure (S3, Lambda, CloudFront, API Gateway)
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
- CloudFront serves the site globally with **HTTPS & caching**, ensuring fast load times.

### **Backend (Lambda + API Gateway + S3 + DynamoDB)**
- API Gateway processes **image upload requests**.
- AWS Lambda functions handle image uploads and metadata storage in **DynamoDB**.
- S3 stores **both original and resized images**.

### **CI/CD (GitHub Actions + Terraform)**
- GitHub Actions automates **Terraform infrastructure deployment**.
- Any new code push triggers **automatic backend & frontend deployment**.

---

## 🔧 Deployment Steps

### **1️⃣ Set Up AWS Credentials in GitHub Actions**
- Go to **GitHub > Settings > Secrets** and add:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

### **2️⃣ Deploy Infrastructure with Terraform**
```sh
cd terraform
terraform init
terraform apply -auto-approve
```

### **3️⃣ Push Code to GitHub**
GitHub Actions will **automatically deploy** the backend & frontend:
```sh
git add .
git commit -m "🚀 Deploying AWS Image Management Platform"
git push origin main
```

### **4️⃣ Access Your Deployed App**
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

## 📌 API Endpoints
| **Method** | **Endpoint** | **Description** |
|-----------|-------------|-----------------|
| `POST` | `/upload` | Upload an image |
| `GET` | `/images` | List all images |
| `DELETE` | `/image/:id` | Delete an image |

---

## 🔥 Next Steps
- ✅ Add authentication with **AWS Cognito** for user management.
- ✅ Implement **CloudWatch Monitoring** for logs and alerts.
- ✅ Optimize image handling with **Lambda processing**.

---

## 💡 Contributing
We welcome contributions! Feel free to **open an issue** or **submit a pull request** to enhance this project. 🚀


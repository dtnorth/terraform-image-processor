📸 AWS Image Management Platform

This project is a full-stack image management platform deployed on AWS. It allows users to upload images, manage them, and access them globally using CloudFront CDN. The entire infrastructure is automated using Terraform, with CI/CD powered by GitHub Actions.

🚀 Features

✅ Frontend: Next.js hosted on AWS S3 & served via CloudFront CDN
✅ Backend: AWS Lambda (Node.js/Express) behind an API Gateway
✅ Storage: AWS S3 for storing original and resized images
✅ Database: AWS DynamoDB for storing metadata (URLs, timestamps, etc.)
✅ CI/CD: GitHub Actions for automatic deployments
✅ Security: IAM roles for permissions & API Gateway securing API requests
✅ Monitoring: AWS CloudWatch for logs & performance metrics

📂 Project Structure

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

🏗️ Infrastructure Overview

Frontend (Next.js + S3 + CloudFront)

Next.js application is statically exported and uploaded to S3.

CloudFront serves the site globally with HTTPS & caching.

Backend (Lambda + API Gateway + S3 + DynamoDB)

API Gateway handles image upload requests.

Lambda processes the images and stores metadata in DynamoDB.

S3 bucket stores original & resized images.

CI/CD (GitHub Actions + Terraform)

GitHub Actions automates Terraform infrastructure deployment.

Deploys backend & frontend automatically when code is pushed.

🔧 Deployment Steps

1️⃣ Setup AWS Credentials in GitHub Actions

Go to GitHub > Settings > Secrets and add:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

2️⃣ Deploy Infrastructure with Terraform

cd terraform
terraform init
terraform apply -auto-approve

3️⃣ Push Code to GitHub

GitHub Actions will automatically deploy the backend & frontend:

git add .
git commit -m "🚀 Deploying AWS Image Management Platform"
git push origin main

4️⃣ Access Your Deployed App

Run:

terraform output

Then open:

Frontend: https://your-cloudfront-id.cloudfront.net
Backend API: https://your-api-id.execute-api.eu-north-1.amazonaws.com/prod

📌 API Endpoints

Method

Endpoint

Description

POST

/upload

Upload an image

GET

/images

List all images

DELETE

/image/:id

Delete an image

🔥 Next Steps

✅ Add authentication with AWS Cognito

✅ Implement CloudWatch Monitoring

✅ Optimize images with Lambda processing

💡 Contributing

Feel free to open an issue or submit a pull request to improve this project! 🚀

resource "aws_iam_role" "github_oidc_role" {
  name = "GitHub-Terraform-Deploy"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::897729117574:oidc-provider/token.actions.githubusercontent.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "token.actions.githubusercontent.com:sub": "repo:dtnorth/terraform-bjss:ref:refs/heads/main"
          }
        }
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "github_terraform_policy" {
  name        = "GitHubTerraformPolicy"
  description = "Allows Terraform actions in AWS"
  
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:*",
          "s3:*",
          "iam:*",
          "vpc:*",
          "elasticloadbalancing:*",
          "cloudwatch:*"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "github_attach_policy" {
  role       = aws_iam_role.github_oidc_role.name
  policy_arn = aws_iam_policy.github_terraform_policy.arn
}


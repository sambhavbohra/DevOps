# AWS Services Research: 01. IAM (Identity and Access Management)

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## 1. What is AWS IAM?
AWS Identity and Access Management (IAM) is a web service that helps you securely control access to AWS resources. IAM enables you to manage authentication (who can sign in) and authorization (what permissions they have to access resources) centrally across your AWS cloud infrastructure. IAM is a global service and requires no regional selection.

---

## 2. Core IAM Entities

### A. IAM Users
An IAM User represents a human person or service account that interacts with AWS.
- Each user has a unique username and friendly name.
- Authentication credentials can include a Console Password (for AWS Management Console) and up to two active Access Key ID / Secret Access Key pairs (for CLI, SDK, and programmatic API access).

### B. IAM User Groups
An IAM Group is a collection of IAM users.
- Groups allow administrators to specify permissions for multiple users simultaneously, simplifying management.
- Example groups: `Admins`, `Developers`, `SecurityAuditors`, `DevOpsEngineers`.
- A user can belong to multiple groups, but groups cannot be nested inside other groups.

### C. IAM Roles
An IAM Role is an identity with specific permissions that is not uniquely tied to one person. Instead, it is assumed by anyone or anything that needs it.
- **Trusted Entities:** Can be assumed by IAM users, other AWS accounts, AWS services (e.g., an EC2 instance or Lambda function needing access to S3), or external federated identity providers (SAML 2.0 / OpenID Connect).
- **Temporary Credentials:** When a role is assumed, AWS STS (Security Token Service) issues short-lived temporary security credentials (typically valid from 15 minutes up to 12 hours).

---

## 3. Policies & Permissions

### A. IAM Policies
An IAM Policy is a JSON document that defines permissions by explicitly granting or denying actions on AWS resources.

#### Standard Policy Structure:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowS3ReadSpecificBucket",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::scaler-devops-24bcs10090",
        "arn:aws:s3:::scaler-devops-24bcs10090/*"
      ]
    }
  ]
}
```

### B. Types of Policies
1. **Identity-Based Policies:** Attached directly to Users, Groups, or Roles (Managed or Inline).
2. **Resource-Based Policies:** Attached directly to resources (e.g., S3 Bucket Policies, KMS Key Policies).
3. **Permissions Boundaries:** Advanced feature setting the maximum allowable permissions an identity-based policy can grant.
4. **Service Control Policies (SCPs):** Organization-level guardrails applied across AWS member accounts.

---

## 4. Principle of Least Privilege

The Principle of Least Privilege is the fundamental security practice of granting identities only the absolute minimum set of permissions necessary to perform their assigned job duties, and nothing more.

### How to Enforce:
- Start with zero permissions and incrementally grant specific actions (e.g., allow `s3:GetObject` instead of `s3:*`).
- Restrict resource ARNs to specific bucket names or instance IDs instead of `Resource: "*"`.
- Use condition keys (e.g., enforce MFA, restrict access by source IP or VPC Endpoint).

---

## 5. IAM Security Best Practices

1. **Lock Away the AWS Account Root User:** Never use the root account for daily administration; enable hardware MFA immediately.
2. **Require Multi-Factor Authentication (MFA):** Enforce MFA for all console users and privileged CLI operations.
3. **Use Roles for Applications & EC2:** Never hardcode long-term AWS access keys inside code repositories or AMI configurations; use IAM Instance Profiles.
4. **Rotate Access Keys Regularly:** Enforce 90-day credential rotation cycles.
5. **Continuous Auditing:** Use AWS IAM Access Analyzer and AWS CloudTrail to detect unused permissions and generate least-privilege policies.

---

## 6. Common Use Cases

- **Developer Access:** Assigning developer groups restricted access to staging ECS/EKS clusters and CloudWatch logs.
- **CI/CD Pipeline Authentication:** Using OpenID Connect (OIDC) to authenticate GitHub Actions workflows directly into AWS without storing permanent access keys.
- **Cross-Account Management:** Allowing centralized security auditor roles in a master account to inspect resources in member accounts.

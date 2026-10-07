# AWS Services Research: 03. S3 (Simple Storage Service)

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## 1. What is Amazon S3?
Amazon Simple Storage Service (Amazon S3) is an object storage service offering industry-leading scalability, data availability, security, and performance. S3 stores unstructured data as objects within containers called buckets, providing 99.999999999% (11 9s) of data durability across multiple physical Availability Zones.

---

## 2. Core Concepts

### A. Buckets
- Fundamental container for objects in S3.
- Bucket names are globally unique across all AWS accounts worldwide.
- Created in a specific AWS region to optimize latency and satisfy regulatory data residency laws.

### B. Objects
- The fundamental entities stored in S3.
- Consists of Object Data (file content from 0 bytes up to 5 TB), a unique Key (string name/path), Metadata (key-value pairs), and Version ID.

### C. Storage Classes
1. **S3 Standard:** High throughput, low latency for frequently accessed data.
2. **S3 Intelligent-Tiering:** Automatically moves data between tiers based on changing access patterns without operational overhead.
3. **S3 Standard-Infrequent Access (Standard-IA):** For data accessed less frequently but requiring millisecond retrieval.
4. **S3 One Zone-IA:** Lower cost option storing data in a single AZ for easily reproducible files.
5. **S3 Glacier Flexible Retrieval:** Low-cost archive storage with retrieval times from minutes to hours.
6. **S3 Glacier Deep Archive:** Lowest cost cloud storage designed for long-term compliance retention (retrieval within 12 hours).

### D. Versioning
Preserves, retrieves, and restores every version of every object stored in a bucket.
- Protects against accidental overwrites and malicious deletions.
- Deleting an object creates a Delete Marker rather than permanently removing the data until explicitly requested.

### E. Lifecycle Policies
Automated rules that manage objects during their lifespan to reduce costs:
- **Transition Actions:** Move objects to colder tiers (e.g., move to S3 Glacier after 90 days).
- **Expiration Actions:** Automatically delete objects after a specified retention window (e.g., purge application log files after 365 days).

### F. Encryption
- **Server-Side Encryption with Amazon S3 Managed Keys (SSE-S3):** Default AES-256 encryption.
- **Server-Side Encryption with AWS KMS (SSE-KMS):** Provides audit trail, key rotation, and granular access controls.
- **Server-Side Encryption with Customer-Provided Keys (SSE-C):** Customer manages cryptographic keys while AWS manages encryption operations.
- **Client-Side Encryption:** Data is encrypted locally prior to uploading to S3.

### G. Bucket Policies
JSON-based access policy language attached directly to S3 buckets, used to enforce cross-account access, HTTPS-only transport (`aws:SecureTransport`), and restrict IP CIDRs.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnforceTLSRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::scaler-devops-24bcs10090",
        "arn:aws:s3:::scaler-devops-24bcs10090/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
```

---

## 3. Common Use Cases

- Static website hosting (HTML, CSS, JavaScript, assets).
- Data Lake storage for big data analytics (Amazon Athena, EMR, Snowflake).
- Application media and user upload repository.
- Disaster recovery and automated backup storage for database snapshots.
- Terraform remote state backend storage with state locking via DynamoDB.

# AWS Services Research: 05. DynamoDB & RDS Database Services

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## Part 1: Amazon DynamoDB (NoSQL Database)

### 1. What is Amazon DynamoDB?
Amazon DynamoDB is a fully managed, serverless, key-value and document NoSQL database designed for running high-performance applications at any scale. DynamoDB offers single-digit millisecond latency, automated multi-region replication, and built-in in-memory caching with DAX.

### 2. Core DynamoDB Concepts
- **Tables:** Collections of data items (equivalent to tables in relational databases).
- **Items:** A group of attributes uniquely identifiable among all other items (equivalent to rows or records). Maximum size is 400 KB per item.
- **Attributes:** Fundamental data element requiring no predefined schema except for primary key components (equivalent to columns/fields).
- **Primary Key Schemes:**
  1. **Partition Key (Simple Primary Key):** A single attribute used by an internal hash function to distribute items evenly across physical storage partitions.
  2. **Composite Primary Key (Partition Key + Sort Key):** Items with the same partition key are stored together in sorted order by the sort key value, enabling range queries (`begins_with`, `between`, `<`, `>`).

### 3. DynamoDB Use Cases
- High-traffic mobile, web, and gaming user session stores.
- Real-time IoT sensor telemetry data ingestion.
- Shopping cart state management in e-commerce platforms.
- Serverless event-driven architectures paired with AWS Lambda and DynamoDB Streams.

---

## Part 2: Amazon RDS (Relational Database Service)

### 1. What is Amazon RDS?
Amazon Relational Database Service (Amazon RDS) is a managed web service that simplifies the setup, operation, and scaling of relational databases in the cloud. It automates time-consuming administrative tasks such as hardware provisioning, database setup, patching, and backups.

### 2. Supported Database Engines
- PostgreSQL
- MySQL
- MariaDB
- Oracle Database
- Microsoft SQL Server
- Amazon Aurora (MySQL and PostgreSQL-compatible cloud-native database)

### 3. Core RDS Features
- **DB Instances:** Basic building block of RDS running the chosen database engine on dedicated compute and EBS storage.
- **Security:** Network isolation within VPC private subnets, security groups, SSL/TLS in-transit encryption, and AWS KMS at-rest encryption.
- **Automated Backups & Snapshots:** Point-In-Time Recovery (PITR) with retention up to 35 days, plus user-initiated manual snapshots that persist indefinitely.
- **Multi-AZ Deployments:** Synchronous replication to a standby instance in a different Availability Zone for automatic failover during hardware failures or maintenance.
- **Read Replicas:** Asynchronous replication across up to 15 read-only instances to offload read-heavy reporting and query traffic.

### 4. RDS Use Cases
- Traditional transactional enterprise applications (ERP, CRM, accounting).
- Structured relational business databases requiring ACID compliance and complex SQL JOIN queries.
- Legacy application migrations from on-premises data centers to AWS.

---

## Comparison Summary: DynamoDB vs RDS

| Architectural Feature | Amazon DynamoDB | Amazon RDS |
| :--- | :--- | :--- |
| **Data Model** | NoSQL (Key-Value / Document) | Relational (SQL Tables / Foreign Keys) |
| **Schema** | Schema-less (Dynamic attributes) | Fixed, pre-defined schema |
| **Scaling Mechanism** | Automatic horizontal partitioning & throughput | Vertical instance scaling & horizontal Read Replicas |
| **High Availability** | Built-in cross-3 AZ replication by default | Multi-AZ synchronous standby configuration |
| **Latency Profile** | Predictable single-digit milliseconds at any scale | Milliseconds varying by complex joins & indexing |

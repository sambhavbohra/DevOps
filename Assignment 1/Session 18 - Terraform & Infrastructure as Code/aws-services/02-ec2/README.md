# AWS Services Research: 02. EC2 (Elastic Compute Cloud)

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## 1. What is Amazon EC2?
Amazon Elastic Compute Cloud (Amazon EC2) is a web service that provides resizable, on-demand compute capacity in the cloud. It eliminates the need to invest in hardware up front, enabling rapid development and scaling of virtual server instances with full administrative control.

---

## 2. Core EC2 Concepts

### A. Amazon Machine Image (AMI)
An AMI is a template that contains the software configuration (operating system, application server, and initial application state) required to launch your instance.
- **AWS Provided AMIs:** Official Amazon Linux 2023, Ubuntu Server, Red Hat, Windows Server.
- **Custom AMIs:** Pre-baked machine images containing custom runtime dependencies, monitoring agents, and hardening configurations.
- **AWS Marketplace AMIs:** Pre-configured commercial appliances from vendors.

### B. Instance Types
EC2 offers an extensive selection of instance families optimized for different compute profiles:
- **General Purpose (`t3`, `t4g`, `m6i`, `m7g`):** Balanced compute, memory, and networking for web servers, dev environments, and small databases.
- **Compute Optimized (`c6i`, `c7g`):** High compute power per dollar for batch processing, high-performance web servers, and scientific modeling.
- **Memory Optimized (`r6i`, `r7g`, `x2gd`):** High RAM capacity for in-memory caches (Redis/Memcached) and big data analytics.
- **Storage Optimized (`i3en`, `d3`):** High sequential read/write IOPS for data warehousing and distributed filesystems.
- **Accelerated Computing (`p4`, `g5`):** Hardware GPU/FPGA accelerators for machine learning inference and graphics rendering.

### C. Key Pairs
EC2 uses public-key cryptography to authenticate remote access:
- AWS stores the public key on the EC2 instance inside `~/.ssh/authorized_keys`.
- The user retains the private key (`.pem` or `.ppk` file) to establish secure SSH (Linux) or RDP (Windows) sessions.

### D. Security Groups
A Security Group acts as a stateful virtual firewall for your EC2 instances to control incoming and outgoing network traffic:
- **Stateful:** If you send an outbound request, return traffic is automatically allowed regardless of inbound rules.
- **Default Behavior:** All inbound traffic is denied by default; all outbound traffic is allowed.
- Rules can specify protocol (TCP, UDP, ICMP), port range (e.g. 22, 80, 443), and source CIDR / security group IDs.

### E. Elastic Block Store (EBS)
Amazon EBS provides persistent, raw block-level storage volumes for use with EC2 instances:
- **Volume Types:**
  - `gp3` / `gp2`: General Purpose SSDs balancing price and performance.
  - `io2` / `io1`: Provisioned IOPS SSDs for mission-critical low-latency databases.
  - `st1` / `sc1`: Throughput Optimized and Cold HDDs for big data logs.
- **Snapshots:** Incremental point-in-time backups stored reliably in Amazon S3.

### F. Public vs Private IP Addresses
- **Public IP:** Globally routable IPv4 address assigned from Amazon's pool. Changes automatically when an instance is stopped and restarted unless an Elastic IP (static IPv4) is attached.
- **Private IP:** Non-internet routable IPv4 address assigned from the VPC subnet CIDR range. Remains constant throughout the lifecycle of the instance network interface.

---

## 3. Instance Lifecycle

```
[ Pending ] ---> [ Running ] <---> [ Stopped ]
     |                |                 |
     v                v                 v
[ Terminated ]   [ Rebooting ]   [ Terminated ]
```

1. **Pending:** AWS prepares the instance, provisions EBS volumes, and launches virtual hardware.
2. **Running:** Instance is fully booted, running the operating system, and executing user workloads.
3. **Stopped:** Instance is shut down. CPU/RAM are released (no hourly compute charges), while EBS root volume remains intact.
4. **Terminated:** Instance is permanently destroyed and attached non-persistent EBS volumes are deleted.

---

## 4. Common Use Cases

- Hosting web servers, APIs, and microservices behind Application Load Balancers.
- Self-hosted databases (PostgreSQL, MongoDB, MySQL).
- Continuous Integration build nodes and distributed worker clusters.
- High-Performance Computing (HPC) and financial simulation workloads.

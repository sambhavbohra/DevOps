# AWS Services Research: 04. VPC (Virtual Private Cloud)

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## 1. What is Amazon VPC?
Amazon Virtual Private Cloud (Amazon VPC) is a logically isolated virtual network dedicated to your AWS account. It gives you full control over your virtual networking environment, including selection of your own IP address range, creation of subnets, and configuration of route tables and network gateways.

---

## 2. Core VPC Networking Components

### A. Classless Inter-Domain Routing (CIDR)
- Specifies the IPv4/IPv6 private address space allocated to the VPC (e.g., `10.0.0.0/16` providing 65,536 private IP addresses).
- AWS reserves 5 IP addresses in every subnet (Network address, VPC router, DNS resolver, Future use, Broadcast address).

### B. Subnets
A range of IP addresses in your VPC spanning a single specific Availability Zone:
- **Public Subnet:** Traffic is routed directly to an Internet Gateway (`0.0.0.0/0 -> igw-xxxx`). Instances can receive public IPs and communicate directly with the internet.
- **Private Subnet:** Isolated from direct internet access. No default route to an Internet Gateway.

### C. Route Tables
A set of rules (routes) used to determine where network traffic from your subnet or gateway is directed:
- **Main Route Table:** Automatically created with the VPC.
- **Custom Route Tables:** Explicitly associated with specific public or private subnets to dictate routing topologies.

### D. Internet Gateway (IGW)
A horizontally scaled, redundant, and highly available VPC component that enables communication between your VPC and the public internet:
- Performs 1-to-1 Network Address Translation (NAT) for instances with public IPv4 addresses.

### E. NAT Gateway
A managed AWS Network Address Translation service that enables instances in a private subnet to connect to outbound internet services (for software updates and package installations) while preventing the public internet from initiating inbound connections to those private instances:
- Deployed inside a public subnet with an attached Elastic IP address.

### F. Security Groups vs Network Access Control Lists (NACLs)

| Feature | Security Group | Network ACL (NACL) |
| :--- | :--- | :--- |
| **Operates At** | Instance / ENI level | Subnet level |
| **State Nature** | Stateful (Return traffic auto-allowed) | Stateless (Inbound & Outbound evaluated separately) |
| **Rule Types** | ALLOW rules only (implicit deny) | Explicit ALLOW and DENY rules |
| **Rule Order** | Evaluates all rules before decision | Evaluates numbered rules in ascending order |

---

## 3. Standard Multi-Tier VPC Architecture

```
                                  [ Internet Gateway ]
                                           |
    +--------------------------------------+--------------------------------------+
    | Public Subnet (10.0.1.0/24)          | Public Subnet (10.0.2.0/24)          |
    | - Application Load Balancer          | - NAT Gateway (EIP Attached)         |
    +--------------------------------------+--------------------------------------+
                                           |
                                           v
    +-----------------------------------------------------------------------------+
    | Private Subnet (10.0.10.0/24)                                               |
    | - EC2 Application Backend / Kubernetes Worker Nodes                         |
    +-----------------------------------------------------------------------------+
                                           |
                                           v
    +-----------------------------------------------------------------------------+
    | Isolated Database Subnet (10.0.20.0/24)                                     |
    | - Amazon RDS Database Cluster (No external routes)                          |
    +-----------------------------------------------------------------------------+
```

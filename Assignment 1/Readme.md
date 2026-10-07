# DevOps Engineering Portfolio & Practical Assignments

This repository contains the complete portfolio of DevOps engineering assignments, hands-on lab exercises, Infrastructure as Code configurations, container orchestration manifests, automated CI/CD and DevSecOps pipelines, observability stacks, and capstone production projects.

---

## Student Information

| Field | Detail |
|---|---|
| **Student Name** | Sambhav D Bohra |
| **Registration / Enrollment Number** | 24bcs10090 |
| **Course** | DevOps & Cloud Engineering |

---

## Complete Session Navigation Index

| Session | Topic | Directory | Documentation Link |
|---|---|---|---|
| **01 & 02** | Linux Fundamentals | `Session 01 & 02 - Linux Fundamentals/` | [View Notes](Session%2001%20&%2002%20-%20Linux%20Fundamentals/README.md) |
| **03** | Shell Scripting Automation | `Session 03 - Shell Scripting/` | [View Notes](Session%2003%20-%20Shell%20Scripting/README.md) |
| **04** | Networking Fundamentals & Diagnostics | `Session 04 - Networking Fundamentals/` | [View Notes](Session%2004%20-%20Networking%20Fundamentals/README.md) |
| **05** | Git Version Control & GitHub Workflows | `Session 05 - Git and GitHub/` | [View Notes](Session%2005%20-%20Git%20and%20GitHub/README.md) |
| **06** | Docker Fundamentals & Lifecycle | `Session 06 - Docker Fundamentals/` | [View Notes](Session%2006%20-%20Docker%20Fundamentals/README.md) |
| **07** | Dockerfiles & Multi-Stage Images | `Session 07 - Dockerfiles & Images/` | [View Notes](Session%2007%20-%20Dockerfiles%20&%20Images/README.md) |
| **08** | Docker Networking & Storage Mounts | `Session 08 - Docker Networking/` | [View Notes](Session%2008%20-%20Docker%20Networking/README.md) |
| **09** | Kubernetes Fundamentals & Architecture | `Session 09 - Kubernetes Fundamentals/` | [View Notes](Session%2009%20-%20Kubernetes%20Fundamentals/README.md) |
| **10** | Kubernetes Pods, ReplicaSets & Deployments | `Session 10 - Kubernetes Pods, ReplicaSets & Deployments/` | [View Notes](Session%2010%20-%20Kubernetes%20Pods,%20ReplicaSets%20&%20Deployments/README.md) |
| **11** | Kubernetes Networking & Services | `Session 11 - Kubernetes Networking & Services/` | [View Notes](Session%2011%20-%20Kubernetes%20Networking%20&%20Services/README.md) |
| **12** | Kubernetes Ingress, ConfigMaps & Secrets | `Session 12 - Kubernetes Ingress, ConfigMaps & Secrets/` | [View Notes](Session%2012%20-%20Kubernetes%20Ingress,%20ConfigMaps%20&%20Secrets/README.md) |
| **13** | Kubernetes Storage, HPA & Probes | `Session 13 - Kubernetes Storage, HPA & Probes/` | [View Notes](Session%2013%20-%20Kubernetes%20Storage,%20HPA%20&%20Probes/README.md) |
| **14** | Kubernetes Troubleshooting & Diagnostics | `Session 14 - Kubernetes Troubleshooting/` | [View Notes](Session%2014%20-%20Kubernetes%20Troubleshooting/README.md) |
| **15** | Helm Package Manager & Rollbacks | `Session 15 - Helm/` | [View Notes](Session%2015%20-%20Helm/README.md) |
| **16** | CI/CD Pipelines & GitHub Actions | `Session 16 - CI-CD & GitHub Actions/` | [View Notes](Session%2016%20-%20CI-CD%20&%20GitHub%20Actions/README.md) |
| **17** | Complete CI/CD & DevSecOps Security | `Session 17 - Complete CI-CD & DevSecOps/` | [View Notes](Session%2017%20-%20Complete%20CI-CD%20&%20DevSecOps/README.md) |
| **18** | Terraform & Infrastructure as Code | `Session 18 - Terraform & Infrastructure as Code/` | [View Notes](Session%2018%20-%20Terraform%20&%20Infrastructure%20as%20Code/README.md) |
| **19** | Cloud & Terraform in Action | `Session 19 - Cloud & Terraform in Action/` | [View Notes](Session%2019%20-%20Cloud%20&%20Terraform%20in%20Action/README.md) |
| **20** | Monitoring, Observability & GitOps | `Session 20 - Monitoring, Observability & GitOps/` | [View Notes](Session%2020%20-%20Monitoring,%20Observability%20&%20GitOps/README.md) |
| **21** | Final DevOps Capstone Project | `Session 21 - Final DevOps Project & Troubleshooting/` | [View Notes](Session%2021%20-%20Final%20DevOps%20Project%20&%20Troubleshooting/README.md) |

---

## Technology Stack & Tooling

```
+-------------------+---------------------------------------------------------------+
| Domain            | Technologies & Tools                                          |
+-------------------+---------------------------------------------------------------+
| Cloud & IaC       | AWS (VPC, EC2, S3, IAM, RDS, DynamoDB), Terraform             |
| Containers        | Docker, Docker Compose, Multi-Stage Builds, Non-Root Users    |
| Orchestration     | Kubernetes (Deployments, Services, Ingress, HPA, PVC, Probes) |
| Packaging         | Helm v3 / v4 (Charts, Multi-Environment Values, Rollbacks)    |
| CI/CD             | GitHub Actions Workflows, Self-Hosted & GitHub Runners        |
| DevSecOps         | Semgrep (SAST), pip-audit (SCA), Gitleaks (Secrets), Trivy    |
| Observability     | Prometheus, Grafana, Alertmanager, OpenTelemetry (OTel)       |
| GitOps            | ArgoCD, Continuous Reconciliation, Automated Drift Repair     |
| Scripting         | Bash, Python 3, Node.js                                       |
+-------------------+---------------------------------------------------------------+
```

---

## Detailed Overview by Session

### Sessions 01 & 02: Linux Fundamentals
File permissions, hard vs soft symbolic links, user and group management, system administration, and system log auditing.

### Session 03: Shell Scripting
Automated bash scripts (`system_info.sh`) collecting real-time CPU, memory, filesystem telemetry, and process statistics with output redirection.

### Session 04: Networking Fundamentals
Diagnostic tools including `ping`, `traceroute`, `dig`, `nslookup`, `nc`, `netstat`, `whois`, and `tcpdump` with local terminal evidence.

### Session 05: Git and GitHub
Version control workflows, comparing `git commit -m` vs `git commit -a -m`, branch merging strategies, and commit cherry-picking.

### Session 06: Docker Fundamentals
Container lifecycles, interactive debugging, environment variables, port forwarding, and container inspection.

### Session 07: Dockerfiles & Images
Multi-stage Docker builds for Go, Node.js, Python, and Java applications optimizing final layer footprint and execution security.

### Session 08: Docker Networking
Bridge, host, none, and overlay container networks, inter-container communication, and persistent volume bind mounts.

### Session 09: Kubernetes Fundamentals
Cluster architecture, control plane components (API Server, etcd, Scheduler, Controller Manager), worker nodes, and basic Pod lifecycle.

### Session 10: Kubernetes Pods, ReplicaSets & Deployments
Workload management, ReplicaSet scaling, zero-downtime rolling updates, and rollbacks.

### Session 11: Kubernetes Networking & Services
Service discovery patterns across ClusterIP, NodePort, LoadBalancer, ExternalName, and Headless services.

### Session 12: Kubernetes Ingress, ConfigMaps & Secrets
Decoupling configuration and credentials from container images, and NGINX Ingress host and path routing.

### Session 13: Kubernetes Storage, HPA & Probes
In-depth study of `emptyDir`, `hostPath`, `PersistentVolume`, `PersistentVolumeClaim`, and `StorageClass`. Hands-on Horizontal Pod Autoscaling under simulated load, and a multi-replica mini project with health probes.

### Session 14: Kubernetes Troubleshooting
Diagnostic commands (`get`, `describe`, `logs`, `exec`, `events`, `explain`, `top`, `get -o wide`), 8 dedicated runbooks for common failures (CrashLoopBackOff, ImagePullBackOff, Pending, ContainerCreating, Service selector mismatch, CoreDNS), and a multi-tier break-fix mini project.

### Session 15: Helm Package Manager
Core Helm CLI operations, full revision upgrade and rollback workflow (`Install -> Upgrade -> Broken Upgrade -> Rollback`), and a production-grade enterprise Helm chart supporting multi-environment value overrides.

### Session 16: CI/CD & GitHub Actions
Continuous Integration vs Continuous Delivery principles, multi-job workflow pipelines, automated unit testing, container builds, and staging/production rollout jobs in `10-final-cicd-pipeline`.

### Session 17: Complete CI/CD & DevSecOps
11-stage automated security pipeline incorporating SAST (Semgrep), SCA (pip-audit), Secret Scanning (Gitleaks), Container Vulnerability Scanning (Trivy), and automated Security Quality Gates.

### Session 18: Terraform & Infrastructure as Code
Declarative AWS S3 bucket automation with versioning, SSE encryption, public block, and lifecycle rules. In-depth research documentation for IAM, EC2, S3, VPC, DynamoDB, and RDS.

### Session 19: Cloud & Terraform in Action
End-to-end cloud infrastructure provisioning custom VPC networking, public/private subnets, security groups, bootstrapped EC2 web server, and encrypted S3 assets storage.

### Session 20: Monitoring, Observability & GitOps
Prometheus telemetry metric scraping, custom Alertmanager alerting rules, deep dive into the Three Pillars of Observability (Metrics, Logs, Traces), and declarative continuous GitOps reconciliation using ArgoCD.

### Session 21: Final DevOps Project & Troubleshooting
Capstone project unifying all course concepts: microservice application, multi-stage Docker build, Terraform AWS infrastructure, Kubernetes manifests with PVC and HPA, enterprise Helm chart, DevSecOps GitHub Actions pipeline, and full diagnosis of 4 complex production troubleshooting incidents.

---

## How to Run & Verify

1. **Prerequisites:** Install Docker, Minikube, kubectl, Helm, and Terraform.
2. **Kubernetes Exercises:** Start Minikube (`minikube start --driver=docker`) and enable addons (`minikube addons enable metrics-server ingress`).
3. **Terraform Projects:** Navigate to any Terraform directory and execute `terraform init`, `terraform fmt`, `terraform validate`, and `terraform plan`.
4. **Helm Charts:** Lint charts with `helm lint <chart-directory>` and deploy using `helm install <release-name> <chart-directory>`.
5. **Testing & Security:** Run pytest suites using `pytest <test-file> -v` and validate security gates using `bash security/security-gate.sh 0 0 0`.

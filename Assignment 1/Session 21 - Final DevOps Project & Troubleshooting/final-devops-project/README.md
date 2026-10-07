# Enterprise DevOps Capstone Project

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  
**Course:** DevOps & Cloud Engineering  

---

## 1. Project Overview

This capstone project implements an end-to-end enterprise DevOps platform that integrates all core competencies developed throughout the course:
- **Infrastructure as Code (IaC):** Modular Terraform provisioning custom AWS VPC networking, compute clusters, security groups, and encrypted S3 storage.
- **Microservice Architecture:** Production-ready Python Flask REST API with Prometheus telemetry instrumentation, structured JSON logging, and transactional persistence.
- **Containerization:** Multi-stage, non-root Docker build designed for minimal image surface area and high security.
- **Continuous Integration (CI):** Automated linting, pytest test suite execution, and test report artifact archiving.
- **DevSecOps Security Pipeline:** Comprehensive shift-left security enforcement integrating SAST (Semgrep), SCA (pip-audit), Secret Scanning (Gitleaks), Container Scanning (Trivy), and automated Security Quality Gates.
- **Kubernetes Orchestration:** Multi-replica Deployments, ClusterIP Services, NGINX Ingress, Horizontal Pod Autoscalers (HPA), Liveness & Readiness Probes, and dynamic Persistent Volume Claims (PVC).
- **Helm Package Management:** Configurable enterprise Helm charts with environment-specific overrides (Dev, Staging, Production).
- **Observability & Monitoring:** Prometheus metric scraping, custom Alertmanager alerting rules, and Grafana dashboard visualization.
- **GitOps Continuous Reconciliation:** Automated declarative cluster state synchronization using Git as the Single Source of Truth via ArgoCD.
- **Real-World Troubleshooting:** Complete diagnosis, root-cause analysis, and remediation for four realistic production break-fix incidents.

---

## 2. End-to-End Architecture Diagram

```
                                      [ Developer Git Push ]
                                                |
                                                v
                                    +-----------------------+
                                    | GitHub Actions CI/CD  |
                                    +-----------------------+
                                                |
          +---------------------+---------------+---------------------+
          |                     |                                     |
          v                     v                                     v
   +--------------+      +--------------+                      +--------------+
   | 1. CI Phase  |      | 2. DevSecOps |                      | 3. CD Phase  |
   | - Linter     |      | - Gitleaks   |                      | - Buildx     |
   | - Pytest     |      | - Semgrep    |                      | - Trivy Scan |
   | - Artifacts  |      | - pip-audit  |                      | - Gate Check |
   +--------------+      +--------------+                      +--------------+
                                                                      |
                                                                      v (Passes Security Gate)
                                                       +------------------------------+
                                                       | Push Image to Registry       |
                                                       | (ghcr.io/sambhavbohra/...)   |
                                                       +------------------------------+
                                                                      |
                                                                      v (GitOps Repo Sync)
                                                       +------------------------------+
                                                       | ArgoCD In-Cluster Operator   |
                                                       | Continuous Reconciliation    |
                                                       +------------------------------+
                                                                      |
                                                                      v
 =========================================================================================================
 AWS CLOUD INFRASTRUCTURE (PROVISIONED VIA TERRAFORM)
 =========================================================================================================
   [ Internet Gateway ]
           |
           v
   +---------------------------------------------------------------------------------------------------+
   | AWS Virtual Private Cloud (10.0.0.0/16)                                                           |
   |                                                                                                   |
   |   [ NGINX Ingress Controller ] (orders.scaler.internal)                                           |
   |                |                                                                                  |
   |                v                                                                                  |
   |   [ ClusterIP Service: order-platform-service ] (Port 80 -> Target 8080)                          |
   |                |                                                                                  |
   |   +------------+-------------------------------+-------------------------------+                  |
   |   |                                            |                               |                  |
   |   v                                            v                               v                  |
   | +----------------------------+   +----------------------------+   +----------------------------+  |
   | | Kubernetes Pod 1           |   | Kubernetes Pod 2           |   | Kubernetes Pod 3           |  |
   | | - Liveness & Readiness     |   | - Liveness & Readiness     |   | - Liveness & Readiness     |  |
   | | - Non-Root SecurityContext |   | - Non-Root SecurityContext |   | - Non-Root SecurityContext |  |
   | | - Prometheus /metrics      |   | - Prometheus /metrics      |   | - Prometheus /metrics      |  |
   | +----------------------------+   +----------------------------+   +----------------------------+  |
   |                |                               |                               |                  |
   |                +-------------------------------+-------------------------------+                  |
   |                                                |                                                  |
   |                                                v                                                  |
   |                            +---------------------------------------+                              |
   |                            | Dynamic Persistent Volume Claim (1Gi) |                              |
   |                            | /var/log/app/transactions.log         |                              |
   |                            +---------------------------------------+                              |
   |                                                                                                   |
   |   [ Prometheus Operator ] <-------- Scrapes Telemetry Metrics (/metrics)                          |
   |   [ Grafana Dashboards ]  <-------- Visualizes Throughput, Latency & Error Rates                  |
   |   [ Alertmanager Rules ]  <-------- Triggers Pager Alerts on SLO Violations                       |
   +---------------------------------------------------------------------------------------------------+
```

---

## 3. Technologies Used

| Domain | Technology / Tool | Version | Purpose |
| :--- | :--- | :--- | :--- |
| **Cloud Provider** | Amazon Web Services (AWS) | v5 Provider | VPC, Subnets, EC2, S3, Security Groups |
| **Infrastructure as Code** | HashiCorp Terraform | >= 1.5.0 | Declarative cloud infrastructure lifecycle |
| **Container Runtime** | Docker / Docker Compose | 28.0+ | Multi-stage container builds & isolation |
| **Container Orchestration**| Kubernetes (Minikube / EKS) | v1.37+ | Container scaling, self-healing, networking |
| **Package Management** | Helm | v3 / v4 | Parameterized chart templates & release rollbacks |
| **CI/CD Platform** | GitHub Actions | v4 Actions | Automated multi-stage pipeline workflows |
| **SAST Security** | Semgrep | Latest | Static code security analysis |
| **SCA Security** | pip-audit | Latest | Third-party dependency vulnerability scanning |
| **Secret Scanning** | Gitleaks | v2 Action | Git history API key and token detection |
| **Container Scanning** | Aqua Security Trivy | Latest | Base image OS and package vulnerability analysis |
| **Monitoring** | Prometheus | v2.50+ | Time-series metric collection and scraping |
| **Visualization** | Grafana | v10+ | Real-time performance dashboards |
| **GitOps Delivery** | ArgoCD | v2.10+ | Automated continuous reconciliation and self-healing |

---

## 4. Component Implementation Breakdown

### A. Application Setup
The application is a Python microservice with:
- `/health` endpoint for Kubernetes Liveness probes.
- `/ready` endpoint for Kubernetes Readiness probes.
- `/metrics` endpoint serving Prometheus-formatted metrics (`http_requests_total`, `http_request_duration_seconds`, `system_cpu_usage_percent`, `system_memory_usage_bytes`).
- `/api/v1/orders` endpoint handling transactional REST orders with schema validation.

### B. Docker Setup
- Multi-stage build separating builder compiler tools from the final slim runtime image.
- Enforces non-root execution (`USER 10001:10001`).
- Uses `.dockerignore` to minimize build context transfer times.

### C. Kubernetes Deployment
- **Deployment:** 3 replicas configured with RollingUpdate strategy (`maxSurge: 1`, `maxUnavailable: 0`).
- **Probes:** Liveness probe on port 80 with initial delay of 15 seconds; Readiness probe on port 80 with initial delay of 5 seconds.
- **SecurityContext:** `runAsNonRoot: true`, `readOnlyRootFilesystem: false`, `fsGroup: 10001`.
- **Storage:** Mounted PersistentVolumeClaim `order-platform-pvc` for transaction logging.
- **HPA:** Autoscales between 3 and 10 pods when CPU utilization crosses 60%.

### D. Helm Deployment
- Modular chart (`helm/devops-platform/`) with helpers, values, and environment files (`values-dev.yaml`, `values-prod.yaml`).
- Templated manifests for Deployment, Service, Ingress, HPA, PVC, ConfigMap, and Secret.

### E. Terraform Cloud Infrastructure
- Provisions custom VPC (`10.0.0.0/16`), Public Web Subnet (`10.0.1.0/24`), and Private DB Subnet (`10.0.2.0/24`).
- Deploys EC2 worker node with Amazon Linux 2023.
- Configures encrypted S3 assets bucket with versioning and public access blocking.

### F. CI/CD & DevSecOps Pipeline
- Automated GitHub Actions workflow covering:
  `Code -> Build -> Pytest -> SAST (Semgrep) -> SCA (pip-audit) -> Secret Scan (Gitleaks) -> Docker Build -> Container Scan (Trivy) -> Security Gate -> Push Image -> Helm Deploy`

### G. Monitoring & GitOps
- Prometheus scrape configuration and custom alert rules for High CPU, High Latency, and Replica degradation.
- Declarative ArgoCD application manifest configured with automated self-healing and drift remediation.

### H. Final Troubleshooting Challenge
- 4 production break-fix scenarios diagnosed and fixed:
  1. CrashLoopBackOff resolved by fixing missing encryption key mount.
  2. ImagePullBackOff resolved by correcting image semantic tag.
  3. Service 0 Endpoints resolved by matching Service selector with Pod template labels.
  4. PVC mount failure resolved by provisioning dynamic PersistentVolumeClaim.

---

## 5. Lessons Learned

1. **Shift Security Left:** Finding vulnerabilities during the CI phase with SAST and Trivy saves significant remediation cost compared to post-deployment patching.
2. **Immutable Infrastructure:** Managing cloud resources with Terraform eliminates configuration drift and ensures reproducible staging and production environments.
3. **Declarative GitOps Delivery:** In-cluster GitOps operators like ArgoCD provide automated self-healing and zero-downtime rollbacks, making deployments resilient against manual tampering.
4. **Resilient Health Probes:** Configuring appropriate initial delays and timeouts on liveness and readiness probes prevents premature container restarts during initialization.

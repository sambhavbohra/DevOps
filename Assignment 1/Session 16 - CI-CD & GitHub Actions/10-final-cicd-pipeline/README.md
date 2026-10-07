# Session 16: CI/CD & GitHub Actions (10-final-cicd-pipeline)

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## Core Concepts & Architectural Overview

Modern software engineering relies on automated delivery pipelines to ship high-quality features rapidly. This demo project implements an end-to-end CI/CD workflow using GitHub Actions.

### 1. CI vs CD

| Dimension | Continuous Integration (CI) | Continuous Delivery (CD) | Continuous Deployment (CD) |
| :--- | :--- | :--- | :--- |
| **Primary Goal** | Automatically build and test code on every commit | Automatically package and stage releases ready for deployment | Automatically push every passing build directly to production |
| **Trigger** | Git push / Pull Request | Merge to `main` or release branch | Automated trigger after all gates pass |
| **Key Activities** | Code linting, unit testing, SAST, artifact creation | Container image build, registry push, staging rollout | Automated zero-downtime production deployment |
| **Manual Gate** | None (fully automated) | Optional approval before production | Zero human intervention |

### 2. GitHub Actions Building Blocks
- **Workflows:** Configurable automated processes defined in YAML files located in `.github/workflows/`.
- **Events / Triggers:** Specific events that trigger workflow runs (`push`, `pull_request`, `workflow_dispatch`).
- **Jobs:** A set of sequential steps that execute on the same virtual runner. Jobs run in parallel by default, but dependencies can be declared with `needs: [job_name]`.
- **Steps:** Individual tasks within a job (either shell scripts or reusable marketplace actions).
- **Runners:** Virtual machines (`ubuntu-latest`, `windows-latest`, `macos-latest`) or self-hosted servers that execute jobs.
- **Secrets:** Encrypted environment variables (`${{ secrets.GITHUB_TOKEN }}`, `${{ secrets.DOCKER_PASSWORD }}`) for credentials.
- **Artifacts:** Persistent files (such as test reports, coverage stats, binary bundles) shared across jobs or downloaded post-run.

---

## Pipeline Architecture Diagram

```
 [ Developer Push to Git ]
            |
            v
 +-------------------------------------------------------------------+
 | 1. CI Job: lint-and-test                                          |
 |    - Checkout Code (actions/checkout@v4)                          |
 |    - Setup Node.js 20 (actions/setup-node@v4)                     |
 |    - npm install                                                  |
 |    - npm run lint                                                 |
 |    - npm test (Automated unit tests)                              |
 |    - Upload Test Artifact (actions/upload-artifact@v4)            |
 +-------------------------------------------------------------------+
            | (Passes)
            v
 +-------------------------------------------------------------------+
 | 2. CD Job: build-and-package                                      |
 |    - Setup Docker Buildx                                          |
 |    - Authenticate to Container Registry (ghcr.io)                 |
 |    - Build Multi-Stage Docker Image                               |
 |    - Tag with Git Commit SHA & latest                             |
 +-------------------------------------------------------------------+
            | (Passes)
            v
 +-------------------------------------------------------------------+
 | 3. CD Job: deploy-staging                                         |
 |    - Authenticate to Staging Kubeconfig Context                   |
 |    - Apply Kubernetes Deployment & Service Manifests              |
 |    - Validate Health Probes & Rollout                             |
 +-------------------------------------------------------------------+
            | (Passes)
            v
 +-------------------------------------------------------------------+
 | 4. CD Job: deploy-production (Production Environment Gate)        |
 |    - Apply Manifests to Production Namespace                      |
 |    - Zero-Downtime Rolling Update                                 |
 +-------------------------------------------------------------------+
```

---

## Project Structure

```
10-final-cicd-pipeline/
├── src/
│   ├── server.js               # Node.js HTTP microservice
│   └── server.test.js          # Automated unit test suite
├── package.json                # Dependencies and test scripts
├── Dockerfile                  # Multi-stage container definition
├── .dockerignore               # Build optimization filter
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # Complete CI/CD GitHub Actions workflow
├── k8s/
│   └── deployment.yaml         # Kubernetes deployment and service
└── README.md
```

---

## Local Execution & Validation

### 1. Execute Automated Test Suite
```bash
npm test
```
**Output:**
```
✔ Tax calculation - standard calculation (0.42ms)
✔ Tax calculation - zero tax rate (0.11ms)
✔ Tax calculation - invalid argument type throws error (0.19ms)
✔ Tax calculation - negative number throws error (0.15ms)
ℹ tests 4
ℹ suites 0
ℹ pass 4
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
ℹ duration_ms 42.12
```

### 2. Build Multi-Stage Docker Image
```bash
docker build -t cicd-demo-service:latest .
```
**Output:**
```
[+] Building 13.5s (11/11) FINISHED
 => [internal] load build definition from Dockerfile
 => [1/5] FROM docker.io/library/node:20-alpine
 => [2/5] WORKDIR /usr/src/app
 => [3/5] COPY package*.json ./
 => [4/5] RUN npm install --omit=dev
 => [5/5] COPY src/ ./src/
 => naming to docker.io/library/cicd-demo-service:latest
```

---

## Deliverables Summary
- Complete application source code and unit tests.
- Optimized Docker container definition.
- Production-grade multi-stage GitHub Actions workflow.
- Verified local and CI/CD execution evidence.

# Session 17: DevSecOps Complete CI/CD & Security Pipeline

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## Overview

DevSecOps embeds security testing directly into each phase of the Continuous Integration and Continuous Delivery lifecycle (shifting security left). Instead of waiting for penetration testing before production launch, automated static analysis, dependency vulnerability checking, secret detection, and container image scans execute automatically on every pull request and commit.

---

## 11-Stage DevSecOps Pipeline Flow

```
+---------------------------------------------------------------------------------------------------------------+
| Code -> Build -> Unit Test -> SAST -> SCA -> Secret Scan -> Docker Build -> Container Scan -> Gate -> Push -> Deploy |
+---------------------------------------------------------------------------------------------------------------+
```

### Stage Details

1. **Code:** Developers commit clean, modular Python application code adhering to secure coding standards.
2. **Build:** Dependencies and environment packages are installed in isolated runners.
3. **Unit Test:** Automated pytest suite executes validation checks against edge cases and injection attempts.
4. **SAST (Static Application Security Testing):** Semgrep analyzes application source code for code-level security anti-patterns without executing the code.
5. **SCA (Software Composition Analysis):** `pip-audit` inspects third-party libraries in `requirements.txt` against known CVE databases.
6. **Secret Scanning:** Gitleaks analyzes git history and working trees for accidentally committed high-entropy API keys, private certificates, or passwords.
7. **Docker Build:** Builds a hardened, multi-stage, non-root Linux container.
8. **Container Image Scan:** Aqua Security Trivy scans the compiled image for operating system package vulnerabilities and library CVEs.
9. **Security Gate:** Automated shell script enforces strict compliance thresholds (Zero Criticals, Maximum 2 Highs, Zero Leaked Secrets). If thresholds are violated, the pipeline halts immediately.
10. **Push Image:** Authenticated push of signed container images to GitHub Container Registry (`ghcr.io`).
11. **Deploy to Kubernetes:** Rolling rollout to Kubernetes cluster applying strict `securityContext` policies (dropping all Linux capabilities, read-only root filesystems, and non-root execution).

---

## Security Tools Configuration Reference

| Security Layer | Tool Utilized | Config File | Target & Purpose |
| :--- | :--- | :--- | :--- |
| **Secret Detection** | Gitleaks | `security-configs/.gitleaks.toml` | High-entropy regex checks for API keys & tokens |
| **SAST** | Semgrep | `security-configs/.semgrep.yml` | Code vulnerabilities (SQL injection, XSS, shell execution) |
| **SCA** | pip-audit / Safety | `requirements.txt` | Known CVEs in open source dependencies |
| **Container Scanning** | Trivy | `security-configs/trivy-config.yaml` | Base OS and layer CVE scanner |
| **Policy Gate** | Shell Script | `security-configs/security-gate.sh` | Automated pass/fail deployment policy enforcement |
| **Runtime Security** | K8s SecurityContext | `k8s/deployment.yaml` | Drop all Linux capabilities, readOnlyRootFilesystem |

---

## Verification & Execution Results

### 1. Pytest Unit Testing
```bash
pytest src/test_app.py -v
```
**Output:**
```
collected 5 items
src/test_app.py::test_health_check PASSED
src/test_app.py::test_validate_username_valid PASSED
src/test_app.py::test_validate_username_invalid_chars PASSED
src/test_app.py::test_validate_user_endpoint_success PASSED
src/test_app.py::test_validate_user_endpoint_bad_input PASSED

5 passed in 0.15s
```

### 2. Security Gate Execution
```bash
bash security-configs/security-gate.sh 0 0 0
```
**Output:**
```
====================================================
    DevSecOps Automated Quality & Security Gate     
====================================================
[*] Checking Critical Vulnerabilities: 0 (Allowed: 0)
[*] Checking High Vulnerabilities:     0 (Allowed: 2)
[*] Checking Secret Leaks:             0 (Allowed: 0)
[+] Security Gate PASSED: All security compliance standards met.
```

---

## Deliverables Summary
- Secure Python Flask application source code with test suite.
- Hardened multi-stage Dockerfile running as non-root user.
- Security tool configuration files (Gitleaks, Semgrep, Trivy).
- Automated security gate script.
- GitHub Actions DevSecOps workflow definition.
- Kubernetes manifests with Pod security standards.

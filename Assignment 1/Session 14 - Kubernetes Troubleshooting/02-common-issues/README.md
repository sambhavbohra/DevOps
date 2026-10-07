# Session 14: Task 2 - Kubernetes Common Issues & Troubleshooting Runbook

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## Overview

This directory contains individual practical labs, broken manifests, fixed manifests, and full step-by-step diagnostic workflows for the most common failure modes encountered in Kubernetes production environments.

---

## Troubleshooting Runbook Index

| Issue Category | Problem Indicator | Primary Root Cause | Solution Pattern | Subfolder |
| :--- | :--- | :--- | :--- | :--- |
| **CrashLoopBackOff** | Container exits with status > 0 repeatedly | Missing config files, bad startup command, uncaught exception | Fix application logic, mount prerequisites | [`01-crashloopbackoff/`](01-crashloopbackoff/) |
| **ImagePullBackOff / ErrImagePull** | Status `ImagePullBackOff` | Typo in image name/tag, private repo credentials missing | Fix image tag, configure `imagePullSecrets` | [`02-imagepullbackoff-errimagepull/`](02-imagepullbackoff-errimagepull/) |
| **Pending / Unschedulable** | Pod stays in `Pending` state | Insufficient CPU/Memory, node selector/affinity mismatch | Right-size requests, add cluster capacity | [`03-pending-unschedulable/`](03-pending-unschedulable/) |
| **ContainerCreating / Mount Failures** | Status `ContainerCreating` | Missing PVC, ConfigMap, or Secret volume source | Create missing dependencies before pod | [`04-containercreating-mountfailure/`](04-containercreating-mountfailure/) |
| **Service Connectivity** | Traffic cannot reach backend pods | Service selector does not match Pod labels | Align `spec.selector` with Pod labels | [`05-service-connectivity/`](05-service-connectivity/) |
| **DNS Resolution** | `NXDOMAIN` / `ENOTFOUND` | Querying wrong FQDN, CoreDNS degraded | Verify CoreDNS, use proper cluster domain | [`06-dns-issues/`](06-dns-issues/) |
| **Pod Networking** | Cross-pod traffic dropped | CNI plugin failure, NetworkPolicy blocking | Reinstall CNI, configure ingress policies | [`07-pod-networking/`](07-pod-networking/) |
| **Configuration Errors** | `CreateContainerConfigError` | Referenced key does not exist in ConfigMap/Secret | Fix key spelling in `valueFrom` references | [`08-configuration-issues/`](08-configuration-issues/) |

---

## Universal Troubleshooting 6-Step Method

Every issue in this runbook is systematically investigated using the standard 6-step lifecycle:
1. **Identify the Problem:** Detect failure through alerts, status codes, or `kubectl get`.
2. **Investigate:** Inspect logs, describe resources, and review cluster events.
3. **Find the Root Cause:** Pinpoint the underlying misconfiguration or hardware constraint.
4. **Fix It:** Update manifests, adjust limits, or repair dependencies.
5. **Verify the Solution:** Validate pods reach `Running` state and services route traffic.
6. **Document:** Capture commands, diffs, and preventative measures.

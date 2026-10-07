# Session 14: Task 3 - Kubernetes Troubleshooting Mini Project

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## Project Overview

In this comprehensive troubleshooting mini project, a multi-tier microservice stack (Frontend, API backend, Redis cache, and ClusterIP Service) was deployed with four intentional, realistic production failures. This document outlines the systematic investigation, root cause analysis, resolution, and verification process following the standard 6-step troubleshooting methodology.

---

## 1. Problem Statement

Upon applying the initial application deployment manifests (`broken-infrastructure.yaml`), multiple critical errors occurred across all tiers:
1. **Frontend Pods:** Stuck in `ErrImagePull` and `ImagePullBackOff`.
2. **API Backend Pods:** Stuck in `0/1 Running` with readiness probe failures, never receiving traffic.
3. **API Service:** Routing failed with zero active endpoints registered (`<none>`).
4. **Database Pod:** Blocked in `ContainerCreating` status due to a failed volume mount.

---

## 2. Investigation Steps

### Initial Cluster State (Before Fix)
```bash
kubectl apply -f broken-infrastructure.yaml
kubectl get pods,svc,endpoints
```

**Before Output:**
```
NAME                                READY   STATUS              RESTARTS   AGE
pod/api-service-64b9b85c74-bdvfn    0/1     Running             0          15s
pod/api-service-64b9b85c74-h42sk    0/1     Running             0          15s
pod/db-cache-pod                    0/1     ContainerCreating   0          15s
pod/frontend-app-5cf4c98ddb-67jsn   0/1     ErrImagePull        0          15s
pod/frontend-app-5cf4c98ddb-98ktw   0/1     ErrImagePull        0          15s

NAME                  TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/api-service   ClusterIP   10.96.226.93   <none>        80/TCP    15s

NAME                    ENDPOINTS           AGE
endpoints/api-service   <none>              15s
```

### Deep Dive Investigation per Tier

#### A. Investigating Frontend Failure
```bash
kubectl describe pod -l app=frontend-app
```
**Output Evidence:**
```
Events:
  Warning  Failed     kubelet  Failed to pull image "nginx:1.99.9-alpine-broken-tag": manifest not found
  Warning  Failed     kubelet  Error: ImagePullBackOff
```

#### B. Investigating API Readiness Failure
```bash
kubectl describe pod -l app=api-service
```
**Output Evidence:**
```
Events:
  Warning  Unhealthy  kubelet  Readiness probe failed: Get "http://10.244.0.35:9090/": dial tcp 10.244.0.35:9090: connect: connection refused
```

#### C. Investigating API Service Endpoints Mismatch
```bash
kubectl describe svc api-service
```
**Output Evidence:**
```
Selector:   app=wrong-api-tag
TargetPort: 80/TCP
Endpoints:  <none>
```

#### D. Investigating Database Cache Mount Failure
```bash
kubectl describe pod db-cache-pod
```
**Output Evidence:**
```
Events:
  Warning  FailedMount  kubelet  MountVolume.SetUp failed for volume "secret-data" : secret "missing-db-secret" not found
```

---

## 3. Root Cause Analysis

| Component | Error Observed | Root Cause |
| :--- | :--- | :--- |
| **Frontend Deployment** | `ImagePullBackOff` | Non-existent image tag `nginx:1.99.9-alpine-broken-tag` in Docker registry |
| **API Deployment** | `0/1 Running` (Unhealthy) | Readiness probe pointing to TCP port 9090 while container listens on port 80 |
| **API Service** | `<none>` Endpoints | Selector `app: wrong-api-tag` did not match Pod label `app: api-service` |
| **DB Cache Pod** | `ContainerCreating` | Pod definition mounts Secret `missing-db-secret` which was never created in cluster |

---

## 4. Remediation and Solutions

1. **Fix Image Tag:** Updated `frontend-app` container image to `nginx:alpine`.
2. **Fix Readiness Probe:** Changed `readinessProbe.httpGet.port` to `80`.
3. **Fix Service Selector:** Updated `spec.selector` in `api-service` to `app: api-service`.
4. **Provision Missing Secret:** Created Secret manifest `missing-db-secret` containing base64 encoded credentials prior to mounting.

All fixes were integrated into `fixed-infrastructure.yaml`.

---

## 5. Verification (After Fix)

```bash
kubectl apply -f fixed-infrastructure.yaml
kubectl get pods,svc,endpoints
```

**After Output:**
```
NAME                                READY   STATUS    RESTARTS   AGE
pod/api-service-7dbfb4789-nnmsp     1/1     Running   0          45s
pod/api-service-7dbfb4789-zmnvf     1/1     Running   0          45s
pod/db-cache-pod                    1/1     Running   0          30s
pod/frontend-app-7987cd6cc4-lqpqw   1/1     Running   0          45s
pod/frontend-app-7987cd6cc4-pmhg8   1/1     Running   0          38s

NAME                  TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/api-service   ClusterIP   10.96.226.93   <none>        80/TCP    1m

NAME                    ENDPOINTS                       AGE
endpoints/api-service   10.244.0.40:80,10.244.0.42:80   1m
```

---

## 6. Preventative Best Practices

- **Linting & Validation:** Use `kubeconform` or `kubeval` in CI pipelines to catch schema errors before deployment.
- **Image Pinning:** Use immutable image digests (`sha256:...`) or verified semantic tags.
- **Helm / Kustomize:** Parameterize selectors and ports to prevent copy-paste configuration drift.

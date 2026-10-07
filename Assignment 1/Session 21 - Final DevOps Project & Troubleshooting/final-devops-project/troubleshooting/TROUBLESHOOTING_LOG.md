# Session 21: Final Troubleshooting Challenge Runbook

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## Overview

As part of the Capstone DevOps project, four production-grade break-fix failure scenarios were intentionally simulated across the application, cluster networking, storage, and container runtime layers. This document details the complete 6-step troubleshooting methodology applied to identify, diagnose, and remediate each failure.

---

## Incident 1: Microservice CrashLoopBackOff on Startup

### 1. Identify Problem
Following deployment of `01-crashloop-broken-config.yaml`, the pods repeatedly enter `Error` state with restart count increasing rapidly.

### 2. Investigate
```bash
kubectl get pods -l app=order-platform
kubectl logs deployment/order-platform-deployment --previous
```
**Log Output:**
```
FileNotFoundError: [Errno 2] No such file or directory: '/nonexistent/secret/encryption.key'
```

### 3. Root Cause
The container entrypoint attempted to read an encryption key file from `/nonexistent/secret/encryption.key` which was neither mounted from a Kubernetes Secret nor present in the container image filesystem.

### 4. Fix Issue
Updated configuration in `01-crashloop-fixed.yaml` to read the key from the mounted Secret volume `/etc/secrets/key` and added graceful fallback handling.

### 5. Verify Solution
```bash
kubectl apply -f 01-crashloop-fixed.yaml
kubectl get pods -l app=order-platform
```
**Output:**
```
NAME                                          READY   STATUS    RESTARTS   AGE
order-platform-deployment-78f99d8b7-2hk9s     1/1     Running   0          30s
order-platform-deployment-78f99d8b7-8qzp1     1/1     Running   0          30s
order-platform-deployment-78f99d8b7-w91xk     1/1     Running   0          30s
```

---

## Incident 2: ImagePullBackOff / ErrImagePull

### 1. Identify Problem
New release rollout stalls indefinitely. Pods report `ErrImagePull` followed by `ImagePullBackOff`.

### 2. Investigate
```bash
kubectl describe pod -l app=order-platform
```
**Events Output:**
```
Events:
  Warning  Failed   kubelet  Failed to pull image "ghcr.io/sambhavbohra/order-processing-platform:v9.9.9-nonexistent": manifest unknown
```

### 3. Root Cause
The Helm deployment values referenced a non-existent semantic image tag `v9.9.9-nonexistent` rather than the verified build tag `2.5.0`.

### 4. Fix Issue
Corrected image tag in `02-imagepullbackoff-fixed.yaml` to `sambhavbohra/order-processing-platform:2.5.0`.

### 5. Verify Solution
Kubelet pulls the valid image successfully and pods transition immediately to `Running`.

---

## Incident 3: Ingress / Service Connectivity Failure (0 Endpoints)

### 1. Identify Problem
External HTTP requests to `http://orders.scaler.internal` return `503 Service Temporarily Unavailable`.

### 2. Investigate
```bash
kubectl get endpoints order-platform-service
kubectl describe svc order-platform-service | grep Selector
```
**Output:**
```
NAME                     ENDPOINTS   AGE
order-platform-service   <none>      5m

Selector: app=wrong-order-tag
```

### 3. Root Cause
The Service selector was configured with `app: wrong-order-tag`, which did not match the Pod template label `app: order-platform`.

### 4. Fix Issue
Updated `spec.selector` to `app: order-platform` in `03-service-selector-mismatch-fixed.yaml`.

### 5. Verify Solution
```bash
kubectl get endpoints order-platform-service
```
**Output:**
```
NAME                     ENDPOINTS                                               AGE
order-platform-service   10.244.0.51:8080,10.244.0.52:8080,10.244.0.53:8080     15s
```

---

## Incident 4: PVC Dynamic Storage Mount Failure

### 1. Identify Problem
Pods remain stuck in `ContainerCreating` status without starting the application container.

### 2. Investigate
```bash
kubectl describe pod -l app=order-platform
```
**Events Output:**
```
Events:
  Warning  FailedMount  kubelet  MountVolume.SetUp failed for volume "transaction-logs" : persistentvolumeclaim "nonexistent-order-pvc" not found
```

### 3. Root Cause
The Pod specification mounted a volume named `transaction-logs` bound to `claimName: nonexistent-order-pvc` which was never defined in the cluster namespace.

### 4. Fix Issue
Created the PersistentVolumeClaim `order-platform-pvc` and bound it correctly to the deployment in `04-pvc-mount-failure-fixed.yaml`.

### 5. Verify Solution
The dynamic storage class provisioner bound a 1Gi volume, and all 3 pods started successfully.

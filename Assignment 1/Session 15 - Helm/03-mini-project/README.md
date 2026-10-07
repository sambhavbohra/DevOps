# Session 15: Task 3 - Enterprise Helm Chart Mini Project

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## Project Overview

This mini project delivers a fully parameterized, production-ready Helm chart (`ecommerce-web`) designed for modern microservice architectures. The chart features dynamic templating for Deployments, ClusterIP Services, NGINX Ingress, HorizontalPodAutoscalers, PersistentVolumeClaims, ConfigMaps, and Secrets, supporting seamless multi-environment deployments (Development, Staging, and Production).

---

## Chart Architecture & Features

```
ecommerce-chart/
├── Chart.yaml              # Chart metadata and versioning
├── values.yaml             # Base / default configuration parameters
├── values-dev.yaml         # Lightweight dev overrides (1 replica, no Ingress/HPA)
├── values-prod.yaml        # High-availability production overrides (4+ replicas, HPA, Ingress)
└── templates/
    ├── _helpers.tpl        # Standardized naming and label helpers
    ├── deployment.yaml     # Application deployment with probes and volume mounts
    ├── service.yaml        # Service definition
    ├── ingress.yaml        # Ingress routing rules (conditional)
    ├── hpa.yaml            # Autoscaling policies (conditional)
    ├── pvc.yaml            # Persistent storage claim (conditional)
    ├── configmap.yaml      # Environment configuration variables
    ├── secret.yaml         # Encrypted credentials
    └── NOTES.txt           # Post-installation CLI instructions
```

---

## Multi-Environment Deployment Guide

### 1. Linting the Chart
Ensure all templates and values adhere to Helm standards:
```bash
helm lint ./ecommerce-chart
```
**Output:**
```
==> Linting ./ecommerce-chart
1 chart(s) linted, 0 chart(s) failed
```

### 2. Deploying Staging Environment (Default Values)
```bash
helm install ecommerce-staging ./ecommerce-chart
```

**Verification:**
```bash
kubectl get pods,svc,hpa,ingress,pvc -l app.kubernetes.io/instance=ecommerce-staging
```
**Output:**
```
NAME                                                  READY   STATUS    RESTARTS   AGE
pod/ecommerce-staging-ecommerce-web-7df4dd6f8-lwc44   1/1     Running   0          45s
pod/ecommerce-staging-ecommerce-web-7df4dd6f8-tjfmq   1/1     Running   0          45s

NAME                                         TYPE        CLUSTER-IP      PORT(S)   AGE
service/ecommerce-staging-ecommerce-web      ClusterIP   10.96.250.232   80/TCP    45s

NAME                                                                     REFERENCE                                       TARGETS         MINPODS   MAXPODS
horizontalpodautoscaler.autoscaling/ecommerce-staging-ecommerce-web       Deployment/ecommerce-staging-ecommerce-web     cpu: 0%/50%     2         6

NAME                                                            CLASS   HOSTS             PORTS
ingress.networking.k8s.io/ecommerce-staging-ecommerce-web       nginx   ecommerce.local   80

NAME                                                            STATUS   VOLUME                                     CAPACITY
persistentvolumeclaim/ecommerce-staging-ecommerce-web-pvc       Bound    pvc-d3e4d9a5-e7cb-4bca-9f4b-e80e330292d3   1Gi
```

### 3. Deploying to Production with Overrides
```bash
helm upgrade --install ecommerce-prod ./ecommerce-chart -f ./ecommerce-chart/values-prod.yaml --namespace production --create-namespace
```

### 4. Rollback in Production
If a production deployment introduces regressions:
```bash
helm rollback ecommerce-prod 1 --namespace production
```

---

## Deliverables Summary
- Enterprise Helm chart with modular templates.
- Environment-specific override files (`values-dev.yaml`, `values-prod.yaml`).
- Zero-downtime rolling upgrades and instant rollback capabilities.

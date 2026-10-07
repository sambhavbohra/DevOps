# Session 13: Task 3 - Storage, Autoscaling & Health Probes Mini Project

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## Project Overview

This mini project demonstrates an end-to-end production-grade Kubernetes deployment pattern combining:
1. **Persistent Volume Claims (PVC):** Dynamically provisioned storage volume for application logging and state.
2. **Health Probes:** Liveness probes to detect and restart frozen containers, and Readiness probes to ensure zero-downtime routing during startup.
3. **Horizontal Pod Autoscaler (HPA v2):** Multi-metric autoscaling based on both CPU utilization (50% target) and Memory utilization (75% target).
4. **Resilient Rolling Updates:** Zero downtime rolling update strategy with maxUnavailable set to 0.

---

## Architecture Diagram

```
                              [ Ingress / External Traffic ]
                                             |
                                             v
                                  [ ClusterIP Service ]
                                   (Port 80 -> Target 80)
                                             |
                     +-----------------------+-----------------------+
                     |                                               |
                     v                                               v
          +-----------------------+                       +-----------------------+
          |  order-service Pod 1  |                       |  order-service Pod 2  |
          |  - Liveness Probe     |                       |  - Liveness Probe     |
          |  - Readiness Probe    |                       |  - Readiness Probe    |
          |  - Resource Limits    |                       |  - Resource Limits    |
          +-----------------------+                       +-----------------------+
                     |                                               |
                     +-----------------------+-----------------------+
                                             |
                                             v
                           +-----------------------------------+
                           |  order-service-storage-pvc (1Gi)  |
                           |  Dynamic Persistent Storage       |
                           +-----------------------------------+
```

---

## Component Manifests

### 1. PersistentVolumeClaim (`pvc.yaml`)
Requests a 1Gi volume with ReadWriteOnce access mode. The storage provisioner automatically creates and binds a backing PersistentVolume.

### 2. Microservice Deployment (`app-deployment.yaml`)
Deploys 2 initial replicas of the backend service with:
- Container resource requests: CPU 100m, Memory 64Mi.
- Container resource limits: CPU 500m, Memory 256Mi.
- Volume mount at `/var/log/order-service`.
- Liveness probe configured with `initialDelaySeconds: 15`, `periodSeconds: 10`.
- Readiness probe configured with `initialDelaySeconds: 5`, `periodSeconds: 5`.

### 3. Service Definition (`service.yaml`)
Provides internal cluster load balancing across all active, ready pods selected by `app: order-service`.

### 4. HorizontalPodAutoscaler (`hpa.yaml`)
Scales the workload dynamically between a minimum of 2 pods and a maximum of 8 pods based on CPU and memory thresholds.

---

## Deployment and Verification Steps

### Step 1: Deploy All Manifests
```bash
kubectl apply -f pvc.yaml
kubectl apply -f app-deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f hpa.yaml
```

**Output:**
```
persistentvolumeclaim/order-service-storage-pvc created
deployment.apps/order-service created
service/order-service created
horizontalpodautoscaler.autoscaling/order-service-hpa created
```

### Step 2: Verify PVC Binding
```bash
kubectl get pvc
```

**Output:**
```
NAME                        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
order-service-storage-pvc   Bound    pvc-a76facf5-938d-4176-80c5-3136184ee4b3   1Gi        RWO            standard       15s
```

### Step 3: Verify Pod Health and Probes
```bash
kubectl get pods -l app=order-service
```

**Output:**
```
NAME                             READY   STATUS    RESTARTS   AGE
order-service-6f87b8849c-q8kc8   1/1     Running   0          30s
order-service-6f87b8849c-xrd2m   1/1     Running   0          30s
```

### Step 4: Run Load Test and Validate Autoscaling
```bash
kubectl apply -f load-generator.yaml
kubectl get hpa
```

**Output:**
```
NAME                REFERENCE                  TARGETS               MINPODS   MAXPODS   REPLICAS   AGE
order-service-hpa   Deployment/order-service   cpu: 68%/50%, 68%/75% 2         8         4          2m
```

---

## Key Benefits Realized

- **Data Safety:** Persistent storage ensures transaction logs survive container failures and restarts.
- **Traffic Protection:** Readiness probes prevent incomplete or failing pods from receiving production traffic.
- **Cost and Performance Optimization:** HPA automatically scales computing power during peak traffic and saves resources during lulls.

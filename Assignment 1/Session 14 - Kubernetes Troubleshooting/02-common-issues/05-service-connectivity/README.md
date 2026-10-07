# Troubleshooting: Service Connectivity & Endpoint Mismatch

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## 1. Problem Statement
Pods are healthy and running, but curl requests sent to `http://backend-service` fail with `Connection refused` or timeout.

---

## 2. Investigation Steps

### Step 1: Verify Pod Health
```bash
kubectl get pods -l app=backend-app
```
**Output:**
```
NAME                          READY   STATUS    RESTARTS   AGE
backend-app-567c9c849-5gqw9   1/1     Running   0          2m
backend-app-567c9c849-p8zk2   1/1     Running   0          2m
```

### Step 2: Check Service Endpoints
```bash
kubectl get endpoints backend-service
```
**Output:**
```
NAME              ENDPOINTS   AGE
backend-service   <none>      2m
```

### Step 3: Compare Service Selector and Pod Labels
```bash
kubectl describe svc backend-service | grep Selector
kubectl get pods --show-labels
```
**Output:**
```
Selector:          app=wrong-backend-label
Pod Labels:        app=backend-app
```

---

## 3. Root Cause
The Service definition specifies `selector: app=wrong-backend-label`, which does not match the actual pod label `app: backend-app`. Because no pods match the selector, the Kubernetes endpoint controller registers zero backend IP addresses, leaving the service without any route to traffic.

---

## 4. Solution
Update the Service manifest `spec.selector` to match the exact labels declared in the Deployment pod template (`app: backend-app`).

Apply the corrected configuration in `fixed-service.yaml`.

---

## 5. Verification
```bash
kubectl apply -f fixed-service.yaml
kubectl get endpoints backend-service
```
**Output:**
```
NAME              ENDPOINTS                               AGE
backend-service   10.244.0.18:80,10.244.0.19:80          10s
```
Internal curl requests to `http://backend-service:80` return HTTP 200 responses immediately.

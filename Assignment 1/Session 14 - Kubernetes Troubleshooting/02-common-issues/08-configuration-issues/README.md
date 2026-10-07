# Troubleshooting: Configuration Errors & CreateContainerConfigError

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## 1. Problem Statement
The Pod `payment-app-broken` fails to start and is stuck in `CreateContainerConfigError`.

---

## 2. Investigation Steps

### Step 1: Check Pod Status
```bash
kubectl get pods
```
**Output:**
```
NAME                 READY   STATUS                         RESTARTS   AGE
payment-app-broken   0/1     CreateContainerConfigError     0          35s
```

### Step 2: Describe Pod Events
```bash
kubectl describe pod payment-app-broken
```
**Output:**
```
Events:
  Type     Reason     Age                From     Message
  ----     ------     ----               ----     -------
  Normal   Scheduled  40s                default  Successfully assigned default/payment-app-broken to minikube
  Warning  Failed     10s (x5 over 40s)  kubelet  Error: configmap "payment-app-config" key "WRONG_PORT_KEY" does not exist
```

---

## 3. Root Cause
The Pod template references key `WRONG_PORT_KEY` in ConfigMap `payment-app-config`. However, the ConfigMap only defines keys `SERVICE_PORT` and `DATABASE_NAME`. Kubelet cannot construct the container environment variables.

---

## 4. Solution
Update the `configMapKeyRef.key` in the Pod definition to match the existing key `SERVICE_PORT`.

Apply the corrected configuration in `fixed-config.yaml`.

---

## 5. Verification
```bash
kubectl apply -f fixed-config.yaml
kubectl logs payment-app-fixed
```
**Output:**
```
Payment service listening on port 8080
```

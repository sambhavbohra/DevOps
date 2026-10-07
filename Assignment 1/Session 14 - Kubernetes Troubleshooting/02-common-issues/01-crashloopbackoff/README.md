# Troubleshooting: CrashLoopBackOff

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## 1. Problem Statement
The Pod `crashloop-demo-broken` starts up but immediately terminates. Kubernetes enters a restart back-off loop with status `CrashLoopBackOff`, and restart counts increase continuously.

---

## 2. Investigation Steps

### Step 1: Check Pod Status
```bash
kubectl get pods
```
**Output:**
```
NAME                    READY   STATUS             RESTARTS      AGE
crashloop-demo-broken   0/1     CrashLoopBackOff   4 (45s ago)   2m
```

### Step 2: Describe Pod Events and Container Exit Code
```bash
kubectl describe pod crashloop-demo-broken
```
**Output:**
```
State:          Waiting
  Reason:       CrashLoopBackOff
Last State:     Terminated
  Reason:       Error
  Exit Code:    1
Events:
  Warning  BackOff  kubelet  Back-off restarting failed container
```

### Step 3: Inspect Logs of the Crashing Container
```bash
kubectl logs crashloop-demo-broken --previous
```
**Output:**
```
cat: can't open '/nonexistent/config.json': No such file or directory
```

---

## 3. Root Cause
The container command attempts to read a mandatory configuration file `/nonexistent/config.json` that is not mounted or present in the container image. The shell command exits with error code 1, triggering Kubernetes to restart the container in an exponential back-off cycle.

---

## 4. Solution
Update the container startup script to verify prerequisites or supply the required configuration via ConfigMap or file mount, ensuring the primary container process remains active.

Apply the fixed manifest in `fixed.yaml`.

---

## 5. Verification
```bash
kubectl apply -f fixed.yaml
kubectl get pods -l app=crashloop-demo
```
**Output:**
```
NAME                   READY   STATUS    RESTARTS   AGE
crashloop-demo-fixed   1/1     Running   0          25s
```
Container logs show successful continuous execution:
```
[Wed Oct 7 07:40:00 UTC 2026] Application is healthy and executing successfully
```

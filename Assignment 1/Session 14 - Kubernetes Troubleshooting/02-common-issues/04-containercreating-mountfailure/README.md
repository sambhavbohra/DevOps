# Troubleshooting: ContainerCreating / Volume Mount Failures

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## 1. Problem Statement
The Pod `containercreating-demo-broken` is scheduled onto a node but remains stuck in the `ContainerCreating` status without progressing to `Running`.

---

## 2. Investigation Steps

### Step 1: Check Pod Status
```bash
kubectl get pods
```
**Output:**
```
NAME                           READY   STATUS              RESTARTS   AGE
containercreating-demo-broken  0/1     ContainerCreating   0          2m
```

### Step 2: Describe Pod and Check Mount Events
```bash
kubectl describe pod containercreating-demo-broken
```
**Output:**
```
Events:
  Type     Reason       Age                From     Message
  ----     ------       ----               ----     -------
  Normal   Scheduled    2m                 default  Successfully assigned default/containercreating-demo-broken to minikube
  Warning  FailedMount  10s (x8 over 2m)   kubelet  MountVolume.SetUp failed for volume "missing-config-vol" : configmap "app-nonexistent-config" not found
```

---

## 3. Root Cause
Kubelet cannot start the container because a volume dependency (ConfigMap `app-nonexistent-config`) referenced under `volumes` does not exist in the cluster namespace. Until all volume mounts are verified and resolved, container creation is blocked.

---

## 4. Solution
Create the missing ConfigMap or Secret resource, or update the pod volume configuration to reference existing valid cluster resources.

Apply the corrected configuration in `fixed.yaml`.

---

## 5. Verification
```bash
kubectl apply -f fixed.yaml
kubectl get pods -l app=mount-demo
```
**Output:**
```
NAME                          READY   STATUS    RESTARTS   AGE
containercreating-demo-fixed  1/1     Running   0          15s
```
Volume is mounted and the container initializes smoothly.

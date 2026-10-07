# Troubleshooting: Pending / Unschedulable Pods

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## 1. Problem Statement
The Pod `pending-demo-broken` is created but never runs. Its status remains stuck in `Pending` indefinitely without getting assigned to any node.

---

## 2. Investigation Steps

### Step 1: Check Pod Status
```bash
kubectl get pods -o wide
```
**Output:**
```
NAME                  READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE
pending-demo-broken   0/1     Pending   0          2m    <none>   <none>   <none>
```

### Step 2: Describe Pod and Check Scheduler Events
```bash
kubectl describe pod pending-demo-broken
```
**Output:**
```
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  45s   default-scheduler  0/1 nodes are available: 1 Insufficient cpu, 1 Insufficient memory. preemption: 0/1 nodes are available: 1 No preemption victims found for incoming pod.
```

---

## 3. Root Cause
The Pod specifies resource requests of `cpu: 128` and `memory: 500Gi`. The Kubernetes default scheduler evaluates cluster node capacities and finds zero nodes possessing the required unallocated CPU and RAM.

---

## 4. Solution
Right-size the container resource requests based on actual application workload profiling, or add additional worker nodes / configure Cluster Autoscaler.

Apply the corrected configuration in `fixed.yaml`.

---

## 5. Verification
```bash
kubectl apply -f fixed.yaml
kubectl get pods -l app=pending-demo
```
**Output:**
```
NAME                 READY   STATUS    RESTARTS   AGE
pending-demo-fixed   1/1     Running   0          12s
```
Scheduler assigns the pod to an available node immediately.

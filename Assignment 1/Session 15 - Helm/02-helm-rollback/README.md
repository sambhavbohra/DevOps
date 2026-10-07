# Session 15: Task 2 - Complete Helm Rollback Workflow

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## Objective

This exercise demonstrates the complete lifecycle of rolling deployments and rollbacks in Helm. In production, bad application builds or configuration drifts can break running services. Helm maintains an immutable ledger of release revisions in cluster secrets, enabling zero-downtime rollbacks to previous known good states.

---

## Rollback Lifecycle Flow

```
+-----------------------------------------------------------------------------------------------+
| 1. Install (Rev 1) -> 2. Upgrade (Rev 2) -> 3. Broken Upgrade (Rev 3) -> 4. Rollback to Rev 2 |
|    (v1.25, 2 reps)     (v1.26, 3 reps)      (invalid-tag, failing)      (v1.26, 3 reps)       |
+-----------------------------------------------------------------------------------------------+
```

---

## Detailed Step-by-Step Execution

### Step 1: Initial Installation (Revision 1)
Deploy the initial application chart with image `nginx:1.25.0` and replica count of 2:

```bash
helm install rollback-demo ./sample-app-chart --set image.tag=1.25.0 --set replicaCount=2
```

**Output:**
```
NAME: rollback-demo
LAST DEPLOYED: Wed Oct  7 13:18:38 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
```

### Step 2: First Upgrade to Stable Version (Revision 2)
Upgrade the application to image `nginx:1.26.0` and scale to 3 replicas:

```bash
helm upgrade rollback-demo ./sample-app-chart --set image.tag=1.26.0 --set replicaCount=3
```

**Output:**
```
Release "rollback-demo" has been upgraded. Happy Helming!
NAME: rollback-demo
STATUS: deployed
REVISION: 2
DESCRIPTION: Upgrade complete
```

### Step 3: Verify Revision 2
```bash
helm history rollback-demo
```

**Output:**
```
REVISION   UPDATED                  STATUS       CHART            APP VERSION  DESCRIPTION     
1          Wed Oct  7 13:18:38 2026 superseded   sample-app-0.1.0 1.0.0        Install complete
2          Wed Oct  7 13:18:41 2026 deployed     sample-app-0.1.0 1.0.0        Upgrade complete
```

### Step 4: Deploy Faulty Upgrade (Revision 3)
Simulate a buggy deployment by pushing an invalid non-existent image tag `invalid-broken-tag`:

```bash
helm upgrade rollback-demo ./sample-app-chart --set image.tag=invalid-broken-tag --set replicaCount=3
```

**Output:**
```
Release "rollback-demo" has been upgraded. Happy Helming!
NAME: rollback-demo
STATUS: deployed
REVISION: 3
DESCRIPTION: Upgrade complete
```

### Step 5: Verify Faulty State
Pods enter `ErrImagePull` / `ImagePullBackOff` state. Review revision history:

```bash
helm history rollback-demo
```

**Output:**
```
REVISION   UPDATED                  STATUS       CHART            APP VERSION  DESCRIPTION     
1          Wed Oct  7 13:18:38 2026 superseded   sample-app-0.1.0 1.0.0        Install complete
2          Wed Oct  7 13:18:41 2026 superseded   sample-app-0.1.0 1.0.0        Upgrade complete
3          Wed Oct  7 13:18:45 2026 deployed     sample-app-0.1.0 1.0.0        Upgrade complete
```

### Step 6: Execute Rollback to Stable Revision 2
Revert cluster state back to the healthy Revision 2:

```bash
helm rollback rollback-demo 2
```

**Output:**
```
Rollback was a success! Happy Helming!
```

### Step 7: Final Verification of Restored State
Check history to verify that Revision 4 was generated referencing Revision 2:

```bash
helm history rollback-demo
```

**Output:**
```
REVISION   UPDATED                  STATUS       CHART            APP VERSION  DESCRIPTION     
1          Wed Oct  7 13:18:38 2026 superseded   sample-app-0.1.0 1.0.0        Install complete
2          Wed Oct  7 13:18:41 2026 superseded   sample-app-0.1.0 1.0.0        Upgrade complete
3          Wed Oct  7 13:18:45 2026 superseded   sample-app-0.1.0 1.0.0        Upgrade complete
4          Wed Oct  7 13:18:48 2026 deployed     sample-app-0.1.0 1.0.0        Rollback to 2   
```

```bash
kubectl get pods -l app.kubernetes.io/name=sample-app
```

**Output:**
```
NAME                                        READY   STATUS    RESTARTS   AGE
rollback-demo-sample-app-58b455b54f-5thhj   1/1     Running   0          45s
rollback-demo-sample-app-58b455b54f-rsszd   1/1     Running   0          45s
rollback-demo-sample-app-58b455b54f-zk92m   1/1     Running   0          40s
```

All 3 pods are back to `1/1 Running` on the stable image.

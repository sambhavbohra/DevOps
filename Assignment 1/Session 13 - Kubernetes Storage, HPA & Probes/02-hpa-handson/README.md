# Session 13: Task 2 - Horizontal Pod Autoscaler (HPA) Hands-on

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## Objective

The objective of this hands-on exercise is to configure and test the Kubernetes Horizontal Pod Autoscaler (HPA v2). We deploy a sample CPU-intensive application (`php-apache`), establish resource requests and limits, attach an HPA resource targeting 50% average CPU utilization, generate artificial HTTP load, and observe Kubernetes automatically scaling pods up to handle demand and back down when idle.

---

## Step-by-Step Implementation

### Step 1: Deploy Application and HPA
The manifest `hpa.yml` defines the Deployment, ClusterIP Service, and HorizontalPodAutoscaler.

```bash
kubectl apply -f hpa.yml
```

**Output:**
```
deployment.apps/php-apache created
service/php-apache created
horizontalpodautoscaler.autoscaling/php-apache-hpa created
```

### Step 2: Verify Initial Cluster State
Initially, there is a single replica running with baseline CPU consumption:

```bash
kubectl get hpa
kubectl get pods
```

**Output:**
```
NAME             REFERENCE               TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
php-apache-hpa   Deployment/php-apache   cpu: 0%/50%     1         10        1          30s

NAME                          READY   STATUS    RESTARTS   AGE
php-apache-59d98c65fd-wpf6h   1/1     Running   0          30s
```

### Step 3: Deploy the Load Generator
We deploy a busybox load generator that continuously issues HTTP GET requests to `http://php-apache` in an infinite loop:

```bash
kubectl apply -f load-generator.yaml
```

**Output:**
```
deployment.apps/load-generator created
```

### Step 4: Monitor CPU Utilization and Autoscaling in Real Time
As the load generator queries the `php-apache` endpoint, the container CPU utilization increases rapidly above the 50% target threshold:

```bash
kubectl top pods
```

**Output:**
```
NAME                             CPU(cores)   MEMORY(bytes)   
load-generator-cbfd97f4f-cqvss   6m           3Mi             
php-apache-59d98c65fd-wpf6h      500m         40Mi            
```

### Step 5: Observe HPA Scaling Out Pods
Within 15 to 30 seconds of high CPU load, the HPA controller triggers automated scale-out events:

```bash
kubectl get hpa
```

**Output:**
```
NAME             REFERENCE               TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
php-apache-hpa   Deployment/php-apache   cpu: 500%/50%   1         10        4          2m48s
```

```bash
kubectl get pods
```

**Output:**
```
NAME                             READY   STATUS    RESTARTS   AGE
load-generator-cbfd97f4f-cqvss   1/1     Running   0          2m27s
php-apache-59d98c65fd-2bmvl      1/1     Running   0          3s
php-apache-59d98c65fd-5kd54      1/1     Running   0          3s
php-apache-59d98c65fd-c7z5w      1/1     Running   0          18s
php-apache-59d98c65fd-dwzmh      1/1     Running   0          33s
php-apache-59d98c65fd-f26xz      1/1     Running   0          18s
php-apache-59d98c65fd-l4gsp      1/1     Running   0          3s
php-apache-59d98c65fd-q2frh      1/1     Running   0          3s
php-apache-59d98c65fd-wpf6h      1/1     Running   0          2m48s
```

### Step 6: Detailed HPA Controller Events Inspection

```bash
kubectl describe hpa php-apache-hpa
```

**Output:**
```
Name:                                                  php-apache-hpa
Namespace:                                             default
Labels:                                                <none>
Annotations:                                           <none>
CreationTimestamp:                                     Wed, 07 Oct 2026 12:58:51 +0530
Reference:                                             Deployment/php-apache
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  500% (500m) / 50%
Min replicas:                                          1
Max replicas:                                          10
Behavior:
  Scale Up:
    Stabilization Window: 0 seconds
    Select Policy: Max
    Policies:
      - Type: Percent  Value: 100  Period: 15 seconds
  Scale Down:
    Stabilization Window: 60 seconds
    Select Policy: Max
    Policies:
      - Type: Percent  Value: 50  Period: 30 seconds
Deployment pods:       4 current / 8 desired
Conditions:
  Type            Status  Reason            Message
  ----            ------  ------            -------
  AbleToScale     True    SucceededRescale  the HPA controller was able to update the target scale to 8
  ScalingActive   True    ValidMetricFound  the HPA was able to successfully calculate a replica count
Events:
  Type     Reason             Age   From                       Message
  ----     ------             ----  ----                       -------
  Normal   SuccessfulRescale  33s   horizontal-pod-autoscaler  New size: 2; reason: cpu resource utilization above target
  Normal   SuccessfulRescale  18s   horizontal-pod-autoscaler  New size: 4; reason: cpu resource utilization above target
  Normal   SuccessfulRescale  3s    horizontal-pod-autoscaler  New size: 8; reason: cpu resource utilization above target
```

---

## Key Learnings

1. **Resource Requests are Mandatory:** HPA cannot compute percentage-based targets if container `resources.requests.cpu` is omitted.
2. **Metrics Server Dependency:** HPA queries the `metrics.k8s.io` API aggregator powered by Kubernetes `metrics-server`.
3. **Stabilization Windows:** Custom behavior rules prevent flapping (rapid scaling up and down) by enforcing configurable stabilization periods.

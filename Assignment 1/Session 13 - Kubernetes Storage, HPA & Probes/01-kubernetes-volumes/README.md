# Session 13: Task 1 - Kubernetes Volumes and Storage

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## Overview

In Kubernetes, containers inside pods are ephemeral by design. When a container crashes or restarts, all data written inside its local filesystem is permanently lost. To solve this challenge and provide data persistence and sharing, Kubernetes offers a comprehensive volume and storage architecture.

This documentation explores the core storage concepts in Kubernetes, explaining how each works with practical examples and use cases.

---

## 1. emptyDir

### What is emptyDir?
An `emptyDir` volume is created when a Pod is assigned to a Node and exists as long as that Pod is running on that node. All containers in the Pod can read and write the same files in the `emptyDir` volume. When a Pod is removed from a node for any reason, the data in the `emptyDir` is deleted permanently.

### Practical Use Cases
- Scratch space for disk-based sorting, caching, or temporary file processing.
- Checkpointing long computations for recovery from crashes.
- Sharing data between co-located containers in a multi-container pod (such as a web server and a content-fetching sidecar).

### YAML Example
Refer to `01-emptydir-pod.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-demo-pod
spec:
  containers:
  - name: writer-container
    image: busybox:1.36
    command: ["/bin/sh", "-c"]
    args:
      - while true; do date >> /shared-data/timestamp.log; sleep 5; done
    volumeMounts:
    - name: shared-storage
      mountPath: /shared-data
  - name: reader-container
    image: busybox:1.36
    command: ["/bin/sh", "-c"]
    args:
      - while true; do tail -n 3 /shared-data/timestamp.log; sleep 10; done
    volumeMounts:
    - name: shared-storage
      mountPath: /shared-data
  volumes:
  - name: shared-storage
    emptyDir: {}
```

---

## 2. hostPath

### What is hostPath?
A `hostPath` volume mounts a file or directory from the host node's filesystem directly into your Pod. This allows pods to interact with underlying node storage directly.

### Practical Use Cases
- Running cluster monitoring or logging agents (like Fluentd, Filebeat, or Prometheus Node Exporter) that need access to `/var/log` or system metrics on the host.
- Accessing host Docker/containerd daemons or system sockets.
- Local single-node testing environments like Minikube.

### Security Consideration
`hostPath` volumes present significant security risks in multi-tenant environments because a pod can potentially access sensitive host files. In production, use `PersistentVolumes` backed by cloud block storage instead.

### YAML Example
Refer to `02-hostpath-pod.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-demo-pod
spec:
  containers:
  - name: node-logger
    image: busybox:1.36
    command: ["/bin/sh", "-c", "while true; do echo \"[$(date)] Node check\" >> /host-logs/node-audit.log; sleep 10; done"]
    volumeMounts:
    - name: host-log-volume
      mountPath: /host-logs
  volumes:
  - name: host-log-volume
    hostPath:
      path: /tmp/k8s-node-data
      type: DirectoryOrCreate
```

---

## 3. PersistentVolume (PV)

### What is a PersistentVolume?
A `PersistentVolume` (PV) is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes. It is a cluster-level resource just like a Node, and has a lifecycle completely independent of any individual Pod that uses the PV.

### Key Attributes
- **Capacity:** The volume storage size (such as 1Gi, 100Gi).
- **Access Modes:**
  - `ReadWriteOnce` (RWO): Mountable as read-write by a single Node.
  - `ReadOnlyMany` (ROX): Mountable as read-only by many Nodes.
  - `ReadWriteMany` (RWX): Mountable as read-write by many Nodes.
  - `ReadWriteOncePod` (RWOP): Mountable as read-write by a single Pod.
- **Reclaim Policy:**
  - `Retain`: Manual reclamation; data is preserved after PVC is deleted.
  - `Delete`: Automatically removes PV and associated storage backend when PVC is deleted.
  - `Recycle`: Deprecated basic scrub (`rm -rf /thevolume/*`).

### YAML Example
Refer to `03-persistent-volume.yaml`:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local-storage
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/tmp/data/pv-storage"
```

---

## 4. PersistentVolumeClaim (PVC)

### What is a PersistentVolumeClaim?
A `PersistentVolumeClaim` (PVC) is a request for storage by a user or application pod. It is similar to a Pod: Pods consume node resources (CPU, Memory) and PVCs consume PV resources (Size, Access Modes).

### Binding Workflow
The Kubernetes control plane constantly monitors PVCs, finds matching PVs (matching storage class, access modes, and requested capacity), and binds them together in a 1-to-1 relationship.

### YAML Example
Refer to `04-persistent-volume-claim.yaml`:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

### Pod Consuming the PVC
Refer to `05-pod-using-pvc.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: task-pv-pod
spec:
  volumes:
    - name: task-pv-storage
      persistentVolumeClaim:
        claimName: task-pv-claim
  containers:
    - name: task-pv-container
      image: nginx:alpine
      ports:
        - containerPort: 80
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: task-pv-storage
```

---

## 5. StorageClass

### What is a StorageClass?
A `StorageClass` provides a way for administrators to describe the "classes" of storage they offer (such as fast SSDs, cheap standard HDDs, or AWS EBS gp3). It defines which dynamic provisioner plugin to invoke and what parameters to pass.

### Key Parameters
- `provisioner`: Determines what volume plugin is used for provisioning PVs (e.g., `kubernetes.io/aws-ebs`, `pd.csi.storage.gke.io`, `k8s.io/minikube-hostpath`).
- `volumeBindingMode`:
  - `Immediate`: PV is created immediately when PVC is created.
  - `WaitForFirstConsumer`: Delays PV creation until a Pod using the PVC is scheduled, ensuring storage is allocated in the correct Availability Zone.
- `allowVolumeExpansion`: Allows resizing PVCs dynamically.

### YAML Example
Refer to `06-storage-class.yaml`:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd-storage
provisioner: k8s.io/minikube-hostpath
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
parameters:
  type: standard
```

---

## 6. Dynamic Provisioning

### How Dynamic Provisioning Works
1. A developer creates a `PersistentVolumeClaim` referencing a `StorageClass`.
2. The dynamic volume provisioner creates a new volume in the cloud or local storage backend automatically.
3. A `PersistentVolume` is automatically generated by Kubernetes and bound to the PVC.
4. The Pod mounts the PVC and begins read/write operations with zero manual intervention from administrators.

```
+------------------+         +--------------------+         +-----------------------+
| Developer writes | ------> | StorageClass       | ------> | Cloud / Disk Provider |
| PVC manifest     |         | Provisioner triggers|         | provisions volume     |
+------------------+         +--------------------+         +-----------------------+
                                        |                               |
                                        v                               v
                             +--------------------+         +-----------------------+
                             | Pod mounts PVC     | <------ | PV created & bound    |
                             | to /data path      |         | automatically         |
                             +--------------------+         +-----------------------+
```

---

## Summary Comparison Matrix

| Storage Type | Persistence | Node Bound | Dynamic Provisioning | Primary Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **emptyDir** | Pod Lifetime | Yes | No | Container data sharing, scratch cache |
| **hostPath** | Node Lifetime | Yes | No | DaemonSets, system metrics, node logs |
| **Static PV/PVC** | Persistent | Configurable | No (Manual admin setup) | Fixed legacy storage, single-cluster DBs |
| **Dynamic StorageClass** | Persistent | Cloud / CSI | Yes (Automatic) | Production stateful workloads, microservices |

# Session 15: Task 1 - Helm Commands Reference Guide

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## Overview

Helm is the package manager for Kubernetes. It simplifies the definition, versioning, installation, and upgrade of complex Kubernetes applications using reusable packages called Charts. This guide documents the primary Helm CLI commands practiced in this session.

---

## 1. `helm create`

### Purpose
Scaffolds a standard Helm chart directory structure with default templates (`deployment.yaml`, `service.yaml`, `hpa.yaml`, `ingress.yaml`), `values.yaml`, and `Chart.yaml`.

### Command and Output
```bash
helm create my-chart
```
**Output:**
```
Creating my-chart
```

---

## 2. `helm repo`

### Purpose
Manages remote chart repositories, including adding, listing, updating, and removing chart repositories.

### Command and Output
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```
**Output:**
```
"bitnami" has been added to your repositories
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈Happy Helming!⎈
```

---

## 3. `helm search`

### Purpose
Searches for Helm charts either locally within added repositories or globally across the Artifact Hub.

### Command and Output
```bash
helm search repo bitnami/nginx
```
**Output:**
```
NAME            CHART VERSION   APP VERSION   DESCRIPTION                                  
bitnami/nginx   18.3.5          1.27.4        NGINX Open Source is a web server that can...
```

---

## 4. `helm install`

### Purpose
Renders chart templates with values and installs the resulting Kubernetes manifests as a named release into the cluster.

### Command and Output
```bash
helm install my-webapp ./my-chart --set replicaCount=2
```
**Output:**
```
NAME: my-webapp
LAST DEPLOYED: Wed Oct  7 08:15:20 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
   export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=my-chart" -o jsonpath="{.items[0].metadata.name}")
   kubectl --namespace default port-forward $POD_NAME 8080:80
```

---

## 5. `helm list`

### Purpose
Lists all deployed Helm releases in the current namespace or across all namespaces with `-A`.

### Command and Output
```bash
helm list
```
**Output:**
```
NAME         NAMESPACE   REVISION   UPDATED                                STATUS     CHART           APP VERSION
my-webapp    default     1          2026-10-07 08:15:20.123456 +0530 IST   deployed   my-chart-0.1.0  1.16.0     
```

---

## 6. `helm status`

### Purpose
Displays the current status of a deployed release, including notes, deployment timestamp, namespace, and Kubernetes resources created.

### Command and Output
```bash
helm status my-webapp
```
**Output:**
```
NAME: my-webapp
LAST DEPLOYED: Wed Oct  7 08:15:20 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

---

## 7. `helm get`

### Purpose
Fetches specific release information stored in Kubernetes Secret storage, including rendered manifests, user-supplied values, or all data.

### Subcommands
- `helm get values <release>`: Retrieves user-supplied configuration overrides.
- `helm get manifest <release>`: Retrieves rendered raw Kubernetes YAML manifests.
- `helm get all <release>`: Fetches charts, values, hooks, and release notes.

### Command and Output
```bash
helm get values my-webapp
```
**Output:**
```
USER-SUPPLIED VALUES:
replicaCount: 2
```

---

## 8. `helm upgrade`

### Purpose
Upgrades an existing release to a new chart version or applies updated configuration values without deleting the underlying state.

### Command and Output
```bash
helm upgrade my-webapp ./my-chart --set replicaCount=4
```
**Output:**
```
Release "my-webapp" has been upgraded. Happy Helming!
NAME: my-webapp
LAST DEPLOYED: Wed Oct  7 08:18:45 2026
NAMESPACE: default
STATUS: deployed
REVISION: 2
TEST SUITE: None
```

---

## 9. `helm history`

### Purpose
Shows the complete revision history of a release, showing previous deployments, timestamps, statuses, and description messages.

### Command and Output
```bash
helm history my-webapp
```
**Output:**
```
REVISION   UPDATED                   STATUS       CHART           APP VERSION   DESCRIPTION     
1          Wed Oct  7 08:15:20 2026  superseded   my-chart-0.1.0  1.16.0        Install complete
2          Wed Oct  7 08:18:45 2026  deployed     my-chart-0.1.0  1.16.0        Upgrade complete
```

---

## 10. `helm rollback`

### Purpose
Rolls back a release to a previous stable revision number in case of bad deployments, configuration errors, or failed rollouts.

### Command and Output
```bash
helm rollback my-webapp 1
```
**Output:**
```
Rollback was a success! Happy Helming!
```

---

## 11. `helm uninstall`

### Purpose
Deletes all Kubernetes resources associated with the named release and removes the release record.

### Command and Output
```bash
helm uninstall my-webapp
```
**Output:**
```
release "my-webapp" uninstalled
```

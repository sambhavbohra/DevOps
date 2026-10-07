# Session 20: Task 3 - GitOps Architecture & Continuous Reconciliation

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## 1. What is GitOps?

GitOps is an operational framework that takes DevOps best practices used for application development (such as version control, collaboration, compliance, and CI/CD) and applies them to infrastructure automation and application delivery.

In GitOps, **Git is the Single Source of Truth** for both infrastructure definitions and application deployment states.

---

## 2. Core Principles of GitOps

```
+---------------------------------------------------------------------------------------------------+
| 1. Declarative Description  | 2. Versioned & Immutable | 3. Automated Pull Sync | 4. Continuous   |
|    Entire desired state is   |    Stored in Git with     |    Agent pulls changes |    Reconciliation |
|    declared in YAML code    |    full audit history    |    into cluster        |    fixes drift    |
+---------------------------------------------------------------------------------------------------+
```

1. **Declarative Configuration:** The entire desired state of the cluster is described declaratively (Kubernetes manifests, Helm charts, Kustomize overlays).
2. **Versioned and Immutable State:** The canonical desired state is version-controlled in Git, providing complete change logs, pull request reviews, and instantaneous rollbacks via `git revert`.
3. **Automated Pull-Based Synchronization:** An in-cluster operator (such as ArgoCD or Flux) continuously pulls the desired state from Git rather than pushing from an external CI server.
4. **Continuous Reconciliation (Self-Healing):** The GitOps agent constantly compares the live cluster state against the desired state in Git. If configuration drift occurs (e.g., someone manually edits a service using `kubectl edit`), the controller automatically overwrites the drift to match Git.

---

## 3. GitOps vs Traditional CI/CD (Pull vs Push)

| Dimension | Traditional CI/CD (Push Model) | GitOps (Pull Model) |
| :--- | :--- | :--- |
| **Deployment Trigger** | External CI pipeline executes `kubectl apply` | In-cluster agent pulls from Git repository |
| **Cluster Access Security** | CI runner must hold administrative cluster credentials | Zero external cluster credentials needed; agent runs inside cluster |
| **Drift Detection** | None (manual cluster changes remain undetected) | Active 24/7 continuous reconciliation and self-healing |
| **Rollback Mechanism** | Trigger a new CI deployment job | Simply execute `git revert <commit>` in Git |

---

## 4. GitOps Workflow Lifecycle

```
[ Developer ] ---> [ Git Pull Request ] ---> [ Code Review & Merge to main ]
                                                               |
                                                               v (Git is Source of Truth)
                                                   +------------------------+
                                                   | GitHub Repository      |
                                                   +------------------------+
                                                               |
                                                               v (ArgoCD continuously pulls)
                                                   +------------------------+
                                                   | ArgoCD In-Cluster      |
                                                   | Reconciliation Engine  |
                                                   +------------------------+
                                                               |
                                            +------------------+------------------+
                                            |                                     |
                                            v                                     v
                             +-----------------------------+       +-----------------------------+
                             | Live State == Desired State |       | State Drift Detected        |
                             | Status: Synced / Healthy    |       | Auto Self-Heal to Git State |
                             +-----------------------------+       +-----------------------------+
```

---

## 5. Kubernetes & ArgoCD Implementation

The manifest `argocd-app.yaml` configures an automated ArgoCD deployment:
- **`syncPolicy.automated.prune: true`:** Deletes live Kubernetes objects that are removed from the Git repository.
- **`syncPolicy.automated.selfHeal: true`:** Overwrites manual out-of-band changes to guarantee cluster integrity.
- **`destination.namespace: production`:** Deploys target manifests to the designated environment namespace.

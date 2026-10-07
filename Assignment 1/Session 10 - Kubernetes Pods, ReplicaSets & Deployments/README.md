# Session 10 — Pods, ReplicaSets, Deployments, StatefulSets, DaemonSets

**Sambhav D Bohra — 24BCS10090**

Minikube (Docker driver) on macOS, Kubernetes v1.37.0. Ran everything in its own `session10` namespace instead of `default`, because `default` already had a `web` Pod from an earlier assignment with label `app=web` — the same label this ReplicaSet uses. Applying in `default` would've silently adopted that Pod instead of creating fresh ones.

Folders got renamed after the fact for clarity (`k8s-core-objects/` → `manifests/`, `supporting/` → `extra/`, `deamonset.yml` → `daemonset.yml`), so the terminal screenshots below still show the old paths — the commands are quoted here with the current ones.

```
minikube version: v1.39.0
kubectl Client Version: v1.34.1
kubectl get nodes: minikube   Ready   control-plane   v1.37.0
```
![environment](screenshots/00-environment.png)

## Pod — [manifests/pod.yml](manifests/pod.yml)

Two containers in one Pod: `app` (nginx) and `logger` (busybox looping `echo log`).

```
kubectl apply -f manifests/pod.yml
kubectl get pods
```
![apply](screenshots/pod/01-apply.png)

```
kubectl get pod mypod -o wide
kubectl get pod mypod -o jsonpath="{.spec.containers[*].name}"
```
`2/2 Running`, one Pod IP for both containers, names `app logger` come back from jsonpath.
![get](screenshots/pod/02-get.png)

`kubectl describe pod mypod` — two separate `Containers:` blocks, each with its own image/state.
![describe](screenshots/pod/03-describe.png)

`kubectl logs mypod -c logger` / `-c app` — needs `-c` because there are two containers; each has its own log stream (repeated `log` from busybox vs nginx's startup log).
![logs](screenshots/pod/04-logs.png)

## ReplicaSet — [manifests/replicaset.yml](manifests/replicaset.yml)

3 replicas, selector `app: web`.

```
kubectl apply -f manifests/replicaset.yml
kubectl get rs
```
![apply](screenshots/replicaset/05-apply.png)

`kubectl get pods -o wide` — three `myapp-rs-*` Pods, random suffixes, plus `mypod` still around.
![pods](screenshots/replicaset/06-pods.png)

`kubectl describe rs myapp-rs` — three `SuccessfulCreate` events from the replicaset-controller.
![describe](screenshots/replicaset/07-describe.png)

Self-healing check: grabbed one Pod name, deleted it, listed again.

```
victim=$(kubectl get pods -l app=web -o jsonpath="{.items[0].metadata.name}")
kubectl delete pod "$victim"
kubectl get pods -l app=web
```
`myapp-rs-767lq` got deleted → `myapp-rs-5f84x` showed up at 4s while the other two sat at 87s. Count went right back to 3, but it's a new Pod, not the old one restarted.
![self-healing](screenshots/replicaset/08-self-healing.png)

## Deployment — [manifests/deployment.yml](manifests/deployment.yml)

```
kubectl apply -f manifests/deployment.yml
kubectl get deployments
```
Caught it mid-rollout: `READY 2/3`.
![apply](screenshots/deployment/09-apply.png)

```
kubectl rollout status deployment/myapp
kubectl get rs
```
Rolled out fine, and now there's a second ReplicaSet, `myapp-5b9587f95d`, sitting next to the standalone `myapp-rs` from before — the Deployment created its own.
![status](screenshots/deployment/10-status.png)

`ownerReferences` on the Pods point at `ReplicaSet/myapp-5b9587f95d`, not the Deployment directly. Deployment owns the ReplicaSet, ReplicaSet owns the Pods.
![pods](screenshots/deployment/11-pods.png)

Scaled 3 → 5 → 3:
```
kubectl scale deployment myapp --replicas=5
kubectl scale deployment myapp --replicas=3
```
Two new Pods showed up at 8s while the original three sat at 78s, then scaling back down removed the extras. ReplicaSet hash never changed — scaling isn't a new revision.
![scaling](screenshots/deployment/12-scaling.png)

## StatefulSet — [manifests/statefulset.yml](manifests/statefulset.yml)

Needs a headless Service first (`extra/mysql-headless-service.yml`, `clusterIP: None`) since `serviceName: mysql` doesn't ship with the StatefulSet manifest itself.

```
kubectl get svc          # No resources found
kubectl apply -f extra/mysql-headless-service.yml
kubectl apply -f manifests/statefulset.yml
```
![apply](screenshots/statefulset/13-apply.png)

Here's where it got interesting. `mysql:5.7` doesn't ship an arm64 image, and this Mac is Apple Silicon:

```
kubectl get pods -l app=mysql -o wide
NAME      READY   STATUS             AGE
mysql-0   0/1     ImagePullBackOff   24s
```
`mysql-0` never comes up, so `mysql-1` and `mysql-2` never even get created — a StatefulSet won't start ordinal 1 until ordinal 0 is Ready. `kubectl get statefulset` sits at `0/3` for good. On an x86 machine this would've pulled fine and gone `mysql-0 → mysql-1 → mysql-2` in order.
![pods](screenshots/statefulset/14-pods.png)

One PVC did get created for `mysql-0` before the image pull failed — `mysql-persistent-storage-mysql-0`, `Bound`, 5Gi. That part of the StatefulSet contract (one PVC per ordinal, from `volumeClaimTemplates`) worked exactly as expected even though the container itself never started.
![pvc](screenshots/statefulset/15-pvc.png)

`kubectl describe statefulset mysql` confirms it: `1 total` replica created, `0 Running / 1 Waiting`.
![describe](screenshots/statefulset/16-describe.png)

## DaemonSet — [manifests/daemonset.yml](manifests/daemonset.yml)

Runs `prom/node-exporter` — no `replicas` field, the controller just runs one Pod per node.

```
kubectl apply -f manifests/daemonset.yml
kubectl get daemonset
```
Caught right after apply: `READY 0`, image still pulling.
![apply](screenshots/daemonset/17-apply.png)

A bit later, `1/1` everywhere — makes sense, since `kubectl get nodes` only shows one node (`minikube`). Same yaml on a 3-node cluster would say `DESIRED 3`.
![pods](screenshots/daemonset/18-pods.png)

`kubectl describe daemonset node-exporter` — `Desired Number of Nodes Scheduled: 1`, `Misscheduled: 0`.
![describe](screenshots/daemonset/19-describe.png)

## Final check

```
kubectl get pods
kubectl get rs
kubectl get deployments
kubectl get statefulsets
kubectl get daemonsets
kubectl get pvc
```

| Object | Pods | Notes |
|---|---|---|
| Pod | `mypod` (2/2) | |
| ReplicaSet `myapp-rs` | 3 | one self-healed mid-way |
| Deployment `myapp` | 3 | via ReplicaSet `myapp-5b9587f95d` |
| StatefulSet `mysql` | 0/3 | `mysql-0` stuck on `ImagePullBackOff` (arm64) |
| DaemonSet `node-exporter` | 1 | one node in the cluster |

Everything else came up clean; the only real failure was the arm64/mysql:5.7 image mismatch, left in as-is rather than swapped for a working image, since it's an honest result of running this on an M-series Mac instead of the x86 machine the manifests were written for.

![final](screenshots/20-final.png)

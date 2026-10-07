# Troubleshooting: ImagePullBackOff & ErrImagePull

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## 1. Problem Statement
The Pod `imagepull-broken` fails to initialize. The pod status remains stuck in `ErrImagePull` followed by `ImagePullBackOff`.

---

## 2. Investigation Steps

### Step 1: Check Pod Status
```bash
kubectl get pods
```
**Output:**
```
NAME               READY   STATUS             RESTARTS   AGE
imagepull-broken   0/1     ImagePullBackOff   0          45s
```

### Step 2: Describe Pod and Inspect Events
```bash
kubectl describe pod imagepull-broken
```
**Output:**
```
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  60s                default-scheduler  Successfully assigned default/imagepull-broken to minikube
  Normal   Pulling    15s (x3 over 58s)  kubelet            Pulling image "nginx:nonexistent-tag-99999"
  Warning  Failed     14s (x3 over 57s)  kubelet            Failed to pull image "nginx:nonexistent-tag-99999": manifest for nginx:nonexistent-tag-99999 not found
  Warning  Failed     14s (x3 over 57s)  kubelet            Error: ErrImagePull
  Normal   BackOff    2s (x6 over 56s)   kubelet            Back-off pulling image "nginx:nonexistent-tag-99999"
  Warning  Failed     2s (x6 over 56s)   kubelet            Error: ImagePullBackOff
```

---

## 3. Root Cause
The container image tag `nginx:nonexistent-tag-99999` does not exist in Docker Hub container registry. Kubelet receives HTTP 404 from the registry, marking the image pull as failed and entering exponential back-off.

---

## 4. Solution
Correct the image repository name, tag version, or configure image pull secrets if pulling from a private registry (such as AWS ECR, Docker Hub private repos, or GitHub Container Registry).

Apply the fixed manifest in `fixed.yaml`.

---

## 5. Verification
```bash
kubectl apply -f fixed.yaml
kubectl get pods -l app=imagepull-demo
```
**Output:**
```
NAME              READY   STATUS    RESTARTS   AGE
imagepull-fixed   1/1     Running   0          18s
```
Kubelet pulls `nginx:alpine` and starts container successfully.

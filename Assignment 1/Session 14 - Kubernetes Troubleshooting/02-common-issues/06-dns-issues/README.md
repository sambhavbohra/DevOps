# Troubleshooting: Kubernetes CoreDNS & Name Resolution

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## 1. Problem Statement
Application containers report `getaddrinfo ENOTFOUND` or `server can't find domain: NXDOMAIN` when attempting to communicate with other services across the cluster.

---

## 2. Investigation Steps

### Step 1: Inspect CoreDNS Pod Health in `kube-system`
```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns
```
**Output:**
```
NAME                       READY   STATUS    RESTARTS      AGE
coredns-559f6c778d-74scx   1/1     Running   0             18d
```

### Step 2: Check DNS Resolution from Inside a Test Pod
```bash
kubectl run dnsutils --image=tutum/dnsutils --rm -it --restart=Never -- nslookup kubernetes.default
```
**Output:**
```
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1
```

### Step 3: Inspect `/etc/resolv.conf` Inside Failing Containers
```bash
kubectl exec -it dns-test-broken -- cat /etc/resolv.conf
```
**Output:**
```
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5
```

---

## 3. Root Cause
Common DNS failures stem from:
1. CoreDNS pods in CrashLoopBackOff or lacking upstream nameserver forwarding.
2. Applications querying incorrect Fully Qualified Domain Names (e.g., omitting the namespace when querying cross-namespace services: `<service-name>.<namespace>.svc.cluster.local`).
3. High ndots overhead causing query delays and timeouts.

---

## 4. Solution
1. Verify CoreDNS deployment and logs using `kubectl logs -n kube-system -l k8s-app=kube-dns`.
2. Standardize inter-service domain naming following `<service>.<namespace>.svc.cluster.local`.
3. Apply corrected manifest in `fixed-dns.yaml`.

---

## 5. Verification
```bash
kubectl apply -f fixed-dns.yaml
kubectl logs dns-test-fixed
```
**Output:**
```
Server:         10.96.0.10
Address:        10.96.0.10:53

Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1

DNS resolution succeeded
```

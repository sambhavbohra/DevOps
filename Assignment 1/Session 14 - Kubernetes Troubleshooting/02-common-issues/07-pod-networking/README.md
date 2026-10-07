# Troubleshooting: Pod Networking & CNI Issues

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## 1. Problem Statement
Pods running on different nodes or even on the same node cannot communicate over their assigned IP addresses. Network packet drops or timeouts occur during pod-to-pod communication.

---

## 2. Investigation Steps

### Step 1: Inspect CNI Plugin DaemonSet Status
Check the Container Network Interface (Calico, Flannel, Cilium, or Kindnet) pods in the `kube-system` namespace:
```bash
kubectl get pods -n kube-system -l k8s-app=kindnet
```
**Output:**
```
NAME            READY   STATUS    RESTARTS   AGE
kindnet-lps94   1/1     Running   3          18d
```

### Step 2: Check Node Network Routing and IP Allocation
```bash
kubectl describe node minikube | grep PodCIDR
```
**Output:**
```
PodCIDR:                      10.244.0.0/24
PodCIDRs:                     10.244.0.0/24
```

### Step 3: Test Direct Pod-to-Pod Ping / Curl
```bash
kubectl exec -it pod-a -- ping -c 3 10.244.0.22
```

### Step 4: Check for NetworkPolicies Blocking Traffic
```bash
kubectl get networkpolicies -A
```

---

## 3. Root Cause
- CNI plugin pod crash or failure to initialize iptables/eBPF routing rules on worker nodes.
- Pod CIDR IP pool exhaustion preventing IP assignment.
- Default-deny NetworkPolicy unintentionally blocking ingress/egress traffic on target namespace ports.
- Host firewall rules (such as `ufw` or `iptables` FORWARD chain dropping cross-bridge traffic).

---

## 4. Solution
1. Restart or reinstall CNI DaemonSet pods.
2. Ensure Linux kernel packet forwarding is enabled on all nodes (`sysctl net.ipv4.ip_forward=1`).
3. Audit and apply explicit NetworkPolicy ingress rules allowing required application ports.

---

## 5. Verification
```bash
kubectl exec -it pod-a -- nc -zv 10.244.0.22 80
```
**Output:**
```
Connection to 10.244.0.22 80 port [tcp/http] succeeded!
```

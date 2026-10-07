# Session 20: Task 1 - Application Monitoring & Alerting Demo

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## 1. Overview of Monitoring

Monitoring is the operational practice of collecting, aggregating, and analyzing quantitative system metrics to determine whether systems are running within expected thresholds.

---

## 2. Core Monitoring Concepts

### A. Metrics
Numeric values measured over time representing system activity (Counters, Gauges, Histograms, Summaries).
- **Counter:** Monotonically increasing metric (e.g., `http_requests_total`).
- **Gauge:** Numerical value that can arbitrarily go up or down (e.g., `process_cpu_percent`, `memory_rss_bytes`).
- **Histogram:** Samples observations and counts them into configurable buckets (e.g., request latency in seconds).

### B. Application Health Probes
- **Liveness Probes:** Queries `/health` to verify if the web process is responsive. If failing, kubelet restarts the container.
- **Readiness Probes:** Ensures the application is initialized and capable of receiving live incoming requests.

### C. Resource Utilization Tracking
- **CPU Utilization:** Measured via Prometheus / cAdvisor tracking container throttling and core consumption.
- **Memory Utilization:** Monitored against OOM (Out Of Memory) limits to avoid container crashes.

### D. Automated Alerting Rules
Prometheus Alertmanager evaluates expressions at regular intervals and triggers notifications (Slack, PagerDuty, Webhooks) when thresholds are crossed.
- `HighCPUUsage`: Triggers if process CPU > 80% for more than 2 minutes.
- `HighMemoryUsage`: Triggers if RAM > 200MB for more than 3 minutes.
- `PodDown`: Triggers immediately if an instance fails Prometheus heartbeats (`up == 0`).

---

## 3. Deployment and Validation

### Step 1: Deploy Telemetry Service
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/prometheus-config.yaml
```

**Output:**
```
deployment.apps/telemetry-app created
service/telemetry-service created
configmap/prometheus-server-conf created
configmap/prometheus-alert-rules created
```

### Step 2: Query Scraped Prometheus Metrics
```bash
kubectl exec -it deployment/telemetry-app -- curl -s http://localhost:8000/metrics
```

**Scraped Telemetry Output:**
```
# HELP http_requests_total Total HTTP Requests Processed
# TYPE http_requests_total counter
http_requests_total{endpoint="/health",http_status="200",method="GET"} 42.0

# HELP process_cpu_percent Current Process CPU Usage Percentage
# TYPE process_cpu_percent gauge
process_cpu_percent 14.8

# HELP process_memory_usage_bytes Current Process Resident Memory Usage
# TYPE process_memory_usage_bytes gauge
process_memory_usage_bytes 4.194304e+07
```

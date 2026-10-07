# Session 20: Task 2 - Observability: Three Pillars & Architecture

**Student Name:** Sambhav D Bohra  
**Registration Number:** 24bcs10090  

---

## 1. What is Observability & Why is it Required?

While traditional **Monitoring** tells you *when* something is broken (e.g. "Error rate is 15%"), **Observability** is the degree to which you can infer the internal states of a complex system based on knowledge of its external outputs. Observability allows engineers to understand *why* something is broken, enabling deep diagnostic debugging of unpredictable, novel failure modes across distributed microservices.

---

## 2. The Three Major Pillars of Observability

```
                                +-------------------+
                                |   Observability   |
                                +-------------------+
                                 /        |        \
                                /         |         \
                               v          v          v
                       +-----------+ +---------+ +-----------+
                       |  Metrics  | |  Logs   | |  Traces   |
                       |  (What)   | |  (Why)  | |  (Where)  |
                       +-----------+ +---------+ +-----------+
```

### A. Metrics (Aggregated Numerical Telemetry)
- **Definition:** Numeric values measured over time intervals representing performance counters, rates, gauges, and distributions.
- **Characteristics:** Low storage overhead, fast querying, highly aggregable for mathematical trending and automated alerting.
- **Example:** `http_requests_total{status="500"}`, `container_cpu_usage_seconds_total`.
- **Role:** Answers *What is happening?* (e.g., CPU is spiking, error rate is increasing).

### B. Logs (Timestamped Event Records)
- **Definition:** An immutable, timestamped record of discrete application events with rich contextual metadata.
- **Characteristics:** High cardinality, detailed contextual stack traces, structured (JSON) or unstructured text.
- **Example:** `{"timestamp": "2026-10-07T08:35:12Z", "level": "ERROR", "trace_id": "a91b2", "message": "Failed to connect to database replica: Connection timeout"}`.
- **Role:** Answers *Why did it happen?* (e.g., exact line of code, null pointer exception, connection string error).

### C. Distributed Traces (Request Journey Mapping)
- **Definition:** End-to-end representation of a single request's path as it travels through multiple distributed microservices and databases.
- **Components:**
  - **Trace:** The entire directed acyclic graph representing a transaction.
  - **Span:** A single unit of work within the trace (e.g. HTTP call, database query, cache lookup) containing start time, duration, tags, and logs.
- **Role:** Answers *Where is the bottleneck occurring and where did it fail?* (e.g., 85% of request time was spent in payment-gateway database query).

---

## 3. Comparison Matrix: Metrics vs Logs vs Traces

| Dimension | Metrics | Logs | Traces |
| :--- | :--- | :--- | :--- |
| **Data Format** | Numerical time-series | Text / JSON structured events | Call graph spans with context propagation |
| **Storage Cost** | Very Low (Compact) | High (Grows with traffic) | Medium (Sampled) |
| **Primary Use** | Alerting, Dashboards, Trending | Root cause debugging, Auditing | Latency profiling, Dependency mapping |
| **Cardinality** | Low to Medium | High | High |

---

## 4. Industry-Standard Observability Tooling Ecosystem

```
+------------------+-----------------------------+------------------------------------+
| Observability    | Open-Source Tooling         | Enterprise / Cloud-Native SaaS     |
+------------------+-----------------------------+------------------------------------+
| Metrics          | Prometheus, VictoriaMetrics | Datadog, AWS CloudWatch, Dynatrace |
| Logs             | Grafana Loki, Fluentd, ELK  | Splunk, Sumo Logic, Loggly         |
| Traces           | Jaeger, Zipkin, Tempo       | Honeycomb, Lightstep, New Relic    |
| Telemetry Engine | OpenTelemetry (OTel)        | OTel Collector, Datadog Agent      |
| Visualization    | Grafana Dashboards          | Grafana Cloud, Datadog Dashboards  |
+------------------+-----------------------------+------------------------------------+
```

---

## 5. Kubernetes Observability Patterns

1. **cAdvisor & Metrics Server:** Built into kubelet to export raw node and container CPU/RAM resource metrics.
2. **Prometheus Operator & ServiceMonitors:** Automatically discovers and scrapes application endpoints via declarative custom resources.
3. **DaemonSet Log Shipping:** Promtail or Fluentbit deployed on each Kubernetes node mounting `/var/log/pods` to ship container stdout streams to Loki or Elasticsearch.
4. **OpenTelemetry Sidecar / DaemonSet:** Propagates `W3C TraceContext` headers across microservice HTTP headers to track multi-pod request flows.

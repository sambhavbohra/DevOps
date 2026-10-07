import os
import time
import json
import psutil
from flask import Flask, jsonify, request, Response
# pyrefly: ignore [missing-import]
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# Application Metadata
APP_NAME = os.environ.get("APP_NAME", "order-processing-platform")
APP_VERSION = os.environ.get("APP_VERSION", "2.5.0")
ENVIRONMENT = os.environ.get("ENVIRONMENT", "production")
LOG_PATH = os.environ.get("STORAGE_LOG_PATH", "/var/log/app/transactions.log")

# In-Memory Data Store (Simulating DB)
ORDERS_DB = []

# Prometheus Metrics Definitions
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests received",
    ["method", "endpoint", "status"]
)
REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request execution latency",
    ["endpoint"]
)
SYSTEM_CPU_GAUGE = Gauge(
    "system_cpu_usage_percent",
    "Current CPU usage percentage"
)
SYSTEM_MEM_GAUGE = Gauge(
    "system_memory_usage_bytes",
    "Current RSS Memory consumption in bytes"
)

def log_transaction(order):
    try:
        os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)
        with open(LOG_PATH, "a") as f:
            f.write(json.dumps(order) + "\n")
    except Exception as e:
        print(f"[Warning] Could not write to log volume: {e}")

@app.route("/health", methods=["GET"])
def health_liveness():
    REQUEST_COUNT.labels(method="GET", endpoint="/health", status="200").inc()
    return jsonify({
        "status": "HEALTHY",
        "service": APP_NAME,
        "version": APP_VERSION,
        "author": "Sambhav D Bohra",
        "regNo": "24bcs10090"
    }), 200

@app.route("/ready", methods=["GET"])
def health_readiness():
    # Verify environment and readiness
    REQUEST_COUNT.labels(method="GET", endpoint="/ready", status="200").inc()
    return jsonify({
        "status": "READY",
        "environment": ENVIRONMENT,
        "active_orders": len(ORDERS_DB)
    }), 200

@app.route("/api/v1/orders", methods=["GET"])
def get_orders():
    start = time.time()
    REQUEST_COUNT.labels(method="GET", endpoint="/api/v1/orders", status="200").inc()
    REQUEST_LATENCY.labels(endpoint="/api/v1/orders").observe(time.time() - start)
    return jsonify({"count": len(ORDERS_DB), "orders": ORDERS_DB}), 200

@app.route("/api/v1/orders", methods=["POST"])
def create_order():
    start = time.time()
    data = request.get_json(silent=True)
    if not data or "item" not in data or "amount" not in data:
        REQUEST_COUNT.labels(method="POST", endpoint="/api/v1/orders", status="400").inc()
        return jsonify({"error": "Invalid payload: item and amount are required"}), 400
    
    if not isinstance(data["amount"], (int, float)) or data["amount"] <= 0:
        REQUEST_COUNT.labels(method="POST", endpoint="/api/v1/orders", status="422").inc()
        return jsonify({"error": "Amount must be a positive number"}), 422

    order = {
        "id": f"ORD-{len(ORDERS_DB) + 1001}",
        "item": str(data["item"]),
        "amount": float(data["amount"]),
        "status": "PROCESSED",
        "timestamp": time.time()
    }
    ORDERS_DB.append(order)
    log_transaction(order)
    
    REQUEST_COUNT.labels(method="POST", endpoint="/api/v1/orders", status="201").inc()
    REQUEST_LATENCY.labels(endpoint="/api/v1/orders").observe(time.time() - start)
    return jsonify(order), 201

@app.route("/metrics", methods=["GET"])
def metrics():
    SYSTEM_CPU_GAUGE.set(psutil.cpu_percent())
    SYSTEM_MEM_GAUGE.set(psutil.Process().memory_info().rss)
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)

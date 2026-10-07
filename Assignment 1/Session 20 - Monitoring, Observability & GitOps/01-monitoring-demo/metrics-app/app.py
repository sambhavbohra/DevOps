import time
import psutil
from flask import Flask, jsonify, Response
# pyrefly: ignore [missing-import]
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# Prometheus Metrics Definitions
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP Requests Processed',
    ['method', 'endpoint', 'http_status']
)
REQUEST_LATENCY = Histogram(
    'http_request_duration_seconds',
    'HTTP Request Latency in Seconds',
    ['endpoint']
)
CPU_USAGE_GAUGE = Gauge(
    'process_cpu_usage_percent',
    'Current Process CPU Usage Percentage'
)
MEMORY_USAGE_GAUGE = Gauge(
    'process_memory_usage_bytes',
    'Current Process Resident Memory Usage in Bytes'
)

@app.route('/health', methods=['GET'])
def health():
    REQUEST_COUNT.labels(method='GET', endpoint='/health', http_status='200').inc()
    return jsonify({
        "status": "UP",
        "service": "telemetry-metrics-service",
        "author": "Sambhav D Bohra",
        "regNo": "24bcs10090"
    }), 200

@app.route('/api/order', methods=['POST'])
def process_order():
    start_time = time.time()
    # Simulate work
    time.sleep(0.05)
    duration = time.time() - start_time
    
    REQUEST_COUNT.labels(method='POST', endpoint='/api/order', http_status='201').inc()
    REQUEST_LATENCY.labels(endpoint='/api/order').observe(duration)
    
    return jsonify({"status": "order_processed", "duration_ms": round(duration * 1000, 2)}), 201

@app.route('/metrics', methods=['GET'])
def metrics():
    # Update real system metrics before scraping
    CPU_USAGE_GAUGE.set(psutil.cpu_percent())
    MEMORY_USAGE_GAUGE.set(psutil.Process().memory_info().rss)
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)

# Multi-stage hardened non-root container
FROM python:3.11-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Final minimal distroless/slim runtime image
FROM python:3.11-slim AS runner

WORKDIR /app

# Create non-root dedicated application user
RUN groupadd -r appgroup && useradd -r -g appgroup -u 10001 appuser

# Copy installed wheels from builder
COPY --from=builder /root/.local /home/appuser/.local
COPY src/ /app/src/

ENV PATH=/home/appuser/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1
ENV PORT=5000

USER appuser

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--chdir", "/app/src", "app:app"]

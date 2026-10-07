# Stage 1: Build dependencies
FROM python:3.11-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY application/requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Hardened Runtime Container
FROM python:3.11-slim AS runner

WORKDIR /app

# Non-root user creation
RUN groupadd -r devopsgroup && useradd -r -g devopsgroup -u 10001 devopsuser

# Copy python dependencies
COPY --from=builder /root/.local /home/devopsuser/.local
COPY application/src/ /app/src/

# Directory for transaction volume storage
RUN mkdir -p /var/log/app && chown -R devopsuser:devopsgroup /var/log/app /app

ENV PATH=/home/devopsuser/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1
ENV PORT=8080
ENV ENVIRONMENT=production

USER devopsuser

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "3", "--chdir", "/app/src", "app:app"]

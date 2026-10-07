#!/bin/bash
set -euo pipefail

echo "========================================================"
echo "   Enterprise DevSecOps Quality & Security Gate v2.5    "
echo "========================================================"

CRITICAL_VULNS=${1:-0}
HIGH_VULNS=${2:-0}
SECRET_LEAKS=${3:-0}

MAX_CRITICAL=0
MAX_HIGH=0
MAX_SECRETS=0

echo "[*] Checking Critical Vulnerabilities: $CRITICAL_VULNS (Allowed: $MAX_CRITICAL)"
echo "[*] Checking High Vulnerabilities:     $HIGH_VULNS (Allowed: $MAX_HIGH)"
echo "[*] Checking Leaked Secrets:           $SECRET_LEAKS (Allowed: $MAX_SECRETS)"

if [ "$CRITICAL_VULNS" -gt "$MAX_CRITICAL" ] || [ "$HIGH_VULNS" -gt "$MAX_HIGH" ] || [ "$SECRET_LEAKS" -gt "$MAX_SECRETS" ]; then
    echo "[-] Security Gate FAILED. Release rejected."
    exit 1
fi

echo "[+] Security Gate PASSED. Artifact approved for production deployment."
exit 0

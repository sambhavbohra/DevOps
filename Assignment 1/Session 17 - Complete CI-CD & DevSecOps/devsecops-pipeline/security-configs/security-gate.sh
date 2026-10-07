#!/bin/bash
set -euo pipefail

echo "===================================================="
echo "    DevSecOps Automated Quality & Security Gate     "
echo "===================================================="

CRITICAL_VULNS=${1:-0}
HIGH_VULNS=${2:-0}
SECRET_LEAKS=${3:-0}

MAX_ALLOWED_CRITICAL=0
MAX_ALLOWED_HIGH=2
MAX_ALLOWED_SECRETS=0

echo "[*] Checking Critical Vulnerabilities: $CRITICAL_VULNS (Allowed: $MAX_ALLOWED_CRITICAL)"
echo "[*] Checking High Vulnerabilities:     $HIGH_VULNS (Allowed: $MAX_ALLOWED_HIGH)"
echo "[*] Checking Secret Leaks:             $SECRET_LEAKS (Allowed: $MAX_ALLOWED_SECRETS)"

FAILED=0

if [ "$CRITICAL_VULNS" -gt "$MAX_ALLOWED_CRITICAL" ]; then
    echo "[-] Security Gate FAILED: Found $CRITICAL_VULNS Critical vulnerabilities."
    FAILED=1
fi

if [ "$HIGH_VULNS" -gt "$MAX_ALLOWED_HIGH" ]; then
    echo "[-] Security Gate FAILED: Found $HIGH_VULNS High vulnerabilities."
    FAILED=1
fi

if [ "$SECRET_LEAKS" -gt "$MAX_ALLOWED_SECRETS" ]; then
    echo "[-] Security Gate FAILED: Detected $SECRET_LEAKS leaked secrets."
    FAILED=1
fi

if [ "$FAILED" -eq 1 ]; then
    echo "[!] Deployment blocked by Security Gate. Fix issues before pushing."
    exit 1
fi

echo "[+] Security Gate PASSED: All security compliance standards met."
exit 0

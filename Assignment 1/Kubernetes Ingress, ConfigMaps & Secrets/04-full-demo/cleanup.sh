#!/usr/bin/env bash
D="$(dirname "$0")"
kubectl delete -f "$D/ingress.yaml"   --ignore-not-found
kubectl delete -f "$D/frontend.yaml"  --ignore-not-found
kubectl delete -f "$D/backend.yaml"   --ignore-not-found
kubectl delete -f "$D/secret.yaml"    --ignore-not-found
kubectl delete -f "$D/configmap.yaml" --ignore-not-found
echo "==> Teardown complete"

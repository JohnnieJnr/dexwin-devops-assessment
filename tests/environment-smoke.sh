#!/usr/bin/env bash
set -euo pipefail

cleanup() {
  if kind get clusters 2>/dev/null | grep -qx dexwin-devops-assessment; then
    ./scripts/reset.sh
  fi
}
trap cleanup EXIT

terraform version >/dev/null
./scripts/setup.sh

kubectl get namespace assessment
kubectl get deployment customer-api --namespace assessment
kubectl get service customer-api --namespace assessment

echo "assessment environment smoke test passed"

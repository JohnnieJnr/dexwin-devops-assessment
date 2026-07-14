#!/usr/bin/env bash
set -euo pipefail

cluster_name="dexwin-devops-assessment"
image_name="customer-api:assessment"

for command in docker kind kubectl; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "Missing required command: ${command}" >&2
    exit 1
  fi
done

if kind get clusters | grep -qx "${cluster_name}"; then
  echo "Cluster ${cluster_name} already exists; reusing it."
else
  kind create cluster --name "${cluster_name}" --config kind-config.yaml
fi

docker build --tag "${image_name}" ./app
kind load docker-image "${image_name}" --name "${cluster_name}"
kubectl apply -f kubernetes/

echo
echo "Assessment environment applied. The starting deployment is intentionally unhealthy."
echo "Inspect it with ./scripts/status.sh and test it with ./scripts/verify.sh."

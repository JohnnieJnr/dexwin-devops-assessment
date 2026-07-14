#!/usr/bin/env bash
set -euo pipefail

namespace="assessment"

kubectl get deployments,pods,services,endpointslices -n "${namespace}" -o wide

echo
kubectl get events -n "${namespace}" --sort-by='.lastTimestamp'

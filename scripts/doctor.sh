#!/usr/bin/env bash
set -u

cluster_name="dexwin-devops-assessment"
local_port="18080"
failure_count=0
warning_count=0

pass() {
  printf 'PASS  %s\n' "$1"
}

warn() {
  printf 'WARN  %s\n' "$1"
  warning_count=$((warning_count + 1))
}

fail() {
  printf 'FAIL  %s\n' "$1" >&2
  failure_count=$((failure_count + 1))
}

command_version() {
  local command_name="$1"

  case "${command_name}" in
    docker) docker --version 2>/dev/null | head -n 1 ;;
    kind) kind version 2>/dev/null | head -n 1 ;;
    kubectl) kubectl version --client 2>/dev/null | head -n 1 ;;
    curl) curl --version 2>/dev/null | head -n 1 ;;
  esac
}

print_remediation() {
  cat <<'EOF'

Local installation help:
  macOS:   install and start Docker Desktop, then run: brew install kind kubectl
  Linux:   install Docker Engine, kind, and kubectl from their official documentation
  Windows: use the provided GitHub Codespace, or WSL 2 with Docker Desktop integration

Alternatively, open this repository in GitHub Codespaces to use the prepared environment.
EOF
}

printf 'Checking Dexwin DevOps assessment prerequisites...\n\n'

for command_name in docker kind kubectl curl; do
  if command -v "${command_name}" >/dev/null 2>&1; then
    version="$(command_version "${command_name}")"
    pass "${command_name}${version:+: ${version}}"
  else
    fail "Missing required command: ${command_name}"
  fi
done

if ((BASH_VERSINFO[0] >= 4)); then
  pass "Bash ${BASH_VERSION}"
else
  warn "Bash ${BASH_VERSION} is older than the tested Bash 4+ environment."
fi

docker_ready=0
if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    docker_ready=1
    pass "Docker daemon is responding."
  else
    fail "Docker is installed, but the daemon is not responding. Start Docker and retry."
  fi
fi

if ((docker_ready == 1)) && command -v kind >/dev/null 2>&1; then
  clusters="$(kind get clusters 2>/dev/null || true)"
  if grep -qx "${cluster_name}" <<<"${clusters}"; then
    warn "Cluster ${cluster_name} already exists and setup will reuse it. Run ./scripts/reset.sh for a clean start."
  else
    pass "No stale ${cluster_name} cluster found."
  fi
fi

if [[ "${DOCTOR_SKIP_PORT_CHECK:-0}" != "1" ]]; then
  if command -v lsof >/dev/null 2>&1; then
    if lsof -nP -iTCP:"${local_port}" -sTCP:LISTEN >/dev/null 2>&1; then
      fail "Port ${local_port} is already in use. Stop that process before running ./scripts/verify.sh."
    else
      pass "Port ${local_port} is available."
    fi
  elif command -v ss >/dev/null 2>&1; then
    if ss -ltn 2>/dev/null | awk '{print $4}' | grep -Eq "(^|:)${local_port}$"; then
      fail "Port ${local_port} is already in use. Stop that process before running ./scripts/verify.sh."
    else
      pass "Port ${local_port} is available."
    fi
  else
    warn "Could not inspect port ${local_port}; neither lsof nor ss is available."
  fi
fi

if command -v terraform >/dev/null 2>&1; then
  pass "Optional Terraform tool: $(terraform version 2>/dev/null | head -n 1)"
else
  printf 'INFO  Terraform is not installed; it is required only for the Terraform extension.\n'
fi

printf '\n'
if ((failure_count > 0)); then
  printf 'Prerequisite check failed with %d problem(s).\n' "${failure_count}" >&2
  print_remediation >&2
  exit 1
fi

printf 'Assessment prerequisites are ready.'
if ((warning_count > 0)); then
  printf ' Review the %d warning(s) above.' "${warning_count}"
fi
printf '\n'

#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
doctor="${repo_root}/scripts/doctor.sh"
test_root="$(mktemp -d)"
trap 'rm -rf "${test_root}"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  [[ "${haystack}" == *"${needle}"* ]] || fail "expected output to contain: ${needle}"
}

make_command() {
  local name="$1"
  local body="$2"
  printf '#!/usr/bin/env bash\n%s\n' "${body}" >"${test_root}/${name}"
  chmod +x "${test_root}/${name}"
}

run_doctor() {
  PATH="${test_root}:/usr/bin:/bin" DOCTOR_SKIP_PORT_CHECK=1 "${doctor}" 2>&1
}

make_command docker '[[ "${1:-}" == "info" ]] && exit 0; echo "Docker version 28.0.0"'
make_command kind '[[ "${1:-}" == "get" ]] && exit 0; echo "kind v0.32.0"'
make_command kubectl 'echo "Client Version: v1.36.1"'
make_command curl 'echo "curl 8.7.1"'

output="$(run_doctor)" || fail "doctor should pass when prerequisites are healthy"
assert_contains "${output}" "Assessment prerequisites are ready."

rm "${test_root}/kind"
if output="$(run_doctor)"; then
  fail "doctor should fail when a required command is missing"
fi
assert_contains "${output}" "Missing required command: kind"

make_command kind '[[ "${1:-}" == "get" ]] && exit 0; echo "kind v0.32.0"'
make_command docker '[[ "${1:-}" == "info" ]] && { echo "daemon unavailable" >&2; exit 1; }; echo "Docker version 28.0.0"'
if output="$(run_doctor)"; then
  fail "doctor should fail when the Docker daemon is unavailable"
fi
assert_contains "${output}" "Docker is installed, but the daemon is not responding."

echo "doctor tests passed"

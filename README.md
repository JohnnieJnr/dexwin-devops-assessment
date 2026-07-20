# Dexwin DevOps assessment

This repository contains a small customer-facing API and the infrastructure used to run it. Treat it as a production system you have just inherited.

## Scenario

Version 2 of the API was deployed to Kubernetes. The workload is not reliably serving requests.

Your task is to:

1. Establish the symptoms and likely blast radius.
2. State your hypotheses before changing the system.
3. Gather evidence from the source and cluster.
4. Identify the root cause or causes.
5. Correct the source-controlled configuration.
6. Deploy the correction and demonstrate end-to-end recovery.
7. Explain rollback, monitoring, and how you would prevent recurrence.

There is no published defect count. Prioritize restoring service safely before optional hardening.

## Tool policy

The Kubernetes incident is open-book. You may use official documentation and ordinary web search, but not AI assistance during this section. We care about your reasoning and evidence, not whether you remember every command.

Your interviewer may allow AI during the extension task. If so, you remain responsible for reviewing, explaining, and verifying everything it produces.

## Choose your environment

### GitHub Codespaces (recommended)

[Open the assessment in GitHub Codespaces](https://codespaces.new/dexwin-tech-ltd/dexwin-devops-assessment)

Select the branch supplied by your interviewer. The prepared environment includes Docker, `kind`, `kubectl`, `curl`, Bash, and Terraform. You need only a GitHub account and a browser. When the terminal is ready, confirm the environment:

```bash
./scripts/doctor.sh
```

Do not run `setup.sh` until your interviewer starts the assessment.

### Local environment

Run the assessment locally if you prefer. You need:

- Docker with the daemon running
- [`kind` v0.32.0](https://kind.sigs.k8s.io/)
- `kubectl` v1.36.x
- `curl`
- Bash 4 or later recommended

Optional for the extension:

- Terraform 1.6 or later

Check the complete local environment before the interview:

```bash
./scripts/doctor.sh
```

The doctor does not install software or change your machine. It reports missing tools, an unavailable Docker daemon, a stale assessment cluster, and a conflicting verification port, with remediation guidance.

## Start the environment

```bash
./scripts/setup.sh
```

The script creates a disposable local cluster named `dexwin-devops-assessment`, builds and loads the API image, and applies the Kubernetes assets.

Inspect the starting state with:

```bash
./scripts/status.sh
```

Run the end-to-end service check with:

```bash
./scripts/verify.sh
```

The initial verification is expected to fail. Do not modify the application merely to make the check pass unless evidence shows the application itself is defective.

## Repository structure

| Path | Purpose |
| --- | --- |
| `app/` | Small Node.js API and its container image. |
| `kubernetes/` | Namespace, configuration, Deployment, and Service. |
| `scripts/` | Environment setup, status, verification, and reset helpers. |
| `.devcontainer/` | Reproducible Codespaces and Dev Container tooling. |
| `extensions/terraform/` | Optional infrastructure-as-code extension. |
| `.github/workflows/release.yml` | Optional CI/CD extension. |

## Extension

### Reverse Proxy
Assess the accessibility of the service to the open web, and recommend your changes based on best practice.

Your interviewer will ask you to choose one option.

### Terraform

Improve `extensions/terraform` so that it:

- Validates important assumptions.
- Prevents accidental public exposure.
- Includes a meaningful Terraform test or check.

Be prepared to explain state, secrets, plan review, deployment, and rollback. Do not create paid or remote infrastructure.

### CI/CD

Improve `.github/workflows/release.yml` so that it:

- Validates the application and deployment assets.
- Builds and scans an immutable image.
- Uses an appropriate authentication approach.
- Controls production deployment.
- Verifies the release and supports rollback.

The workflow is an assessment artifact; do not connect it to a real production environment.

## Reset

Delete the disposable cluster with:

```bash
./scripts/reset.sh
```

## Submission

Leave your changes on the branch supplied by the interviewer. Be prepared to walk through:

- The evidence you collected.
- The root causes you identified.
- The changes you made.
- How you verified recovery.
- Remaining risks and work you would do next.

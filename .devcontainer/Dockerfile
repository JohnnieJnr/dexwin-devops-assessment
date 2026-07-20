FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG KIND_VERSION=v0.32.0
ARG KUBECTL_VERSION=v1.36.1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install --yes --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

RUN architecture="$(dpkg --print-architecture)" \
    && case "${architecture}" in \
         amd64) binary_architecture="amd64" ;; \
         arm64) binary_architecture="arm64" ;; \
         *) echo "Unsupported architecture: ${architecture}" >&2; exit 1 ;; \
       esac \
    && curl --fail --location --silent --show-error \
         --output /tmp/kind "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${binary_architecture}" \
    && curl --fail --location --silent --show-error \
         --output /tmp/kind.sha256sum "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${binary_architecture}.sha256sum" \
    && echo "$(cat /tmp/kind.sha256sum)  /tmp/kind" | sha256sum --check --status \
    && install -m 0755 /tmp/kind /usr/local/bin/kind \
    && curl --fail --location --silent --show-error \
         --output /tmp/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${binary_architecture}/kubectl" \
    && curl --fail --location --silent --show-error \
         --output /tmp/kubectl.sha256 "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${binary_architecture}/kubectl.sha256" \
    && echo "$(cat /tmp/kubectl.sha256)  /tmp/kubectl" | sha256sum --check --status \
    && install -m 0755 /tmp/kubectl /usr/local/bin/kubectl \
    && rm -f /tmp/kind /tmp/kind.sha256sum /tmp/kubectl /tmp/kubectl.sha256

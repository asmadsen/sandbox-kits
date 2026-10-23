# syntax=docker/dockerfile:1
FROM docker/sandbox-templates:opencode

# OpenChamber needs Node >= 24.14; the template ships Node 22, so we install a
# pinned Node 24 side-by-side and put it first on PATH.
ARG TARGETARCH
ARG NODE_VERSION=24.22.1
ARG OPENCODE_VERSION=2.1.3
ARG OPENCHAMBER_VERSION=2.5.1

USER root

RUN set -eux; \
    case "${TARGETARCH:-$(dpkg --print-architecture)}" in \
      amd64) node_arch=x64 ;; \
      arm64) node_arch=arm64 ;; \
      *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    tmp="$(mktemp -d)"; \
    tarball="node-v${NODE_VERSION}-linux-${node_arch}.tar.gz"; \
    curl -fsSLo "${tmp}/${tarball}" "https://nodejs.org/dist/v${NODE_VERSION}/${tarball}"; \
    curl -fsSLo "${tmp}/SHASUMS256.txt" "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt"; \
    (cd "${tmp}" && grep " ${tarball}\$" SHASUMS256.txt | sha256sum -c -); \
    mkdir -p /usr/local/lib/nodejs; \
    tar -xzf "${tmp}/${tarball}" -C /usr/local/lib/nodejs; \
    node_dir="/usr/local/lib/nodejs/node-v${NODE_VERSION}-linux-${node_arch}/bin"; \
    ln -sfn "${node_dir}/node" /usr/local/bin/node; \
    ln -sfn "${node_dir}/npm" /usr/local/bin/npm; \
    ln -sfn "${node_dir}/npx" /usr/local/bin/npx; \
    rm -rf "${tmp}"; \
    node --version; npm --version

USER agent

# The template ships the v1 OpenCode package; this kit runs the v2 CLI that
# OpenChamber 2.5.x is built against.
RUN npm uninstall -g opencode-ai >/dev/null 2>&1 || true \
    && npm install -g "@opencode/cli@${OPENCODE_VERSION}" "@openchamber/web@${OPENCHAMBER_VERSION}" \
    && npm cache clean --force

# Updates are a kit change, not something the sandbox does to itself.
ENV OPENCODE_DISABLE_AUTOUPDATE=1

WORKDIR /home/agent/workspace

# Loopback only: the OpenChamber desktop app reaches this through its SSH
# Remote Instance, so the server is never published or exposed on the LAN.
ENTRYPOINT ["openchamber", "--foreground", "--host", "127.0.0.1", "--port", "3000"]
CMD []

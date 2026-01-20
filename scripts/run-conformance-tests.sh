#!/bin/bash
# © 2025 Platform Engineering Labs Inc.
# SPDX-License-Identifier: FSL-1.1-ALv2
#
# Script to run conformance tests against a specific version of formae.
# Downloads the formae binary to a temporary directory and runs tests.
#
# Usage:
#   ./scripts/run-conformance-tests.sh [VERSION]
#
# Arguments:
#   VERSION - Optional formae version (e.g., 0.76.0). Defaults to "latest".
#
# Environment variables:
#   FORMAE_INSTALL_PREFIX - Installation directory (default: temp directory)

set -euo pipefail

VERSION="${1:-latest}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Create temp directory for formae binary
if [[ -n "${FORMAE_INSTALL_PREFIX:-}" ]]; then
    INSTALL_DIR="${FORMAE_INSTALL_PREFIX}"
    mkdir -p "${INSTALL_DIR}"
    echo "Using specified install directory: ${INSTALL_DIR}"
else
    INSTALL_DIR=$(mktemp -d -t formae-conformance-XXXXXX)
    echo "Using temp directory: ${INSTALL_DIR}"
    trap "rm -rf ${INSTALL_DIR}" EXIT
fi

# Download formae binary
echo "Downloading formae ${VERSION}..."
if [[ "${VERSION}" == "latest" ]]; then
    /bin/bash -c "$(curl -fsSL https://hub.platform.engineering/setup/formae.sh)" -- -y -p "${INSTALL_DIR}"
else
    /bin/bash -c "$(curl -fsSL https://hub.platform.engineering/setup/formae.sh)" -- -y -v "${VERSION}" -p "${INSTALL_DIR}"
fi

# Find the formae binary (setup.sh installs to ${INSTALL_DIR}/formae/bin/formae)
FORMAE_BINARY="${INSTALL_DIR}/formae/bin/formae"
if [[ ! -x "${FORMAE_BINARY}" ]]; then
    # Fallback: check root directory
    if [[ -x "${INSTALL_DIR}/formae" ]]; then
        FORMAE_BINARY="${INSTALL_DIR}/formae"
    else
        echo "Error: formae binary not found in ${INSTALL_DIR}"
        ls -laR "${INSTALL_DIR}" 2>/dev/null || ls -la "${INSTALL_DIR}"
        exit 1
    fi
fi

echo "Using formae binary: ${FORMAE_BINARY}"
"${FORMAE_BINARY}" version

# Export FORMAE_BINARY for the tests
export FORMAE_BINARY

# Run conformance tests
echo ""
echo "Running conformance tests..."
cd "${PROJECT_ROOT}"
go test -tags=conformance -v -timeout 30m ./...

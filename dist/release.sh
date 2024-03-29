#!/usr/bin/env bash

# Get directory of this script
SD=$(dirname "$0")

# Include common variables
source ${SD}/release-common.env

MACHINE_TYPE="${1}"
MACHINE_ID="${2}"

[[ -z "${MACHINE_ID}" ]] && {
    echo "Usage: $0 <machine-type> <machine-id>"
    exit 1
}

[[ -z "${MACHINE_TYPE}" ]] && {
    echo "Usage: $0 <machine-type> <machine-id>"
    exit 1
}

MACHINE_ENV="${SD}/release-${MACHINE_TYPE}.env"

[[ ! -f "${MACHINE_ENV}" ]] && {
    echo "Machine type not found: ${MACHINE_TYPE}"
    exit 1
}

# Include machine-specific variables
source ${MACHINE_ENV}

# Source build function
source ${SD}/functions.sh

# Build the release package for this machine
build_release "${MACHINE_TYPE}" "${MACHINE_ID}"
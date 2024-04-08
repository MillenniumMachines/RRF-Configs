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

# Source build function
source ${SD}/functions.sh

make_cache_dir

# Build the release package for this machine
load_release "${MACHINE_TYPE}" "${MACHINE_ID}"
build_release

# No release notes for individual releases
rm -f "${RNOTES_PATH}"

clean_cache_dir
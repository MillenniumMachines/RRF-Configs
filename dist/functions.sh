#!/usr/bin/env bash

function build_release() {
    MACHINE_TYPE="${1}"
    MACHINE_ID="${2}"

    MACHINE_DIR="${MACHINE_TYPE}/${MACHINE_ID}"
    COMMON_DIR="${MACHINE_TYPE}/common"

    # Abort if machine dir does not exist
    [[ ! -d "${WD}/${MACHINE_DIR}" ]] && {
        echo "Machine directory not found: ${MACHINE_DIR}"
        exit 1
    }

    MACHINE_NAME="${MACHINE_DIR//\//-}"

    ZIP_PATH="${DIST_DIR}/${MACHINE_NAME}-${COMMIT_ID}.zip"

    [[ -f "${ZIP_PATH}" ]] && rm "${ZIP_PATH}"

    echo "Building release ${COMMIT_ID} for ${MACHINE_NAME}..."

    # Create temporary directory
    TMP_DIR=$(mktemp -d -t rrf-config-XXXXX)

    # Make stub folder-structure
    mkdir -p "${TMP_DIR}/${SYS_DIR}" "${TMP_DIR}/${WWW_DIR}" "${TMP_DIR}/${FIRMWARE_DIR}" "${TMP_DIR}/${MACRO_DIR}" "${TMP_DIR}/${GCODE_DIR}"

    # Copy common config files to correct location
    ${SYNC_CMD} "${WD}/${COMMON_DIR}/" "${TMP_DIR}/${SYS_DIR}/"

    # Copy machine-specific config files to correct location
    ${SYNC_CMD} "${WD}/${MACHINE_DIR}/" "${TMP_DIR}/${SYS_DIR}/"

    # Remove example files that have been overridden by the
    # machine-specific config files.
    find "${TMP_DIR}/${SYS_DIR}" -name '*.g' -print | xargs -n 1 bash -c '[[ -f "${0}.example" ]] && rm ${0}.example && echo "Removed overridden ${0}.example"'

    # Copy firmware files to correct location
    wget -O "${TMP_DIR}/${RRF_FIRMWARE_DST_1_NAME}" "${RRF_FIRMWARE_URL}"
    wget -O "${TMP_DIR}/${FIRMWARE_DIR}/${WIFI_FIRMWARE_DST_NAME}" "${WIFI_FIRMWARE_URL}"

    # Copy RRF firmware to filename required for first boot flash.
    cp "${TMP_DIR}/${RRF_FIRMWARE_DST_1_NAME}" "${TMP_DIR}/${RRF_FIRMWARE_DST_2_NAME}"

    # Extract DWC files to correct location
    wget -O "${TMP_DIR}/dwc.zip" "${DWC_URL}"
    unzip -q "${TMP_DIR}/dwc.zip" -d "${TMP_DIR}/${WWW_DIR}"
    rm "${TMP_DIR}/dwc.zip"

    # Create release zip
    cd "${TMP_DIR}"
    zip -r "${ZIP_PATH}" *
    cd "${WD}"
    rm -rf "${TMP_DIR}"
}
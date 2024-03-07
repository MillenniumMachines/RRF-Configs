#!/usr/bin/env bash

# Get directory of this script
SD=$(dirname "$0")

[[ ! -f ${SD}/release-common.env ]] && echo "Error: release-common.env not found!" && exit 1
# Include common variables
source ${SD}/release-common.env

COMMON_DIR="milo/common"

MACHINE_DIR="milo/ldo-kit-fly-cdyv3"
MACHINE_NAME="${MACHINE_DIR//\//-}"

echo "Building release ${COMMIT_ID} for ${MACHINE_NAME}..."

# Generate download URLs for firmwares and DWC
TG_RELEASE_URL="${TEAMGLOOMY_RELEASES}/v3.5.0-rc.3%2B101"
DUET_RELEASE_URL="${DUET_RELEASES}/3.5.0-rc.3"

RRF_FIRMWARE_URL="${TG_RELEASE_URL}/firmware-stm32f4-wifi-3.5.0-rc.3+101.bin"
RRF_FIRMWARE_NAME=firmware.bin
WIFI_FIRMWARE_URL="${TG_RELEASE_URL}/DuetWiFiServer_32-2.1beta6-01.bin"
WIFI_FIRMWARE_NAME=DuetWiFiServer.bin

DWC_URL="${DUET_RELEASE_URL}/DuetWebControl-SD.zip"

# Create temporary directory
TMP_DIR=$(mktemp -d -t rrf-config-XXXXX)

# Make stub folder-structure
mkdir -p "${TMP_DIR}/${SYS_DIR}" "${TMP_DIR}/${WWW_DIR}" "${TMP_DIR}/${FIRMWARE_DIR}" "${TMP_DIR}/${MACRO_DIR}"

# Copy common config files to correct location
${SYNC_CMD} "${WD}/${COMMON_DIR}/" "${TMP_DIR}/${SYS_DIR}/"

# Copy machine-specific config files to correct location
${SYNC_CMD} "${WD}/${MACHINE_DIR}/" "${TMP_DIR}/${SYS_DIR}/"

# Copy firmware files to correct location
wget -O "${TMP_DIR}/${RRF_FIRMWARE_NAME}" "${RRF_FIRMWARE_URL}"
wget -O "${TMP_DIR}/${FIRMWARE_DIR}/${WIFI_FIRMWARE_NAME}" "${WIFI_FIRMWARE_URL}"

# Extract DWC files to correct location
wget -O "${TMP_DIR}/dwc.zip" "${DWC_URL}"
unzip -q "${TMP_DIR}/dwc.zip" -d "${TMP_DIR}/${WWW_DIR}"
rm "${TMP_DIR}/dwc.zip"

# Create release zip
cd "${TMP_DIR}"
zip -r "${DIST_DIR}/${MACHINE_NAME}-${COMMIT_ID}.zip" *
cd "${WD}"
rm -rf "${TMP_DIR}"

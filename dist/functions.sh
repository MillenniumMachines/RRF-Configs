#!/usr/bin/env bash

function make_cache_dir() {
	[[ -z "${CACHE_DIR}" ]] && {
		CACHE_DIR=$(mktemp -d -t rrf-config-cache-XXXXX)
	}
}

function clean_cache_dir() {
	[[ -d "${CACHE_DIR}" ]] && {
		rm -rf "${CACHE_DIR}"
	}
}

function load_release() {
	MACHINE_TYPE="${1}"
	MACHINE_ID="${2}"

	[[ -z "${MACHINE_ID}" ]] && {
		echo "Usage: $0 <machine-type> <machine-id>"
		clean_cache_dir
		exit 1
	}

	[[ -z "${MACHINE_TYPE}" ]] && {
		echo "Usage: $0 <machine-type> <machine-id>"
		clean_cache_dir
		exit 1
	}

	MACHINE_ID_ENV="${SD}/../${MACHINE_TYPE}/${MACHINE_ID}/build.env"

	[[ -f "${MACHINE_ID_ENV}" ]] && {
		echo "Machine build env found: ${MACHINE_ID}";
		source ${MACHINE_ID_ENV};
	}

	# A machine type can have a single base type that it extends.
	# This is useful for machines that are very similar, but have
	# a few differences.
	BASE_DIR="${SD}/../${MACHINE_TYPE}/${BASE_TYPE}"

	[[ -d "${BASE_DIR}" ]] && {
		[[ -f "${BASE_ENV}" ]] && {
			echo "Base build env found: ${BASE_TYPE}";
		}
	}

	MACHINE_ENV="${SD}/release-${MACHINE_TYPE}.env"

	[[ ! -f "${MACHINE_ENV}" ]] && {
		echo "Machine type not found: ${MACHINE_TYPE}"
		clean_cache_dir
		exit 1
	}

	# Include machine-specific variables
	source ${MACHINE_ENV}

	BOARD_TYPE_ENV="${SD}/release-${RRF_BOARD_TYPE}.env"

	[[ -f "${BOARD_TYPE_ENV}" ]] && {
		echo "Board build env found: ${RRF_BOARD_TYPE}"
		source ${BOARD_TYPE_ENV}
	}

	MACHINE_DIR="${MACHINE_TYPE}/${MACHINE_ID}"
	COMMON_DIR="${MACHINE_TYPE}/common"

	# Abort if machine dir does not exist
	[[ ! -d "${WD}/${MACHINE_DIR}" ]] && {
		echo "Machine directory not found: ${MACHINE_DIR}"
		clean_cache_dir
		exit 1
	}

	MACHINE_NAME="${MACHINE_DIR//\//-}"

	ZIP_PATH="${DIST_DIR}/rrf-${MACHINE_NAME}-${COMMIT_ID}"
}

function build_release() {

	[[ -f "${ZIP_PATH}" ]] && rm "${ZIP_PATH}"

	echo "Building release ${COMMIT_ID} for ${MACHINE_NAME}..."

	# Create temporary directory
	TMP_DIR=$(mktemp -d -t rrf-config-XXXXX)

	# Make stub folder-structure
	mkdir -p "${TMP_DIR}/${SYS_DIR}" "${TMP_DIR}/${WWW_DIR}" "${TMP_DIR}/${FIRMWARE_DIR}" "${TMP_DIR}/${MACRO_DIR}" "${TMP_DIR}/${GCODE_DIR}"

	# Copy common config files to correct location
	${SYNC_CMD} "${WD}/${COMMON_DIR}/" "${TMP_DIR}/${SYS_DIR}/"

	# Copy base config files to correct location
	[[ ! -z "${BASE_DIR}" ]] && [[ -d "${BASE_DIR}" ]] && {
		${SYNC_CMD} "${WD}/${BASE_DIR}/" "${TMP_DIR}/${SYS_DIR}/"
	}

	# Copy machine-specific config files to correct location
	${SYNC_CMD} "${WD}/${MACHINE_DIR}/" "${TMP_DIR}/${SYS_DIR}/"

	# Remove example files that have been overridden by the
	# machine-specific config files.
	find "${TMP_DIR}/${SYS_DIR}" -name '*.g' -print | xargs -n 1 bash -c '[[ -f "${0}.example" ]] && rm ${0}.example && echo "Removed overridden ${0}.example"'

	# RRF STM32 is now released as a single Zip file
	# Copy firmware files to correct location
	[[ ! -f "${CACHE_DIR}/${RRF_FIRMWARE_ZIP_NAME}" ]] && {
		wget -nv -O "${CACHE_DIR}/${RRF_FIRMWARE_ZIP_NAME}" "${RRF_FIRMWARE_URL}" || { echo "Failed to download ${RRF_FIRMWARE_URL}"; exit 1; }
	}

	[[ ! -f "${CACHE_DIR}/${DWC_DST_NAME}" ]] && {
		wget -nv -O "${CACHE_DIR}/${DWC_DST_NAME}" "${DWC_URL}" || { echo "Failed to download ${DWC_URL}"; exit 1; }
	}

	# [[ ! -f "${CACHE_DIR}/${MOS_DST_NAME}" ]] && {
	# 	wget -nv -O "${CACHE_DIR}/${MOS_DST_NAME}" "${MOS_URL}" || { echo "Failed to download ${MOS_URL}"; exit 1; }
	# }

	# Unzip RRF firmware to cache dir
	unzip -o -q "${CACHE_DIR}/${RRF_FIRMWARE_ZIP_NAME}" -d "${CACHE_DIR}/"

	# Copy RRF firmware to both filenames.
	cp "${CACHE_DIR}/${RRF_FIRMWARE_SRC_NAME}" "${TMP_DIR}/${RRF_FIRMWARE_DST_NAME}"
	cp "${CACHE_DIR}/${RRF_FIRMWARE_SRC_NAME}" "${TMP_DIR}/${FIRMWARE_DIR}"

	# Copy WiFi firmware to correct location
	cp "${CACHE_DIR}/${WIFI_FIRMWARE_SRC_NAME}" "${TMP_DIR}/${FIRMWARE_DIR}/${WIFI_FIRMWARE_DST_NAME}"

	# Replace WiFi firmware type variable.
	sed -si -e "s/%%WIFI_FIRMWARE_TYPE%%/${WIFI_FIRMWARE_DST_NAME}/g" ${TMP_DIR}/${SYS_DIR}/*.g

	# Extract DWC files to correct location
	unzip -o -q "${CACHE_DIR}/${DWC_DST_NAME}" -d "${TMP_DIR}/${WWW_DIR}"

	[[ ! -z "${ENABLE_RNOTES}" ]] && {
		cat <<-EOF >>"${RNOTES_PATH}"
		### ${MACHINE_ID^^}

		#### Notes

		${BOARD_NOTES}

		#### Contains

		| Component                | Source File(s)                           | Version         |
		| ------------------------ | ---------------------------------------- | --------------- |
		| RepRapFirmware           | \`${RRF_FIRMWARE_SRC_NAME}\`             | ${TG_RELEASE}   |
		| DuetWiFiServer           | \`${WIFI_FIRMWARE_SRC_NAME}\`            | ${TG_RELEASE}   |
		| DuetWebControl           | \`${DWC_SRC_NAME}\`                      | ${DUET_RELEASE} |
		| Configuration            | \`${COMMON_DIR}\` and \`${MACHINE_DIR}\` | ${COMMIT_ID}    |

		---

		EOF
	}

	# | Optionally, MillenniumOS | \`${MOS_SRC_NAME}\`                      | ${MOS_RELEASE}  |

	# Create release zip with default files
	cd "${TMP_DIR}"
	zip -qr "${ZIP_PATH}.zip" *
	cd "${WD}"

	# TEMP: Do not include MillenniumOS in the release zip.
	# MillenniumOS is now built as a UI plugin, and I have not
	# yet worked out how to include it in an sd-card style zip.
	# unzip -o -q "${CACHE_DIR}/${MOS_DST_NAME}" -d "${TMP_DIR}/"

	# cd "${TMP_DIR}"
	# zip -qr "${ZIP_PATH}-with-mos.zip" *
	# cd "${WD}"

	rm -rf "${TMP_DIR}"
}
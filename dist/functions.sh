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

	# Copy machine-specific config files to correct location
	${SYNC_CMD} "${WD}/${MACHINE_DIR}/" "${TMP_DIR}/${SYS_DIR}/"

	# Remove example files that have been overridden by the
	# machine-specific config files.
	find "${TMP_DIR}/${SYS_DIR}" -name '*.g' -print | xargs -n 1 bash -c '[[ -f "${0}.example" ]] && rm ${0}.example && echo "Removed overridden ${0}.example"'

	# Copy firmware files to correct location
	[[ ! -f "${CACHE_DIR}/${RRF_FIRMWARE_SRC_NAME}" ]] && {
		wget -O "${CACHE_DIR}/${RRF_FIRMWARE_SRC_NAME}" "${RRF_FIRMWARE_URL}"
	}

	[[ ! -f "${CACHE_DIR}/${WIFI_FIRMWARE_SRC_NAME}" ]] && {
		wget -O "${CACHE_DIR}/${WIFI_FIRMWARE_SRC_NAME}" "${WIFI_FIRMWARE_URL}"
	}

	[[ ! -f "${CACHE_DIR}/${DWC_DST_NAME}" ]] && {
		wget -O "${CACHE_DIR}/${DWC_DST_NAME}" "${DWC_URL}"
	}

	[[ ! -f "${CACHE_DIR}/${MOS_DST_NAME}" ]] && {
		wget -O "${CACHE_DIR}/${MOS_DST_NAME}" "${MOS_URL}"
	}

	# Copy RRF firmware to both filenames.
	cp "${CACHE_DIR}/${RRF_FIRMWARE_SRC_NAME}" "${TMP_DIR}/${RRF_FIRMWARE_DST_1_NAME}"
	cp "${CACHE_DIR}/${RRF_FIRMWARE_SRC_NAME}" "${TMP_DIR}/${RRF_FIRMWARE_DST_2_NAME}"

	# Copy WiFi firmware to correct location
	cp "${CACHE_DIR}/${WIFI_FIRMWARE_SRC_NAME}" "${TMP_DIR}/${FIRMWARE_DIR}/${WIFI_FIRMWARE_DST_NAME}"

	# Extract DWC files to correct location
	unzip -o -q "${CACHE_DIR}/${DWC_DST_NAME}" -d "${TMP_DIR}/${WWW_DIR}"

	[[ ! -z "${ENABLE_RNOTES}" ]] && {
		cat <<-EOF >>"${RNOTES_PATH}"
		## ${MACHINE_ID^^}
		* **RepRapFirmware**: [${RRF_FIRMWARE_SRC_NAME}](${RRF_FIRMWARE_URL})
		* **DuetWiFiServer**: [${WIFI_FIRMWARE_SRC_NAME}](${WIFI_FIRMWARE_URL})
		* **DuetWebControl**: [${DWC_SRC_NAME}](${DWC_URL})
		* **Optionally, MillenniumOS**: [${MOS_SRC_NAME}](${MOS_URL})

		---

		EOF
	}

	# Create release zip with default files
	cd "${TMP_DIR}"
	zip -r "${ZIP_PATH}.zip" *
	cd "${WD}"

	unzip -o -q "${CACHE_DIR}/${MOS_DST_NAME}" -d "${TMP_DIR}/"

	cd "${TMP_DIR}"
	zip -r "${ZIP_PATH}-with-mos.zip" *
	cd "${WD}"

	rm -rf "${TMP_DIR}"
}
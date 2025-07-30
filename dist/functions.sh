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
	[[ ! -z "${BASE_TYPE}" ]] && {
		echo "Base build env found: ${BASE_TYPE}";
		BASE_DIR="${SD}/../${MACHINE_TYPE}/${BASE_TYPE}"
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

function generate_dwc_plugins_json() {
	local MOS_EXTRACT_DIR="$1"
	local PLUGIN_JSON_PATH="${MOS_EXTRACT_DIR}/plugin.json"
	local DWC_PLUGINS_JSON_PATH="${TMP_DIR}/${SYS_DIR}/dwc-plugins.json"

	if [[ ! -f "${PLUGIN_JSON_PATH}" ]]; then
		echo "Error: plugin.json not found in ${MOS_EXTRACT_DIR}"
		exit 1
	fi

	echo "Generating dwc-plugins.json from ${PLUGIN_JSON_PATH}"

	# Extract plugin metadata from plugin.json
	local PLUGIN_ID=$(jq -r '.id // empty' "${PLUGIN_JSON_PATH}")
	local PLUGIN_NAME=$(jq -r '.name // .id // empty' "${PLUGIN_JSON_PATH}")
	local PLUGIN_AUTHOR=$(jq -r '.author // "Unknown"' "${PLUGIN_JSON_PATH}")
	local PLUGIN_VERSION=$(jq -r '.version // "unknown"' "${PLUGIN_JSON_PATH}")
	local PLUGIN_LICENSE=$(jq -r '.license // "GPL-3.0-or-later"' "${PLUGIN_JSON_PATH}")
	local PLUGIN_HOMEPAGE=$(jq -r '.homepage // ""' "${PLUGIN_JSON_PATH}")
	local DWC_VERSION=$(jq -r '.dwcVersion // "3.6"' "${PLUGIN_JSON_PATH}")
	local RRF_VERSION=$(jq -r '.rrfVersion // "3.6"' "${PLUGIN_JSON_PATH}")

	if [[ -z "${PLUGIN_ID}" ]]; then
		echo "Error: Could not extract plugin ID from ${PLUGIN_JSON_PATH}"
		exit 1
	fi

	echo "Processing plugin: ${PLUGIN_ID} v${PLUGIN_VERSION}"

	# Collect DWC files (files in dwc directory)
	local DWC_FILES=()
	if [[ -d "${MOS_EXTRACT_DIR}/dwc" ]]; then
		while IFS= read -r -d '' file; do
			local relative_path="${file#${MOS_EXTRACT_DIR}/dwc/}"
			DWC_FILES+=("$relative_path")
		done < <(find "${MOS_EXTRACT_DIR}/dwc" -type f -print0)
	fi

	# Collect SD files (files in sd directory)
	local SD_FILES=()
	if [[ -d "${MOS_EXTRACT_DIR}/sd" ]]; then
		while IFS= read -r -d '' file; do
			local relative_path="${file#${MOS_EXTRACT_DIR}/sd/}"
			SD_FILES+=("$relative_path")
		done < <(find "${MOS_EXTRACT_DIR}/sd" -type f -print0)
	fi

	# Create the JSON structure using jq
	jq -n \
		--arg plugin_id "${PLUGIN_ID}" \
		--arg name "${PLUGIN_NAME}" \
		--arg author "${PLUGIN_AUTHOR}" \
		--arg version "${PLUGIN_VERSION}" \
		--arg license "${PLUGIN_LICENSE}" \
		--arg homepage "${PLUGIN_HOMEPAGE}" \
		--arg dwc_version "${DWC_VERSION}" \
		--arg rrf_version "${RRF_VERSION}" \
		--argjson dwc_files "$(printf '%s\n' "${DWC_FILES[@]}" | jq -R . | jq -s .)" \
		--argjson sd_files "$(printf '%s\n' "${SD_FILES[@]}" | jq -R . | jq -s .)" \
		'{
			($plugin_id): {
				"id": $plugin_id,
				"name": $name,
				"author": $author,
				"version": $version,
				"license": $license,
				"homepage": $homepage,
				"tags": [],
				"dwcVersion": $dwc_version,
				"dwcDependencies": [],
				"sbcRequired": false,
				"sbcDsfVersion": null,
				"sbcExecutable": null,
				"sbcExecutableArguments": null,
				"sbcExtraExecutables": [],
				"sbcAutoRestart": false,
				"sbcOutputRedirected": true,
				"sbcPermissions": [],
				"sbcConfigFiles": [],
				"sbcPackageDependencies": [],
				"sbcPluginDependencies": [],
				"sbcPythonDependencies": [],
				"rrfVersion": $rrf_version,
				"data": {},
				"dsfFiles": [],
				"dwcFiles": $dwc_files,
				"sdFiles": $sd_files,
				"pid": -1
			}
		}' > "${DWC_PLUGINS_JSON_PATH}"

	echo "Created dwc-plugins.json with ${#DWC_FILES[@]} DWC files and ${#SD_FILES[@]} SD files"
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

	[[ ! -f "${CACHE_DIR}/${MOS_DST_NAME}" ]] && {
		wget -nv -O "${CACHE_DIR}/${MOS_DST_NAME}" "${MOS_URL}" || { echo "Failed to download ${MOS_URL}"; exit 1; }
	}

	# Unzip RRF firmware to cache dir
	unzip -o -q "${CACHE_DIR}/${RRF_FIRMWARE_ZIP_NAME}" -d "${CACHE_DIR}/"

	# Unzip MillenniumOS plugin to a temporary directory
	local MOS_TMP_DIR=$(mktemp -d -t mos-plugin-XXXXX)
	unzip -o -q "${CACHE_DIR}/${MOS_DST_NAME}" -d "${MOS_TMP_DIR}"

	# Copy MillenniumOS 'sd' folder contents to SYS_DIR
	if [[ -d "${MOS_TMP_DIR}/sd" ]]; then
		${SYNC_CMD} "${MOS_TMP_DIR}/sd/" "${TMP_DIR}/${SYS_DIR}/"
	fi

	# Copy MillenniumOS 'dwc' folder contents to WWW_DIR
	if [[ -d "${MOS_TMP_DIR}/dwc" ]]; then
		${SYNC_CMD} "${MOS_TMP_DIR}/dwc/" "${TMP_DIR}/${WWW_DIR}/"
	fi

	# Generate dwc-plugins.json
	generate_dwc_plugins_json "${MOS_TMP_DIR}"

	# Clean up temporary MillenniumOS extraction directory
	rm -rf "${MOS_TMP_DIR}"

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
		| MillenniumOS             | \`${MOS_SRC_NAME}\`                      | ${MOS_RELEASE}  |

		---

		EOF
	}

	# Create release zip with all files
	cd "${TMP_DIR}"
	zip -qr "${ZIP_PATH}.zip" *
	cd "${WD}"


	rm -rf "${TMP_DIR}"
}
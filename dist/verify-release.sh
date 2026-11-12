#!/usr/bin/env bash
# Check the release zips in dist/ against the config sources they were built from.
# Run from the repo root after dist/release-all.sh.

# Get directory of this script
SD=$(dirname "$0")

# Include common variables
source ${SD}/release-common.env

FAILS=0
OKS=0
declare -A KNOWN_ZIPS

function fail() {
	echo "FAIL $*"
	FAILS=$((FAILS + 1))
}

function verify_zip() {
	local TYPE="$1" MACHINE="$2" ZIP="$3"
	local ZNAME=$(basename "${ZIP}")
	local FAILS_BEFORE=${FAILS}
	local VALUES=$(env -i "${BASH}" -c 'source "$1"; source "$2"; printf "%s\n%s\n" "$BASE_TYPE" "$WIFI_FIRMWARE_DST_NAME"' _ "${WD}/${TYPE}/${MACHINE}/build.env" "${SD}/release-${TYPE}.env")
	local BASE="${VALUES%%$'\n'*}" WIFI="${VALUES#*$'\n'}"
	local OUT=$(mktemp -d -t rrf-verify-XXXXX)

	unzip -q "${ZIP}" -d "${OUT}" || { fail "${ZNAME}: cannot unzip"; rm -rf "${OUT}"; return; }

	# Expected config files: later layers replace earlier ones.
	local -A EXPECT=() MOS=()
	local LAYER REL
	for LAYER in common ${BASE} ${MACHINE}; do
		[[ -d "${WD}/${TYPE}/${LAYER}" ]] || continue
		while IFS= read -r -d '' REL; do
			REL="${REL#./}"
			[[ "${REL##*/}" == "README.md" || "${REL}" == *.env ]] && continue
			EXPECT["${REL}"]="${TYPE}/${LAYER}/${REL}"
		done < <(cd "${WD}/${TYPE}/${LAYER}" && find . -type f -print0)
	done
	# An example file is dropped when the file it is an example of exists.
	for REL in "${!EXPECT[@]}"; do
		[[ "${REL}" == *.g.example && -n "${EXPECT[${REL%.example}]}" ]] && unset 'EXPECT[$REL]'
	done

	# MillenniumOS files replace config files on purpose.
	if [[ -f "${OUT}/sys/dwc-plugins.json" ]]; then
		while IFS= read -r REL; do
			[[ "${REL}" == sys/* ]] && MOS["${REL#sys/}"]=1
		done < <(jq -r '.[].sdFiles[]' "${OUT}/sys/dwc-plugins.json")
	fi

	local CHECKED=0
	while IFS= read -r REL; do
		[[ -n "${MOS[${REL}]}" ]] && continue
		CHECKED=$((CHECKED + 1))
		if [[ ! -f "${OUT}/sys/${REL}" ]]; then
			fail "${ZNAME}: sys/${REL} missing (expected from ${EXPECT[${REL}]})"
		elif [[ "${REL}" == *.g ]]; then
			cmp -s "${OUT}/sys/${REL}" <(sed -e "s/%%WIFI_FIRMWARE_TYPE%%/${WIFI}/g" "${WD}/${EXPECT[${REL}]}") ||
				fail "${ZNAME}: sys/${REL} differs from ${EXPECT[${REL}]}"
		else
			cmp -s "${OUT}/sys/${REL}" "${WD}/${EXPECT[${REL}]}" ||
				fail "${ZNAME}: sys/${REL} differs from ${EXPECT[${REL}]}"
		fi
	done < <(printf '%s\n' "${!EXPECT[@]}" | sort)

	while IFS= read -r -d '' REL; do
		REL="${REL#./sys/}"
		[[ "${REL}" == "dwc-plugins.json" || -n "${EXPECT[${REL}]}" || -n "${MOS[${REL}]}" ]] && continue
		fail "${ZNAME}: unexpected file sys/${REL}"
	done < <(cd "${OUT}" && find ./sys -type f -print0 | sort -z)

	[[ ${FAILS} -eq ${FAILS_BEFORE} ]] && {
		echo "OK   ${ZNAME} (${CHECKED} config files)"
		OKS=$((OKS + 1))
	}
	rm -rf "${OUT}"
}

for TYPE_ENV in "${SD}"/release-*.env; do
	TYPE=$(basename "${TYPE_ENV}" .env)
	TYPE="${TYPE#release-}"
	[[ "${TYPE}" == "common" || ! -d "${WD}/${TYPE}" ]] && continue
	for MACHINE_PATH in "${WD}/${TYPE}"/*/; do
		MACHINE=$(basename "${MACHINE_PATH}")
		[[ "${MACHINE}" == "common" ]] && continue
		ZIP="${DIST_DIR}/rrf-${TYPE}-${MACHINE}-${COMMIT_ID}.zip"
		KNOWN_ZIPS["${ZIP}"]=1
		[[ -f "${ZIP}" ]] && verify_zip "${TYPE}" "${MACHINE}" "${ZIP}"
	done
done

FOUND=0
for ZIP in "${DIST_DIR}"/rrf-*-${COMMIT_ID}.zip; do
	[[ -f "${ZIP}" ]] || continue
	FOUND=$((FOUND + 1))
	[[ -n "${KNOWN_ZIPS[${ZIP}]}" ]] || fail "$(basename "${ZIP}"): does not match a machine directory"
done
[[ ${FOUND} -eq 0 ]] && fail "no release zips for ${COMMIT_ID} in dist/"

echo "Checked ${FOUND} zip(s): ${OKS} OK, ${FAILS} FAIL"
[[ ${FAILS} -eq 0 ]]

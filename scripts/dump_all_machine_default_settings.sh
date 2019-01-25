#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ROOT_WORK_DIR="$1"

today="$(date +%Y-%m-%d)"

WORK_DIR="${ROOT_WORK_DIR}/${today}"
mkdir -p "${WORK_DIR}"


# Use docker to run Cura + CuraDebugTools and dump all machine default settings to a directory.
# TODO
docker run --rm \
  -v "${SCRIPT_DIR}":/srv/scripts:ro \
  -v "${WORK_DIR}":/srv/output_dir:rw \
  -e WORK_DIR=/srv/cura \
  -e CURADEBUGTOOLS_DUMPMACHINE_OUTPUTDIR="${WORK_DIR}" \
  cura-build-env /srv/scripts/cura_dump_machine_settings.sh

# Check output file count
file_count="$( ls "${WORK_DIR}" | wc -l )"
if [[ "${file_count}" -eq 0 ]]; then
    echo "Got 0 files from output directory ${WORK_DIR}. Doesn't seem to be correct."
    exit 1
fi

# TODO: Save to an SQLite DB?

# TODO: Analyze


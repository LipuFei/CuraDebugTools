#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# TODO:
ROOT_WORK_DIR="$1"
BRANCH="$2"

today="$( date +%Y-%m-%d )"
current_datetime="$( date +%Y-%m-%d_%H:%M:%S )"

WORK_DIR="${ROOT_WORK_DIR}/${today}"
mkdir -p "${WORK_DIR}"

OUTPUT_DIR="${WORK_DIR}/output"
MACHINE_SETTINGS_OUTPUT_DIR="${OUTPUT_DIR}/machine_settings"
REPO_DIR="${WORK_DIR}/repos"

mkdir -p "${OUTPUT_DIR}" "${MACHINE_SETTINGS_OUTPUT_DIR}"
mkdir -p "${REPO_DIR}"

# Check out Uranium and Cura
pushd "${REPO_DIR}" > /dev/null

git clone -b "${BRANCH}" https://github.com/Ultimaker/Uranium.git
git clone -b "${BRANCH}" https://github.com/Ultimaker/Cura.git

# Get a list of changed files from the last time
# TODO: get last checked git commits
last_uranium_commit=""
last_cura_commit=""

pushd Uranium > /dev/null
this_uranium_commit="$( git rev-parse HEAD )"
uranium_changed_files="$( git diff --name-only "${last_uranium_commit}" )"
popd > /dev/null
echo "${uranium_changed_files}" > "${OUTPUT_DIR}"/uranium_changed_files.txt

pushd Cura > /dev/null
this_cura_commit="$( git rev-parse HEAD )"
cura_changed_files="$( git diff --name-only "${last_cura_commit}" )"
popd > /dev/null
echo "${cura_changed_files}" > "${OUTPUT_DIR}"/cura_changed_files.txt

cat << EOF > "${OUTPUT_DIR}"/summary.txt
datetime: ${current_datetime}
cura branch: ${BRANCH}
cura commit: ${this_cura_commit}
uranium branch: ${BRANCH}
uranium commit: ${this_uranium_commit}
EOF


# Use docker to run Cura + CuraDebugTools and dump all machine default settings to a directory.
# TODO
docker run --rm \
  -v "${SCRIPT_DIR}":/srv/scripts:ro \
  -v "${REPO_DIR}":/srv/repos:rw \
  -v "${OUTPUT_DIR}":/srv/output_dir:rw \
  -e WORK_DIR="${REPO_DIR}" \
  -e CURADEBUGTOOLS_DUMPMACHINE_OUTPUTDIR="${MACHINE_SETTINGS_OUTPUT_DIR}" \
  cura-build-env /srv/scripts/cura_dump_machine_settings.sh

# Check output file count
file_count="$( ls "${MACHINE_SETTINGS_OUTPUT_DIR}" | wc -l )"
if [[ "${file_count}" -eq 0 ]]; then
    echo "Got 0 files from output directory ${MACHINE_SETTINGS_OUTPUT_DIR}. Doesn't seem to be correct."
    exit 1
fi

# TODO: Save to an SQLite DB?

# TODO: Analyze


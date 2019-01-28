#!/usr/bin/env bash

if [[ -z "${REPO_DIR}" ]]; then
    REPO_DIR="/srv/cura"
fi

mkdir -p "${REPO_DIR}"
pushd "${REPO_DIR}" > /dev/null

# Set environment variables
export PYTHONPATH="${WORK_DIR}/Uranium:${PYTHONPATH}"
export PYTHONPATH="${WORK_DIR}/Cura:${PYTHONPATH}"

# TODO: create user and group for running Cura, need to have the same UID and GID as the host


# TODO: run Cura with the appropriate user.


# TODO: chown and chmod for all output files

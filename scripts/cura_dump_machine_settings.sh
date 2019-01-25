#!/usr/bin/env bash

if [[ -z "${WORK_DIR}" ]]; then
    WORK_DIR="/srv/cura"
fi

mkdir -p "${WORK_DIR}"
pushd "${WORK_DIR}" > /dev/null

# Checkout Uranium and Cura
git clone -b master https://github.com/Ultimaker/Uranium.git
git clone -b master https://github.com/Ultimaker/Cura.git

# Set environment variables
export PYTHONPATH="${WORK_DIR}/Uranium:${PYTHONPATH}"
export PYTHONPATH="${WORK_DIR}/Cura:${PYTHONPATH}"

# TODO: create user and group for running Cura, need to have the same UID and GID as the host


# TODO: run Cura with the appropriate user.


# TODO: chown and chmod for all output files

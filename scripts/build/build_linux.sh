#!/usr/bin/env bash

set -e

if ! command -v make &> /dev/null; then
    echo "ERROR: make is not installed."
    exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." &> /dev/null && pwd)"

pushd "${REPO_ROOT}" > /dev/null
make "$@"
popd > /dev/null

#read -p "Press enter to continue..."

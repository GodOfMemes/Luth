#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." &> /dev/null && pwd)"

pushd "${REPO_ROOT}" > /dev/null
extern/premake/linux/premake5 --file=premake5.lua gmake2
popd > /dev/null

#read -p "Press [Enter] to continue..."

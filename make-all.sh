#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/b-log.sh

LOG_LEVEL_WARN

main() {
  local root_dir="$1"

  for dir in $(find "${root_dir}" -maxdepth 2 -mindepth 2 -type d); do
    pushd "${dir}" || return

    make all

    popd || return
  done
}

main "$@"

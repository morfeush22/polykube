#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/b-log.sh

LOG_LEVEL_WARN

main() {
  local polyrepo_dest_root_dir="$1"

  for dir in $(find "${polyrepo_dest_root_dir}" -maxdepth 2 -mindepth 2 -type d); do
     pushd "${dir}" || return

     make all || exit

     popd || return
  done
}

main "$@"

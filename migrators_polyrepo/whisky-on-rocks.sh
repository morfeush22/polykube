#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../b-log.sh

LOG_LEVEL_WARN

main() {
  local kubernetes_repo_root_dir="$1"
  local component_relative_path="$2"
  local polyrepo_dest_root_dir="$3"

  if [[ "${SKIP_WHISKY}" != true ]]; then
    whisky_on_rocks "${kubernetes_repo_root_dir}" "${component_relative_path}" "${polyrepo_dest_root_dir}"
  fi
}

main "$@"

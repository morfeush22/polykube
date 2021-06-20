#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../b-log.sh

LOG_LEVEL_ALL

main() {
  local kubernetes_repo_root_dir="$1"
  local component_relative_path="$2"
  local polyrepo_dest_root_dir="$3"

  local go_files_count
  go_files_count="$(find "${kubernetes_repo_root_dir}/${component_relative_path}" -maxdepth 1 -name "*.go" | wc -l)"

  if [[ "${go_files_count}" == 0 ]]; then
    whisky "${kubernetes_repo_root_dir}" "${component_relative_path}" "${polyrepo_dest_root_dir}"
  else
    vodka "${kubernetes_repo_root_dir}" "${component_relative_path}" "${polyrepo_dest_root_dir}"
  fi
}

main "$@"

#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../../commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../../b-log.sh

readonly MAKEFILE_TEMPLATE_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/cluster/Makefile.tmpl

LOG_LEVEL_WARN

# requieres kind in path!
main() {
  local kubernetes_repo_root_dir="$1"
  local polyrepo_dest_root_dir="$2"

  if [[ "${SKIP_WHISKY}" != true ]]; then
    whisky_on_ice "${kubernetes_repo_root_dir}" "test/e2e_kubeadm" "${polyrepo_dest_root_dir}"
    whisky_on_ice "${kubernetes_repo_root_dir}" "test/e2e" "${polyrepo_dest_root_dir}"
  fi

  party "${MAKEFILE_TEMPLATE_PATH}" "${polyrepo_dest_root_dir}"
}

main "$@"

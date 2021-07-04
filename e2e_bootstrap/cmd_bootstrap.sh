#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../b-log.sh

LOG_LEVEL_ALL

main() {
  local kubernetes_repo_root_dir="$1"
  local polyrepo_dest_root_dir="$2"

  mkdir -p "${polyrepo_dest_root_dir}"/_output/local/bin/linux/amd64

  cp "${kubernetes_repo_root_dir}"/_output/bin/kubectl "${polyrepo_dest_root_dir}"/_output/local/bin/linux/amd64/
  cp "${kubernetes_repo_root_dir}"/_output/bin/kube-apiserver "${polyrepo_dest_root_dir}"/_output/local/bin/linux/amd64/
  cp "${kubernetes_repo_root_dir}"/_output/bin/kube-controller-manager "${polyrepo_dest_root_dir}"/_output/local/bin/linux/amd64/
}

main "$@"



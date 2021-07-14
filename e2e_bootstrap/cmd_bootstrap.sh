#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../b-log.sh

LOG_LEVEL_ALL

main() {
  local kubernetes_repo_root_dir="$1"
  local polyrepo_dest_root_dir="$2"

  local output_dest="${polyrepo_dest_root_dir}"/_output/local/bin/linux/amd64

  mkdir -p "${output_dest}"

  # needed by test
  cp "${kubernetes_repo_root_dir}"/_output/bin/kubectl "${output_dest}"
  cp "${kubernetes_repo_root_dir}"/_output/bin/kube-apiserver "${output_dest}"
  cp "${kubernetes_repo_root_dir}"/_output/bin/kube-controller-manager "${output_dest}"
}

main "$@"

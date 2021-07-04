#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../b-log.sh

LOG_LEVEL_ALL

main() {
  local kubernetes_repo_root_dir="$1"
  local polyrepo_dest_root_dir="$2"

  # needed by test
  cp "${kubernetes_repo_root_dir}"/_output/bin/kubectl "${polyrepo_dest_root_dir}"

  local output_dockerized_dest="${polyrepo_dest_root_dir}"/_output/dockerized/bin/linux/amd64

  mkdir -p "${output_dockerized_dest}"

  # needed by kind
  cp "${kubernetes_repo_root_dir}"/_output/bin/kubeadm "${output_dockerized_dest}"
  cp "${kubernetes_repo_root_dir}"/_output/bin/kubelet "${output_dockerized_dest}"
  cp "${kubernetes_repo_root_dir}"/_output/bin/kubectl "${output_dockerized_dest}"

  cp "${kubernetes_repo_root_dir}"/_output/bin/kube-apiserver "${output_dockerized_dest}"
  cp "${kubernetes_repo_root_dir}"/_output/bin/kube-controller-manager "${output_dockerized_dest}"
  cp "${kubernetes_repo_root_dir}"/_output/bin/kube-proxy "${output_dockerized_dest}"
  cp "${kubernetes_repo_root_dir}"/_output/bin/kube-scheduler "${output_dockerized_dest}"
}

main "$@"

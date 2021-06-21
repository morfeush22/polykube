#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../../commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../../b-log.sh

readonly MAKEFILE_TEMPLATE_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/Makefile.tmpl

LOG_LEVEL_ALL

main() {
  local kubernetes_repo_root_dir="$1"
  local component_relative_path="$2"
  local destination_path="$3"

  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/api/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/apiextensions-apiserver/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/apimachinery/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/apiserver/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/cli-runtime/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/client-go/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/cloud-provider/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/cluster-bootstrap/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/code-generator/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/component-base/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/component-helpers/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/controller-manager/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/cri-api/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/csi-translation-lib/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/kube-aggregator/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/kube-controller-manager/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/kube-proxy/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/kube-scheduler/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/kubectl/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/kubelet/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/legacy-cloud-providers/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/metrics/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/mount-utils/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "staging/src/k8s.io/sample-apiserver/go.mod" "${destination_path}"

  TARGETS="[${component_relative_path}]" \
    party "${MAKEFILE_TEMPLATE_PATH}" "${destination_path}"
}

main "$@"

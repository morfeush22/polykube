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

  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/api" "${destination_path}"
  twin "${destination_path}" "vendor/k8s.io/api" "staging/src/k8s.io/api"

  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/apimachinery" "${destination_path}"
  twin "${destination_path}" "vendor/k8s.io/apimachinery" "staging/src/k8s.io/apimachinery"

  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/apiserver" "${destination_path}"
  twin "${destination_path}" "vendor/k8s.io/apiserver" "staging/src/k8s.io/apiserver"

  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/client-go" "${destination_path}"
  twin "${destination_path}" "vendor/k8s.io/client-go" "staging/src/k8s.io/client-go"

  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/component-base" "${destination_path}"
  twin "${destination_path}" "vendor/k8s.io/component-base" "staging/src/k8s.io/component-base"

  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/cloud-provider" "${destination_path}"
  twin "${destination_path}" "vendor/k8s.io/cloud-provider" "staging/src/k8s.io/cloud-provider"

  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/csi-translation-lib" "${destination_path}"
  twin "${destination_path}" "vendor/k8s.io/csi-translation-lib" "staging/src/k8s.io/csi-translation-lib"

  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/controller-manager" "${destination_path}"
  twin "${destination_path}" "vendor/k8s.io/controller-manager" "staging/src/k8s.io/controller-manager"

  TARGETS="[${component_relative_path}]" \
    party "${MAKEFILE_TEMPLATE_PATH}" "${destination_path}"

  cd "${destination_path}/${component_relative_path}" && go mod vendor
}

main "$@"

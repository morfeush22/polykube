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

  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/api/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/apimachinery/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/apiserver/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/client-go/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/code-generator/go.mod" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/component-base/go.mod" "${destination_path}"

  TEST_TARGETS='
[
  "pkg"
]
'

  ENVS='
test1: 1
test2: 2
'

  TARGET="${component_relative_path}" TEST_TARGETS="${TEST_TARGETS}" ENVS="${ENVS}" \
    party "${MAKEFILE_TEMPLATE_PATH}" "${destination_path}"
}

main "$@"

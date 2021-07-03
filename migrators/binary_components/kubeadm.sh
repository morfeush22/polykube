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

  TEST_TARGETS="[${component_relative_path}]"

  ENVS='
  KUBEADM_PATH: $(PWD)/kubeadm
'

  BUILD_FLAGS="
  [
    -X 'k8s.io/component-base/version.gitMajor=0340',
    -X 'k8s.io/component-base/version.gitMinor=8347',
    -X 'k8s.io/component-base/version.gitTreeState=clean'
  ]
"

  ENVS="${ENVS}" BUILD_FLAGS="${BUILD_FLAGS}" TARGET="${component_relative_path}" TEST_TARGETS="${TEST_TARGETS}" \
    party "${MAKEFILE_TEMPLATE_PATH}" "${destination_path}"
}

main "$@"

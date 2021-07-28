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

  waitress "${kubernetes_repo_root_dir}" "hack" "${destination_path}"

  local version_file_name="version.sh"
  "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/hack/version.sh \
    "${kubernetes_repo_root_dir}" \
    "${destination_path}" \
    "${version_file_name}"

  ENVS="
  KUBE_GIT_VERSION_FILE: \$(PWD)/${version_file_name}
"

  TEST_TARGETS="[${component_relative_path}]"

  ENVS="${ENVS}" TARGET="${component_relative_path}" TEST_TARGETS="${TEST_TARGETS}" \
    party "${MAKEFILE_TEMPLATE_PATH}" "${destination_path}"
}

main "$@"

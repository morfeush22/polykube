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
  local version_file_dest_path="${destination_path}/${version_file_name}"

  # deadbeaf
  cat <<'EOF' >"${version_file_dest_path}"
export KUBE_GIT_MAJOR='0340'
export KUBE_GIT_MINOR='8347'
export KUBE_GIT_TREE_STATE='clean'
export KUBE_GIT_COMMIT='03408347'

EOF

  chmod 755 "${version_file_dest_path}"

  TEST_TARGETS="[${component_relative_path}]"

  ENVS="
  KUBEADM_PATH: \$(PWD)/kubeadm
  KUBE_GIT_VERSION_FILE: \$(PWD)/${version_file_name}
"

  ENVS="${ENVS}" TARGET="${component_relative_path}" TEST_TARGETS="${TEST_TARGETS}" \
    party "${MAKEFILE_TEMPLATE_PATH}" "${destination_path}"
}

main "$@"

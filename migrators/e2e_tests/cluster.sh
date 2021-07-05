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

  # needed by kind
  waitress "${kubernetes_repo_root_dir}" "build" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "hack" "${polyrepo_dest_root_dir}"

  pushd "${kubernetes_repo_root_dir}" || return

  local kube_git_version
  kube_git_version="$(./hack/print-workspace-status.sh | sed -n 's/^gitVersion \(.*\)$/\1/p')"

  popd || return

  # kind needs kube git version
  echo "export KUBE_GIT_VERSION=${kube_git_version}" >"${polyrepo_dest_root_dir}"/env.sh

  # kind uses run.sh to build artifacts that we already have, hence we want to skip it using empty file
  echo '#!/usr/bin/env bash' >"${polyrepo_dest_root_dir}"/build/run.sh

  local bootstrap_script_file_name=bootstrap.sh
  local bootstrap_script_file_dest_path="${polyrepo_dest_root_dir}/${bootstrap_script_file_name}"

  cat <<'EOF' >"${bootstrap_script_file_dest_path}"
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

KUBE_ROOT=$(dirname "${BASH_SOURCE[0]}")
source "${KUBE_ROOT}/build/common.sh"
source "${KUBE_ROOT}/build/lib/release.sh"
source "${KUBE_ROOT}"/env.sh

kube::release::build_server_images
kind build node-image --kube-root "${KUBE_ROOT}"

EOF

  chmod 755 "${bootstrap_script_file_dest_path}"

  local kind_config_file_name="kind-config.yaml"
  local kind_config_file_dest_path="${polyrepo_dest_root_dir}/${kind_config_file_name}"

  cat <<'EOF' >"${kind_config_file_dest_path}"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  ipFamily: ipv4
nodes:
- role: control-plane
- role: worker
- role: worker

EOF

  BOOTSTRAP_SCRIPT_RELATIVE_PATH="./${bootstrap_script_file_name}" \
  KIND_CONFIG_RELATIVE_PATH="./${kind_config_file_name}" \
    party "${MAKEFILE_TEMPLATE_PATH}" "${polyrepo_dest_root_dir}"
}

main "$@"

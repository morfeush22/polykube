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

  if [[ "${SKIP_WHISKY:-false}" != true ]]; then
    whisky_on_ice "${kubernetes_repo_root_dir}" "test/e2e_kubeadm" "${polyrepo_dest_root_dir}"
    whisky_on_ice "${kubernetes_repo_root_dir}" "test/e2e" "${polyrepo_dest_root_dir}"
  fi

  # needed by kind
  waitress "${kubernetes_repo_root_dir}" "build" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "hack" "${polyrepo_dest_root_dir}"

  pushd "${kubernetes_repo_root_dir}" || return

  local kube_git_version
  kube_git_version="$(./hack/print-workspace-status.sh | sed -n 's/^gitVersion \(.*\)-.*$/\1/p')"

  popd || return

  # kind needs kube git version
  echo "export KUBE_MAIN_GIT_VERSION=${kube_git_version}" >"${polyrepo_dest_root_dir}"/env.sh

  # kind uses run.sh to build artifacts that we already have, hence we want to skip it using empty file
  echo '#!/usr/bin/env bash' >"${polyrepo_dest_root_dir}"/build/run.sh

  local bootstrap_script_file_name=bootstrap.sh
  local bootstrap_script_file_dest_path="${polyrepo_dest_root_dir}/${bootstrap_script_file_name}"

  cat <<'EOF' >"${bootstrap_script_file_dest_path}"
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export KUBE_VERBOSE=0
export KUBE_BUILD_HYPERKUBE=n
export KUBE_BUILD_CONFORMANCE=n
export KUBE_BUILD_PLATFORMS="$GOOS/$GOARCH"

KUBE_ROOT=$(dirname "${BASH_SOURCE[0]}")
source "${KUBE_ROOT}/build/common.sh"
source "${KUBE_ROOT}/build/lib/release.sh"
source "${KUBE_ROOT}/env.sh"

if ./hack/print-workspace-status.sh | grep -q 'gitTreeState dirty'; then
  export KUBE_GIT_VERSION="${KUBE_MAIN_GIT_VERSION}-dirty"
else
  export KUBE_GIT_VERSION="${KUBE_MAIN_GIT_VERSION}"
fi

DEST_DIR="_output/dockerized/bin/${GOOS}/${GOARCH}"

mkdir -p "${DEST_DIR}"

[[ -f "./${DEST_DIR}/kubeadm" ]] || cp "${ARTIFACTS_DIR}/kubeadm" "./${DEST_DIR}/kubeadm"
[[ -f "./${DEST_DIR}/kubelet" ]] || cp "${ARTIFACTS_DIR}/kubelet" "./${DEST_DIR}/kubelet"
[[ -f "./${DEST_DIR}/kubectl" ]] || cp "${ARTIFACTS_DIR}/kubectl" "./${DEST_DIR}/kubectl"
[[ -f "./${DEST_DIR}/kube-apiserver" ]] || cp "${ARTIFACTS_DIR}/kube-apiserver" "./${DEST_DIR}/kube-apiserver"
[[ -f "./${DEST_DIR}/kube-controller-manager" ]] || cp "${ARTIFACTS_DIR}/kube-controller-manager" "./${DEST_DIR}/kube-controller-manager"
[[ -f "./${DEST_DIR}/kube-proxy" ]] || cp "${ARTIFACTS_DIR}/kube-proxy" "./${DEST_DIR}/kube-proxy"
[[ -f "./${DEST_DIR}/kube-scheduler" ]] || cp "${ARTIFACTS_DIR}/kube-scheduler" "./${DEST_DIR}/kube-scheduler"

chmod 755 "./${DEST_DIR}/"*

kube::release::build_server_images

# hack to fix double dirty
KUBE_GIT_VERSION="${KUBE_MAIN_GIT_VERSION}"
kind build node-image --kube-root "${KUBE_ROOT}"

[[ -f ./kubectl ]] || cp "./${DEST_DIR}/kubectl" ./kubectl

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

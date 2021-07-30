#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../b-log.sh

LOG_LEVEL_WARN

# requieres kind in path!
main() {
  local kubernetes_repo_root_dir="$1"
  local monorepo_dest_root_dir="$2"

  pushd "${kubernetes_repo_root_dir}" || return

  local kube_git_version
  kube_git_version="$(./hack/print-workspace-status.sh | sed -n 's/^gitVersion \(.*\)-.*$/\1/p')"

  popd || return

  # kind needs kube git version
  echo "export KUBE_MAIN_GIT_VERSION=${kube_git_version}" >"${monorepo_dest_root_dir}"/env.sh

  local bootstrap_script_file_name=bootstrap.sh
  local bootstrap_script_file_dest_path="${monorepo_dest_root_dir}/${bootstrap_script_file_name}"

  cat <<'EOF' >"${bootstrap_script_file_dest_path}"
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

KUBE_ROOT=$(dirname "${BASH_SOURCE[0]}")
source "${KUBE_ROOT}/env.sh"

export KUBE_GIT_VERSION="${KUBE_MAIN_GIT_VERSION}"
kind build node-image --kube-root "${KUBE_ROOT}"

SOURCE_DIR="_output/dockerized/bin/${GOOS}/${GOARCH}"

[[ -f ./kubectl ]] || cp "./${SOURCE_DIR}/kubectl" ./kubectl

EOF

  chmod 755 "${bootstrap_script_file_dest_path}"
}

main "$@"

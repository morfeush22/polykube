#!/usr/bin/env bash

# in some binaries, version is checked in tests

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../../../commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../../../b-log.sh

LOG_LEVEL_ALL

main() {
  local kubernetes_repo_root_dir="$1"
  local destination_path="$2"
  local version_file_name="$3"

  local kube_git_version
  kube_git_version="$(
    cd "${kubernetes_repo_root_dir}";
    ./hack/print-workspace-status.sh | sed -n 's/^gitVersion \(.*\)-.*$/\1/p'
  )"

  local kube_git_commit
  kube_git_commit="$(git --git-dir="${kubernetes_repo_root_dir}"/.git rev-parse HEAD)"

  local version_file_dest_path="${destination_path}/${version_file_name}"

  cat <<EOF >"${version_file_dest_path}"
export KUBE_GIT_COMMIT="${kube_git_commit}"
export KUBE_GIT_TREE_STATE="clean"
export KUBE_GIT_VERSION="${kube_git_version}"
export KUBE_GIT_MAJOR="$(sed -n 's/^v\([[:digit:]]*\)\..*\..*$/\1/p' <<<"${kube_git_version}")"
export KUBE_GIT_MINOR="$(sed -n 's/^v[[:digit:]]*\.\([[:digit:]]*\)\..*$/\1/p' <<<"${kube_git_version}")"

EOF

  chmod 755 "${version_file_dest_path}"
}

main "$@"

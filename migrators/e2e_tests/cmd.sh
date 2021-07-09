#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../../commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../../b-log.sh

readonly MAKEFILE_TEMPLATE_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/cmd/Makefile.tmpl

LOG_LEVEL_WARN

# requieres etcd in path!
main() {
  local kubernetes_repo_root_dir="$1"
  local polyrepo_dest_root_dir="$2"

  if [[ "${SKIP_WHISKY}" != true ]]; then
    whisky_on_ice "${kubernetes_repo_root_dir}" "hack" "${polyrepo_dest_root_dir}"
  fi

  waitress "${kubernetes_repo_root_dir}" "test/cmd" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "third_party/forked/shell2junit" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "test/fixtures/doc-yaml/admin/high-availability" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "test/fixtures/doc-yaml/admin/limitrange" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "test/fixtures/doc-yaml/user-guide" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "test/fixtures/pkg/kubectl/cmd/auth" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "test/fixtures/pkg/kubectl/cmd/create" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "test/fixtures/pkg/kubectl/cmd/expose" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "test/fixtures/pkg/kubectl/cmd/patch" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "test/fixtures/pkg/kubectl/plugins" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "test/e2e/testing-manifests/guestbook" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "test/e2e/testing-manifests/kubectl" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "test/e2e/testing-manifests/statefulset/cassandra" "${polyrepo_dest_root_dir}"

  local bootstrap_script_file_name=bootstrap.sh
  local bootstrap_script_file_dest_path="${polyrepo_dest_root_dir}/${bootstrap_script_file_name}"

  cat <<'EOF' >"${bootstrap_script_file_dest_path}"
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DEST_DIR="_output/dockerized/bin/${GOOS}/${GOARCH}"

mkdir -p "${DEST_DIR}"

cp "${ARTIFACTS_DIR}/kubectl" "./${DEST_DIR}/kubectl"
cp "${ARTIFACTS_DIR}/kube-apiserver" "./${DEST_DIR}/kube-apiserver"
cp "${ARTIFACTS_DIR}/kube-controller-manager" "./${DEST_DIR}/kube-controller-manager"

EOF

  chmod 755 "${bootstrap_script_file_dest_path}"

  BOOTSTRAP_SCRIPT_RELATIVE_PATH="./${bootstrap_script_file_name}" \
    party "${MAKEFILE_TEMPLATE_PATH}" "${polyrepo_dest_root_dir}"
}

main "$@"

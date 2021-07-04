#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../../commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../../b-log.sh

readonly MAKEFILE_TEMPLATE_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/cmd/Makefile.tmpl

LOG_LEVEL_WARN

# requieres etcd!
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

  party "${MAKEFILE_TEMPLATE_PATH}" "${polyrepo_dest_root_dir}"
}

main "$@"

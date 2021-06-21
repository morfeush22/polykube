#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../../commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../../b-log.sh

LOG_LEVEL_ALL

main() {
  local kubernetes_repo_root_dir="$1"
  local component_relative_path="$2"
  local destination_path="$3"

  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/apiserver/pkg/admission/testing" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "vendor/github.com/stretchr/testify/assert" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "vendor/github.com/pmezard/go-difflib/difflib" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "vendor/k8s.io/component-base/featuregate/testing" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "vendor/gopkg.in/yaml.v3" "${destination_path}"
  waitress "${kubernetes_repo_root_dir}" "plugin/pkg/auth/authorizer/rbac/bootstrappolicy/testdata" "${destination_path}"
}

main "$@"

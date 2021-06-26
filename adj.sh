#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/b-log.sh

LOG_LEVEL_WARN

infer_import_path() {
  local component_relative_path="$1"

  local -n inferred_import_path="$2"

  pushd "${component_absolute_path}" || return

  local candidate_import_path

  if candidate_import_path="$(go list)"; then
    inferred_import_path="${candidate_import_path}"
  else
    WARN "trying to infer import path for ${component_relative_path}"

    local -r kubernetes_module_spec='k8s.io/kubernetes'

    inferred_import_path="${kubernetes_module_spec}/${component_relative_path}"

    WARN "inferred path is ${inferred_import_path}"
  fi

  popd || return
}

main() {
  local polyrepo_dest_root_dir="$1"
  local component_relative_path="$2"

  local deps_file_path="${polyrepo_dest_root_dir}"/deps.txt
  local adj_file_path="${polyrepo_dest_root_dir}"/adj_file.txt

  local component_absolute_path="${polyrepo_dest_root_dir}/${component_relative_path}"

  local import_path

  infer_import_path "${component_relative_path}" import_path

  sed "s#^#${import_path} #" "${deps_file_path}" |
    cut -f 1,2 -d ' ' \
      >"${adj_file_path}"
}

main "$@"

#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/b-log.sh

declare -a PACKAGE_ABSOLUTE_PATH_ARRAY

calculate_package_absolute_path() {
  local kubernetes_repo_root_dir="$1"
  local package="$2"

  local -r kubernetes_module_spec='k8s.io/kubernetes'

  local package_absolute_path
  if [[ "${package}" == vendor/* ]]; then
    package_absolute_path="${kubernetes_repo_root_dir}/${package}"
  elif [[ "${package}" == "${kubernetes_module_spec}"/* ]]; then
    package_absolute_path="${kubernetes_repo_root_dir}/${package##${kubernetes_module_spec}/}"
  else
    package_absolute_path="${kubernetes_repo_root_dir}/vendor/${package}"
  fi

  echo "${package_absolute_path}"
}

extract_dependencies_from_go_package_deps() {
  local kubernetes_repo_root_dir="$1"
  local go_package_deps_file_path="$2"

  local packages
  packages="$(grep '\.' "${go_package_deps_file_path}")"

  readarray -t package_array <<<"${packages}"

  for package in "${package_array[@]}"; do
    local package_absolute_path
    package_absolute_path="$(
      calculate_package_absolute_path \
        "${kubernetes_repo_root_dir}" \
        "${package}"
    )"

    if [[ ! -d "${package_absolute_path}" ]]; then
      WARN "${package_absolute_path} does not exist, skipping"
    else
      PACKAGE_ABSOLUTE_PATH_ARRAY+=("${package_absolute_path}")
    fi
  done
}

bartender() {
  local kubernetes_repo_root_dir="$1"
  local go_package_deps_file_path="$2"
  local destination_path="$3"

  extract_dependencies_from_go_package_deps \
    "${kubernetes_repo_root_dir}" \
    "${go_package_deps_file_path}"

  copy_dependent_packages_to_destination \
    "${kubernetes_repo_root_dir}" \
    "${destination_path}"
}

waitress() {
  local kubernetes_repo_root_dir="$1"
  local kubernetes_dir_relative_path="$2"
  local destination_path="$3"

  local destination_absolute_path="${destination_path}/${kubernetes_dir_relative_path}"

  mkdir -p "${destination_absolute_path}"

  cp -r "${kubernetes_repo_root_dir}/${kubernetes_dir_relative_path}"/* "${destination_absolute_path}"
}

sugar() {
  local kubernetes_repo_root_dir="$1"
  local destination_path="$2"

  local -r go_mod='go.mod'
  local -r go_sum='go.sum'
  local -r vendor_modules_txt='modules.txt'

  cp "${kubernetes_repo_root_dir}/${go_mod}" "${destination_path}/${go_mod}"
  cp "${kubernetes_repo_root_dir}/${go_sum}" "${destination_path}/${go_sum}"

  if [[ -d "${destination_path}/vendor" ]]; then
    cp "${kubernetes_repo_root_dir}/vendor/${vendor_modules_txt}" "${destination_path}/vendor/${vendor_modules_txt}"
  fi
}

bar() {
  local kubernetes_repo_root_dir="$1"
  local component_relative_path="$2"
  local polyrepo_dest_root_dir="$3"

  local temp_go_package_deps_path

  local component_absolute_path="${kubernetes_repo_root_dir}/${component_relative_path}"

  generate_go_package_deps_file "${component_absolute_path}" "${component_relative_path##*/}" temp_go_package_deps_path

  INFO "generated temporary go deps path is ${temp_go_package_deps_path}"

  bartender "${kubernetes_repo_root_dir}" "${temp_go_package_deps_path}" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "${component_relative_path}" "${polyrepo_dest_root_dir}"
  sugar "${kubernetes_repo_root_dir}" "${polyrepo_dest_root_dir}"
}

generate_go_package_deps_file() {
  local component_absolute_path="$1"
  local temp_file_prefix="$2"

  local -n temp_file_path="$3"

  temp_file_path="/tmp/${temp_file_prefix}.$(date +%s)"

  pushd "${component_absolute_path}" || return

  go list -test -f '{{ join .Deps "\n" }}' >"${temp_file_path}"

  popd || return
}

copy_dependent_packages_to_destination() {
  local kubernetes_repo_root_dir="$1"
  local destination_path="$2"

  for package in "${PACKAGE_ABSOLUTE_PATH_ARRAY[@]}"; do
    local destination_package_relative_path="${package##${kubernetes_repo_root_dir}/}"
    local destination_absolute_path="${destination_path}/${destination_package_relative_path}"

    mkdir -p "${destination_absolute_path}"

    local cp_output
    cp_output="$(cp "${package}"/* "${destination_absolute_path}" 2>&1)"

    local non_omit_directory_errors
    non_omit_directory_errors="$(echo "${cp_output}" | grep -v 'omitting directory')"

    if [[ -n "${non_omit_directory_errors}" ]]; then
      FATAL "${cp_output}"
    fi
  done
}

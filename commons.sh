#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/b-log.sh

readonly HACK_CHECK_REV_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/hack/check-rev.sh

calculate_package_absolute_path() {
  local kubernetes_repo_root_dir="$1"
  local package="$2"

  local -n absolute_path="$3"

  local -r kubernetes_module_spec='k8s.io/kubernetes'

  if [[ "${package}" == "${kubernetes_module_spec}"/* ]]; then
    absolute_path="${kubernetes_repo_root_dir}/${package##${kubernetes_module_spec}/}"
  elif [[ "${package}" == vendor/* ]]; then
    absolute_path="${kubernetes_repo_root_dir}/${package}"
  else
    # shellcheck disable=SC2034
    absolute_path="${kubernetes_repo_root_dir}/vendor/${package}"
  fi
}

add_to_array_if_package_path_exist() {
  local package_absolute_path="$1"

  local -n dest_array="$2"

  if [[ ! -d "${package_absolute_path}" ]]; then
    WARN "${package_absolute_path} does not exist, skipping"
  else
    dest_array+=("${package_absolute_path}")
  fi
}

extract_internal_dependencies_from_go_package_deps() {
  local kubernetes_repo_root_dir="$1"
  local go_package_deps_file_path="$2"

  local -n kub_package_absolute_path_array="$3"

  local kub_packages
  kub_packages="$(grep '\.' "${go_package_deps_file_path}")" || :

  readarray -t kub_package_array <<<"${kub_packages}"

  for kub_package in "${kub_package_array[@]}"; do
    local kub_package_absolute_path

    if [[ "${kub_package}" =~ ^(.*)[[:space:]]\[(.*)\]$ ]]; then
      local fixed_package_spec_1="${BASH_REMATCH[1]}"
      local fixed_package_spec_2="${BASH_REMATCH[2]%.*}"

      WARN "fixing ${kub_package} to ${fixed_package_spec_1} and ${fixed_package_spec_2}"

      calculate_package_absolute_path "${kubernetes_repo_root_dir}" "${fixed_package_spec_1}" kub_package_absolute_path
      add_to_array_if_package_path_exist "${kub_package_absolute_path}" kub_package_absolute_path_array

      calculate_package_absolute_path "${kubernetes_repo_root_dir}" "${fixed_package_spec_2}" kub_package_absolute_path
      add_to_array_if_package_path_exist "${kub_package_absolute_path}" kub_package_absolute_path_array

      continue
    fi

    calculate_package_absolute_path "${kubernetes_repo_root_dir}" "${kub_package}" kub_package_absolute_path
    add_to_array_if_package_path_exist "${kub_package_absolute_path}" kub_package_absolute_path_array
  done
}

copy_dependent_packages_to_destination() {
  local kubernetes_repo_root_dir="$1"
  local destination_root_dir="$2"

  local -n kub_package_absolute_path_array="$3"

  for kub_package in "${kub_package_absolute_path_array[@]}"; do
    local destination_package_relative_path="${kub_package##${kubernetes_repo_root_dir}/}"
    local destination_absolute_path="${destination_root_dir}/${destination_package_relative_path}"

    mkdir -p "${destination_absolute_path}"

    local cp_output
    cp_output="$(cp "${kub_package}"/* "${destination_absolute_path}" 2>&1)" || :

    local non_omit_directory_errors
    non_omit_directory_errors="$(echo "${cp_output}" | grep -v 'omitting directory')" || :

    if [[ -n "${non_omit_directory_errors}" ]]; then
      FATAL "${cp_output}"
    fi
  done
}

bartender() {
  local kubernetes_repo_root_dir="$1"
  local go_package_deps_file_path="$2"
  local destination_root_dir="$3"

  local -a deps_array

  extract_internal_dependencies_from_go_package_deps \
    "${kubernetes_repo_root_dir}" \
    "${go_package_deps_file_path}" \
    deps_array

  copy_dependent_packages_to_destination \
    "${kubernetes_repo_root_dir}" \
    "${destination_root_dir}" \
    deps_array
}

waitress() {
  local kubernetes_repo_root_dir="$1"
  local kubernetes_source_relative_path="$2"
  local destination_root_dir="$3"

  local source_absolute_path="${kubernetes_repo_root_dir}/${kubernetes_source_relative_path}"
  local destination_absolute_path="${destination_root_dir}/${kubernetes_source_relative_path}"

  if [[ -f "${source_absolute_path}" ]]; then
    mkdir -p "${destination_absolute_path%/*}"
    cp "${kubernetes_repo_root_dir}/${kubernetes_source_relative_path}" "${destination_absolute_path}"
  elif [[ -d "${source_absolute_path}" ]]; then
    mkdir -p "${destination_absolute_path}"
    cp -r "${kubernetes_repo_root_dir}/${kubernetes_source_relative_path}"/* "${destination_absolute_path}"
  else
    FATAL "do not know how to copy source"
  fi
}

sugar() {
  local kubernetes_repo_root_dir="$1"
  local destination_root_dir="$2"

  local -r go_mod='go.mod'
  local -r go_sum='go.sum'
  local -r vendor_modules_txt='modules.txt'

  cp "${kubernetes_repo_root_dir}/${go_mod}" "${destination_root_dir}/${go_mod}"
  cp "${kubernetes_repo_root_dir}/${go_sum}" "${destination_root_dir}/${go_sum}"

  if [[ -d "${destination_root_dir}/vendor" ]]; then
    cp "${kubernetes_repo_root_dir}/vendor/${vendor_modules_txt}" "${destination_root_dir}/vendor/${vendor_modules_txt}"
  fi
}

construct_final_deps_file() {
  local kubernetes_repo_root_dir="$1"
  local kubernetes_source_relative_path="$2"

  local -n final_temp_go_package_deps_path="$3"

  local component_absolute_path="${kubernetes_repo_root_dir}/${kubernetes_source_relative_path}"

  INFO "component absolute path: ${component_absolute_path}"

  mapfile -t dirs_to_traverse < <(find -L "${component_absolute_path}" -maxdepth 1 -type d)

  local go_deps_dirs_candidates=()

  while [[ "${#dirs_to_traverse[@]}" != 0 ]]; do
    local current_dir="${dirs_to_traverse[0]}"
    dirs_to_traverse=("${dirs_to_traverse[@]:1}")

    mapfile -t new_dirs < <(find -L "${current_dir}" -maxdepth 1 ! -path "${current_dir}" -type d)
    dirs_to_traverse=("${dirs_to_traverse[@]}" "${new_dirs[@]}")

    go_deps_dirs_candidates+=("${current_dir}")
  done

  local go_deps_files=()

  for go_deps_dir_candidate in "${go_deps_dirs_candidates[@]}"; do
    local temp_file_prefix="${kubernetes_source_relative_path##*/}"

    local temp_go_package_deps_path

    generate_go_package_deps_file "${go_deps_dir_candidate}" "${temp_file_prefix}" temp_go_package_deps_path

    INFO "generated temporary go deps path for ${go_deps_dir_candidate} is ${temp_go_package_deps_path}"

    go_deps_files+=("${temp_go_package_deps_path}")
  done

  final_temp_go_package_deps_path="/tmp/${kubernetes_source_relative_path##*/}.$(uuidgen)"

  cat "${go_deps_files[@]}" | sort | uniq >"${final_temp_go_package_deps_path}"
}

generate_go_package_deps_file() {
  local component_absolute_path="$1"
  local temp_file_prefix="$2"

  local -n temp_file_path="$3"

  temp_file_path="/tmp/${temp_file_prefix}.$(uuidgen)"

  pushd "${component_absolute_path}" || return

  go list -test -f '{{ join .Deps "\n" }}' >"${temp_file_path}" || :

  popd || return
}

whisky_on_ice() {
  local kubernetes_repo_root_dir="$1"
  local kubernetes_source_relative_path="$2"
  local polyrepo_dest_root_dir="$3"

  local final_temp_deps_file_path

  construct_final_deps_file "${kubernetes_repo_root_dir}" "${kubernetes_source_relative_path}" final_temp_deps_file_path

  INFO "generated final temporary go deps path is ${final_temp_deps_file_path}"

  local deps_final_path="${polyrepo_dest_root_dir}"/deps.txt

  INFO "copying to final location ${deps_final_path}"

  cp "${final_temp_deps_file_path}" "${deps_final_path}"

  bartender "${kubernetes_repo_root_dir}" "${final_temp_deps_file_path}" "${polyrepo_dest_root_dir}"
  waitress "${kubernetes_repo_root_dir}" "${kubernetes_source_relative_path}" "${polyrepo_dest_root_dir}"
  sugar "${kubernetes_repo_root_dir}" "${polyrepo_dest_root_dir}"
}

whisky_on_rocks() {
  local kubernetes_repo_root_dir="$1"
  local kubernetes_source_relative_path="$2"
  local polyrepo_dest_root_dir="$3"

  local final_temp_deps_file_path

  construct_final_deps_file "${kubernetes_repo_root_dir}" "${kubernetes_source_relative_path}" final_temp_deps_file_path

  INFO "generated final temporary go deps path is ${final_temp_deps_file_path}"

  local deps_final_path="${polyrepo_dest_root_dir}"/deps.txt

  INFO "copying to final location ${deps_final_path}"

  cp "${final_temp_deps_file_path}" "${deps_final_path}"

  waitress "${kubernetes_repo_root_dir}" "${kubernetes_source_relative_path}" "${polyrepo_dest_root_dir}"
  sugar "${kubernetes_repo_root_dir}" "${polyrepo_dest_root_dir}"
}

twin() {
  local destination_root_dir="$1"
  local source_relative_path="$2"
  local destination_relative_path="$3"

  local src_abs_path="${destination_root_dir}/${source_relative_path}"
  local dst_abs_path="${destination_root_dir}/${destination_relative_path}"

  local dest_dir="${dst_abs_path%/*}"

  if [[ ! -d "${dest_dir}" ]]; then
    mkdir -p "${dest_dir}"
  fi

  if [[ ! -L ${dst_abs_path} ]]; then
    pushd "${dest_dir}" || return

    local link_name="${dst_abs_path##*/}"

    local relative_path
    relative_path="$(realpath --relative-to . "${src_abs_path}")"

    ln -s "${relative_path}" "${link_name}"

    popd || return
  else
    WARN "symbolic link ${dst_abs_path} already exist"
  fi
}

party() {
  local template_path="$1"
  local destination_root_dir="$2"

  gomplate -f "${template_path}" -o "${destination_root_dir}"/Makefile
  cp "${HACK_CHECK_REV_PATH}" "${destination_root_dir}"
}

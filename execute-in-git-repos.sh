#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/b-log.sh

LOG_LEVEL_WARN

main() {
  local git_repos_file="$1"

  readarray -t git_repos_array <"${git_repos_file}"

  for git_repo_main_dir in "${git_repos_array[@]}"; do
    pushd "${git_repo_main_dir}" || return

    echo "${WHAT}"
    eval "${WHAT}"

    popd
  done
}

main "$@"

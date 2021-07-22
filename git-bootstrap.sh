#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/b-log.sh

LOG_LEVEL_WARN

main() {
  local git_source_dir="$1"
  local git_dest_dir="$2"

  if [[ ! -d "${git_source_dir}/.git" ]]; then
    pushd "${git_source_dir}" || return

    git init
    git add -A
    git commit -m "init"

    popd || return
  fi

  git clone --bare "${git_source_dir}" "${git_dest_dir}"
}

main "$@"

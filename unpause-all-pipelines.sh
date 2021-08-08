#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/b-log.sh

LOG_LEVEL_WARN

main() {
  local gocd_server_url="$1"
  local regexp_filter="$2"

  local dashboard
  dashboard="$(
    curl \
      -fsSL \
      -H 'Accept: application/vnd.go.cd.v3+json' \
      "${gocd_server_url}/go/api/dashboard"
  )"

  local pipelines
  pipelines="$(
    jq \
      -r \
      '._embedded.pipelines[]._links.self.href' <<<"${dashboard}"
  )"

  for pipeline in ${pipelines}; do
    local pipeline_unpause_url="${pipeline%/history}/unpause"

    if ! grep -q "${regexp_filter}" <<<"${pipeline}"; then
      continue
    fi

    echo "${pipeline_unpause_url}"

    curl \
      -fsSL \
      -H 'Accept: application/vnd.go.cd.v1+json' \
      -H 'Content-Type: application/json' \
      -H 'X-GoCD-Confirm: true' \
      -X POST \
      "${pipeline_unpause_url}" || :
  done
}

main "$@"

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

  local dashboard
  dashboard="$(
    curl \
      -fsSL \
      -H 'Accept: application/vnd.go.cd.v3+json' \
      "http://${gocd_server_url}/go/api/dashboard"
  )"

  local pipelines
  pipelines="$(
    jq \
      -r \
      '._embedded.pipelines[]._links.self.href' <<<"${dashboard}"
  )"

  for pipeline in ${pipelines}; do
    local pipeline_pause_url="${pipeline%/history}/pause"

    echo "${pipeline_pause_url}"

    curl \
      -fsSL \
      -H 'Accept: application/vnd.go.cd.v1+json' \
      -H 'Content-Type: application/json' \
      -X POST \
      -d '{
            "pause_cause": "pause"
          }' \
      "${pipeline_pause_url}"
  done
}

main "$@"

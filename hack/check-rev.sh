#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

pipeline_history="$(
  curl "${GO_SERVER_URL}/api/pipelines/${GO_PIPELINE_NAME}/history" \
    -sS \
    -H 'Accept: application/vnd.go.cd.v1+json'
)"

previous_revision="$(
  jq \
    --arg material_name "${MATERIAL_NAME}" \
    -r \
    '.pipelines |
        (sort_by(.counter))? |
        reverse |
        .[0].build_cause.material_revisions |
        .[] |
        select(.material.name == $material_name) |
        .modifications |
        sort_by(.modified_time) |
        reverse |
        .[0].revision' <<<"${pipeline_history}"
)"

this_revision_env_var="GO_REVISION_${MATERIAL_NAME}"

[[ previous_revision == "${!this_revision_env_var}" ]]

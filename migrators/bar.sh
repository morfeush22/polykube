#!/usr/bin/env bash

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/../b-log.sh

LOG_LEVEL_ALL

main() {
  bar "$@"
}

main "$@"

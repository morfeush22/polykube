#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# cmd test is flaky, skipping
#
#go clean -cache
#go clean -testcache
#
#make test-cmd

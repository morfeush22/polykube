#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS citext;
EOSQL

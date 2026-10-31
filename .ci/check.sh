#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
trap 'printf "CI check failed at line %s\n" "$LINENO" >&2' ERR

bash bin/pages build

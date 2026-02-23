#!/usr/bin/env bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
exec "$SCRIPT_DIR/tools/crop1to2.sh" "$@"

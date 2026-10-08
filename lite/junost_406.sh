#!/bin/bash
# Lite: Junost 406 (portable mono, contrast-pushed tone).
# Usage: ./junost_406.sh <input> [output]
set -euo pipefail

CHASSIS="junost_406"
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/_common.sh"
lite_main "$@"

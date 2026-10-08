#!/bin/bash
# Lite: Sony Trinitron KV-M2180 (aperture grille, punchy tone).
# Usage: ./sony_kv_m2180.sh <input> [output]
set -euo pipefail

CHASSIS="sony_kv_m2180"
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/_common.sh"
lite_main "$@"

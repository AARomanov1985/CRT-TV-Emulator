#!/bin/bash
# Lite: GoldStar CK-20E40 (TDA8362 single-chip tone).
# Usage: ./goldstar_ck20e40.sh <input> [output]
set -euo pipefail

CHASSIS="goldstar_ck20e40"
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/_common.sh"
lite_main "$@"

#!/bin/bash
# Lite: Daewoo DTC-20U1 (grey-market budget, soft/muddy/foggy tone).
# Usage: ./daewoo_dtc20u1.sh <input> [output]
set -euo pipefail

CHASSIS="daewoo_dtc20u1"
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/_common.sh"
lite_main "$@"

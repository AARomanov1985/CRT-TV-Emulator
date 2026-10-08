#!/bin/bash
# Lite: Philips GR1AX (Dutch neutral, balanced tone).
# Usage: ./philips_gr1ax.sh <input> [output]
set -euo pipefail

CHASSIS="philips_gr1ax"
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/_common.sh"
lite_main "$@"

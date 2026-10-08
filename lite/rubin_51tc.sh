#!/bin/bash
# Lite: Rubin 51TC (MUP-402 matrix decoder tone).
# Usage: ./rubin_51tc.sh <input> [output]
set -euo pipefail

CHASSIS="rubin_51tc"
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/_common.sh"
lite_main "$@"
